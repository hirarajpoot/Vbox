import 'dart:async';

import 'package:get/get.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/core/utils/public_ip.dart';
import 'package:vbox/core/utils/session_traffic.dart';
import 'package:vbox/data/models/server_model.dart';
import 'package:vbox/data/services/public_ip_service.dart';
import 'package:vbox/data/services/tun_stats.dart';

class HomeController extends GetxController {
  HomeController(
    this._vpn,
    this._servers,
    this._settings, {
    TunStats? tunStats,
    PublicIpService? ip,
  })  : _tunStats = tunStats ?? TunStats(),
        _ip = ip ?? PublicIpService();

  final VpnController _vpn;
  final ServerController _servers;
  final SettingsController _settings;
  final TunStats _tunStats;
  final PublicIpService _ip;

  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final Rx<Duration> connectionDuration = Duration.zero.obs;
  final RxString uploadSpeed = '0.0 KB/s'.obs;
  final RxString downloadSpeed = '0.0 KB/s'.obs;
  final Rx<ServerModel?> selectedServer = Rx<ServerModel?>(null);
  final RxBool smartConnect = false.obs;
  final hopPing = RxnInt();
  final publicIp = '—'.obs;
  final ipBusy = false.obs;

  Timer? _ticker;
  Timer? _lostTunnel;
  TrafficSnapshot? _pipe;
  var _readingPipe = false;
  var _ipToken = 0;
  var _upBps = 0.0;
  var _downBps = 0.0;
  var _sessionActive = false;
  String? _ispIp;

  @override
  void onInit() {
    super.onInit();
    smartConnect.value = _settings.settings.smartConnect;
    _syncSelected();
    _syncFromVpn();
    ever(_servers.servers, (_) => _syncSelected());
    ever(_servers.selectedServerId, (_) => _syncSelected());
    ever(_vpn.status, (_) => _syncFromVpn());
    ever(_vpn.connectedPing, (value) => hopPing.value = value);
    if (!isConnected.value && !isConnecting.value) {
      _refreshIp();
    }
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _lostTunnel?.cancel();
    super.onClose();
  }

  void _syncSelected() {
    final id = _servers.selectedServerId.value;
    selectedServer.value = _servers.servers.firstWhereOrNull((s) => s.id == id);
  }

  void _syncFromVpn() {
    final nowConnected = _vpn.isConnected;
    isConnecting.value = _vpn.isConnecting;
    hopPing.value = _vpn.connectedPing.value;
    _syncSelected();

    if (_vpn.isConnecting && !nowConnected) {
      publicIp.value = '—';
      ipBusy.value = true;
    }

    if (nowConnected) {
      _lostTunnel?.cancel();
      _lostTunnel = null;
      final becameConnected = !isConnected.value;
      isConnected.value = true;
      if (becameConnected && !_sessionActive) {
        _sessionActive = true;
        connectionDuration.value = Duration.zero;
        _pipe = null;
        _upBps = 0;
        _downBps = 0;
        _setSpeedLabels();
        publicIp.value = '—';
        _refreshIp(delay: const Duration(seconds: 3));
      }
      _startTicker();
      return;
    }

    if (isConnected.value) {
      _lostTunnel ??= Timer(const Duration(milliseconds: 1200), () {
        if (_vpn.isConnected || _vpn.isConnecting) return;
        isConnected.value = false;
        _sessionActive = false;
        _stopTicker();
        _upBps = 0;
        _downBps = 0;
        _setSpeedLabels();
        if (!isConnecting.value) {
          connectionDuration.value = Duration.zero;
        }
        _refreshIp();
      });
    }
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isConnected.value) return;
      connectionDuration.value += const Duration(seconds: 1);
      _refreshSpeeds();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _pipe = null;
  }

  Future<void> _refreshSpeeds() async {
    if (_readingPipe) return;
    _readingPipe = true;
    try {
      final plugin = _vpn.status.value;
      var up = plugin.uploadSpeed.toDouble();
      var down = plugin.downloadSpeed.toDouble();
      if (up <= 0 && down <= 0) {
        final now = await _tunStats.read();
        if (now == null || !isConnected.value) return;
        final prev = _pipe;
        _pipe = now;
        if (prev == null) return;
        final sample = speedFromSnapshots(prev, now);
        if (sample == null) return;
        up = sample.uploadBps;
        down = sample.downloadBps;
      }
      _upBps = _upBps * 0.55 + up * 0.45;
      _downBps = _downBps * 0.55 + down * 0.45;
      if (_upBps < 80) _upBps = 0;
      if (_downBps < 80) _downBps = 0;
      _setSpeedLabels();
    } finally {
      _readingPipe = false;
    }
  }

  void _setSpeedLabels() {
    uploadSpeed.value = formatLiveSpeed(_upBps);
    downloadSpeed.value = formatLiveSpeed(_downBps);
  }

  Future<void> selectServer(ServerModel server) async {
    await _servers.selectServer(server.id);
    _syncSelected();
  }

  Future<void> toggleSmartConnect(bool value) async {
    smartConnect.value = value;
    await _settings.toggleSmartConnect(value);
  }

  Future<void> connect() async {
    if (selectedServer.value == null) {
      Get.snackbar('No server', 'Select a server first');
      return;
    }
    await _vpn.connect();
  }

  Future<void> disconnect() async {
    await _vpn.disconnect();
  }

  Future<void> toggle() async {
    if (isConnected.value || isConnecting.value) {
      await disconnect();
    } else {
      await connect();
    }
  }

  Future<void> _refreshIp({Duration delay = Duration.zero}) async {
    final token = ++_ipToken;
    ipBusy.value = true;
    try {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
        if (token != _ipToken) return;
      }
      final viaTunnel = isConnected.value;
      final attempts = viaTunnel ? 4 : 1;
      Object? lastError;
      for (var i = 0; i < attempts; i++) {
        if (token != _ipToken) return;
        try {
          String ip;
          if (viaTunnel) {
            try {
              ip = await _tunStats.publicIp();
            } catch (nativeError) {
              try {
                ip = await _ip.lookupThroughTunnel();
              } catch (_) {
                throw nativeError;
              }
            }
          } else {
            ip = await _ip.lookup();
            if (!isConnected.value &&
                !isConnecting.value &&
                !_vpn.isConnected) {
              _ispIp = ip;
            }
          }
          if (token != _ipToken) return;
          final shown = pickPublicIpToShow(
            shown: publicIp.value,
            fetched: ip,
            ispIp: viaTunnel ? _ispIp : null,
          );
          if (shown != null) {
            publicIp.value = shown;
            return;
          }
          if (viaTunnel) {
            throw Exception('IP unchanged');
          }
          publicIp.value = ip;
          return;
        } catch (error) {
          lastError = error;
          if (viaTunnel && i + 1 < attempts && isConnected.value) {
            await Future<void>.delayed(const Duration(seconds: 2));
          }
        }
      }
      if (token != _ipToken) return;
      final kept = pickPublicIpToShow(
        shown: publicIp.value,
        fetched: null,
        ispIp: viaTunnel ? _ispIp : null,
      );
      if (kept != null) {
        publicIp.value = kept;
      } else if (!viaTunnel) {
        publicIp.value = _ipError(lastError ?? 'IP failed');
      }
    } finally {
      if (token == _ipToken) ipBusy.value = false;
    }
  }

  String _ipError(Object error) {
    var text = error.toString().replaceAll('Exception: ', '');
    text = text.replaceAll('PlatformException(', '');
    if (text.length > 42) text = text.substring(0, 42);
    return text.isEmpty ? 'IP failed' : text;
  }
}
