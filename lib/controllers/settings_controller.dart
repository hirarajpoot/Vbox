import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:vbox/data/local/storage_service.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/data/models/log_entry.dart';

class SettingsController extends GetxController {
  SettingsController(this._storage);

  final StorageService _storage;

  late final AppSettings settings;
  final logs = <LogEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    settings = _storage.loadSettings();
    logs.assignAll(_storage.loadLogs());
    if (settings.deviceId == null || settings.deviceId!.isEmpty) {
      settings.deviceId = const Uuid().v4();
      persist();
    }
  }

  Future<void> persist() => _storage.saveSettings(settings);

  Future<void> toggleProxyOnly(bool value) async {
    settings.proxyOnly = value;
    update();
    await persist();
  }

  Future<void> toggleBypassLan(bool value) async {
    settings.bypassLan = value;
    if (value) {
      settings.routeMode = RouteMode.bypassLan;
    } else if (settings.routeMode == RouteMode.bypassLan) {
      settings.routeMode = RouteMode.global;
    }
    update();
    await persist();
  }

  Future<void> toggleAutoConnect(bool value) async {
    settings.autoConnect = value;
    update();
    await persist();
  }

  Future<void> toggleAutoUpdate(bool value) async {
    settings.autoUpdateSubs = value;
    update();
    await persist();
  }

  Future<void> toggleSmartConnect(bool value) async {
    settings.smartConnect = value;
    update();
    await persist();
  }

  Future<void> setDns(List<String> servers) async {
    settings.dnsServers = servers.where((s) => s.trim().isNotEmpty).toList();
    if (settings.dnsServers.isNotEmpty) {
      settings.vpnDns = settings.dnsServers.first;
    }
    update();
    await persist();
  }

  Future<void> setEnableLocalDns(bool value) async {
    settings.enableLocalDns = value;
    update();
    await persist();
  }

  Future<void> setEnableFakeDns(bool value) async {
    settings.enableFakeDns = value;
    update();
    await persist();
  }

  Future<void> setVpnDns(String value) async {
    final dns = value.trim().isEmpty ? '1.1.1.1' : value.trim();
    settings.vpnDns = dns;
    settings.dnsServers = [dns];
    await persist();
  }

  Future<void> setPerAppProxy(bool value) async {
    settings.perAppProxy = value;
    update();
    await persist();
  }

  Future<void> setAutoReconnect(bool value) async {
    settings.autoReconnect = value;
    update();
    await persist();
  }

  Future<void> setMtuSize(String value) async {
    final parsed = int.tryParse(value.trim());
    settings.mtuSize = (parsed == null || parsed <= 0) ? 1500 : parsed;
    update();
    await persist();
  }

  Future<void> setBlockedApps(List<String> packages) async {
    settings.blockedApps = packages;
    update();
    await persist();
  }

  Future<void> setRouteMode(String mode) async {
    settings.routeMode = mode;
    settings.bypassLan = mode == RouteMode.bypassLan;
    update();
    await persist();
  }

  Future<void> setCustomSubnets(List<String> subnets) async {
    settings.customBypassSubnets =
        subnets.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    update();
    await persist();
  }

  Future<void> addCustomSubnet(String raw) async {
    var value = raw.trim();
    if (value.isEmpty) return;
    if (!value.contains('/')) value = '$value/32';
    if (!_isCidr(value)) {
      Get.snackbar('Invalid subnet', 'Use CIDR like 10.0.0.0/8');
      return;
    }
    if (settings.customBypassSubnets.contains(value)) return;
    settings.customBypassSubnets = [...settings.customBypassSubnets, value];
    settings.routeMode = RouteMode.custom;
    settings.bypassLan = false;
    update();
    await persist();
  }

  Future<void> removeCustomSubnet(String value) async {
    settings.customBypassSubnets =
        settings.customBypassSubnets.where((s) => s != value).toList();
    update();
    await persist();
  }

  bool _isCidr(String value) {
    final parts = value.split('/');
    if (parts.length != 2) return false;
    final octets = parts[0].split('.');
    if (octets.length != 4) return false;
    for (final octet in octets) {
      final n = int.tryParse(octet);
      if (n == null || n < 0 || n > 255) return false;
    }
    final prefix = int.tryParse(parts[1]);
    return prefix != null && prefix >= 0 && prefix <= 32;
  }

  Future<void> addTraffic(int upload, int download) async {
    settings.totalUpload += upload;
    settings.totalDownload += download;
    update();
    await persist();
  }

  Future<void> resetTraffic() async {
    settings.totalUpload = 0;
    settings.totalDownload = 0;
    update();
    await persist();
  }

  Future<void> log(String message) async {
    await _storage.addLog(message);
    logs.assignAll(_storage.loadLogs());
  }

  Future<void> clearLogs() async {
    await _storage.clearLogs();
    logs.clear();
  }

  Future<void> completeOnboarding() async {
    settings.onboardingDone = true;
    update();
    await persist();
    final box = Hive.box('appSettings');
    await box.put('isFirstLaunch', false);
  }

  Locale get locale {
    final code = settings.languageCode;
    if (code == 'auto' || code.isEmpty) {
      return Get.deviceLocale ?? const Locale('en');
    }
    return Locale(code);
  }

  Future<void> setLanguage(String code) async {
    settings.languageCode = code;
    update();
    await persist();
    Get.updateLocale(locale);
  }
}
