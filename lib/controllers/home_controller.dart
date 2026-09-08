import 'dart:async';

import 'package:get/get.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/data/models/server_model.dart';

class HomeController extends GetxController {
  HomeController(this._vpn, this._servers, this._settings);

  final VpnController _vpn;
  final ServerController _servers;
  final SettingsController _settings;

  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;
  final Rx<Duration> connectionDuration = Duration.zero.obs;
  final RxString uploadSpeed = '0 KB/s'.obs;
  final RxString downloadSpeed = '0 KB/s'.obs;
  final Rx<ServerModel?> selectedServer = Rx<ServerModel?>(null);
  final RxBool smartConnect = false.obs;

  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    smartConnect.value = _settings.settings.smartConnect;
    _syncSelected();
    _syncFromVpn();
    ever(_servers.servers, (_) => _syncSelected());
    ever(_servers.selectedServerId, (_) => _syncSelected());
    ever(_vpn.status, (_) => _syncFromVpn());
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
    final status = _vpn.status.value;
    uploadSpeed.value = formatSpeed(status.uploadSpeed);
    downloadSpeed.value = formatSpeed(status.downloadSpeed);
    _syncSelected();

    if (isConnected.value) {
      if (!wasConnected) connectionDuration.value = Duration.zero;
      _startTicker();
    } else {
      _stopTicker();
      if (!isConnecting.value) {
        connectionDuration.value = Duration.zero;
      }
    }
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (isConnected.value) {
        connectionDuration.value += const Duration(seconds: 1);
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
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
}
