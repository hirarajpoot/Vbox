import 'dart:async';

import 'package:get/get.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/core/utils/formatters.dart';
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
  TrafficSnapshot? _pipe;
  var _readingPipe = false;
  var _ipToken = 0;
  var _upBps = 0.0;
  var _downBps = 0.0;

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
    _refreshIp();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  void _syncSelected() {
    final id = _servers.selectedServerId.value;
    selectedServer.value = _servers.servers.firstWhereOrNull((s) => s.id == id);
  }

  void _syncFromVpn() {
    final wasConnected = isConnected.value;
    isConnected.value = _vpn.isConnected;
    isConnecting.value = _vpn.isConnecting;
    hopPing.value = _vpn.connectedPing.value;
    _syncSelected();

    if (isConnected.value) {
      if (!wasConnected) {
        connectionDuration.value = Duration.zero;
        _pipe = null;
        _upBps = 0;
        _downBps = 0;
        _setSpeedLabels();
        _refreshIp(delay: const Duration(seconds: 3));
      }
      _startTicker();
    } else {
      _stopTicker();
      _upBps = 0;
      _downBps = 0;
      _setSpeedLabels();
      if (!isConnecting.value) {
        connectionDuration.value = Duration.zero;
      }
      if (wasConnected) _refreshIp();
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
      final attempts = viaTunnel ? 3 : 1;
      Object? lastError;
      for (var i = 0; i < attempts; i++) {
        if (token != _ipToken) return;
        try {
          String ip;
          if (viaTunnel) {
            try {
              ip = await _ip.lookupThroughTunnel();
            } catch (dartError) {
              try {
                ip = await _tunStats.publicIp();
              } catch (_) {
                throw dartError;
              }
            }
          } else {
            ip = await _ip.lookup();
          }
          if (token != _ipToken) return;
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
      publicIp.value = _ipError(lastError ?? 'IP failed');
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
