import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vbox/platform/v2ray_plugin.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/data/models/vpn_config.dart';
import 'package:vbox/data/services/v2ray_service.dart';

class VpnController extends GetxController {
  VpnController(this._v2ray, this._configs, this._settings);

  final V2RayService _v2ray;
  final ConfigController _configs;
  final SettingsController _settings;

  final status = V2RayStatus().obs;
  final busy = false.obs;
  final coreVersion = '—'.obs;
  final connectedPing = RxnInt();

  var _userStopped = true;
  var _reconnecting = false;

  bool get isConnected => status.value.state.toUpperCase() == 'CONNECTED';
  bool get isConnecting => status.value.state.toUpperCase() == 'CONNECTING';
  bool get isDisconnected => !isConnected && !isConnecting;
  bool get coreAvailable => _v2ray.isAvailable;

  @override
  void onInit() {
    super.onInit();
    _v2ray.onStatus = (value) {
      final previous = status.value.state;
      status.value = value;
      final now = value.state.toUpperCase();
      final wasConnected = previous.toUpperCase().contains('CONNECT');
      if (wasConnected && now.contains('DISCONNECT')) {
        _settings.addTraffic(value.upload, value.download);
        _settings.log('Disconnected');
        _scheduleReconnect();
      }
    };
    _loadCore();
    if (_settings.settings.autoConnect) {
      Future<void>.delayed(const Duration(milliseconds: 600), connect);
    }
    if (_settings.settings.autoUpdateSubs) {
      _configs.updateAllSubscriptions();
    }
  }

  Future<void> _loadCore() async {
    coreVersion.value = await _v2ray.coreVersion();
  }

  Future<void> toggle() async {
    if (isConnected || isConnecting) {
      await disconnect();
    } else {
      await connect();
    }
  }

  Future<void> connect() async {
    if (busy.value) return;
    _userStopped = false;
    busy.value = true;
    try {
      VpnConfig? target = _configs.selected;
      if (_settings.settings.smartConnect) {
        target = await _configs.fastest() ?? target;
        if (target != null) await _configs.select(target);
      }
      if (target == null) {
        Get.snackbar('No server', 'Add a VMess or Shadowsocks config first');
        return;
      }
      if (!_v2ray.isAvailable) {
        Get.snackbar(
          kIsWeb ? 'Web preview' : 'Android required',
          kIsWeb
              ? 'This is a web preview. Connect the VPN from the Android app.'
              : 'VPN core (flutter_v2ray) only runs on an Android phone or emulator.',
        );
        return;
      }
      if (!kIsWeb && GetPlatform.isAndroid) {
        await Permission.notification.request();
      }
      if (!_settings.settings.proxyOnly) {
        final allowed = await _v2ray.requestPermission();
        if (!allowed) {
          Get.snackbar('Permission denied', 'VPN permission is required');
          return;
        }
      }
      await _settings.log('Connecting to ${target.remark}');
      await _v2ray.start(config: target, settings: _settings.settings);
      connectedPing.value = await _v2ray.pingConnected();
    } catch (error) {
      await _settings.log('Connect failed: $error');
      Get.snackbar('Connect failed', error.toString());
    } finally {
      busy.value = false;
    }
  }

  Future<void> disconnect() async {
    _userStopped = true;
    await _v2ray.stop();
    connectedPing.value = null;
  }

  void _scheduleReconnect() {
    if (_userStopped || !_settings.settings.autoReconnect) return;
    if (_reconnecting || busy.value) return;
    _reconnecting = true;
    Future<void>.delayed(const Duration(seconds: 2), () async {
      try {
        if (_userStopped || !_settings.settings.autoReconnect) return;
        if (isConnected || isConnecting) return;
        await _settings.log('Auto reconnect');
        await connect();
      } finally {
        _reconnecting = false;
      }
    });
  }
}
