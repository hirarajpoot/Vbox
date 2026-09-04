import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  }

  Future<void> persist() => _storage.saveSettings(settings);

  Future<void> toggleProxyOnly(bool value) async {
    settings.proxyOnly = value;
    update();
    await persist();
  }

  Future<void> toggleBypassLan(bool value) async {
    settings.bypassLan = value;
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
    update();
    await persist();
  }

  Future<void> setBlockedApps(List<String> packages) async {
    settings.blockedApps = packages;
    update();
    await persist();
  }

  Future<void> setCustomSubnets(List<String> subnets) async {
    settings.customBypassSubnets =
        subnets.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    update();
    await persist();
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

  Future<void> setLanguage(String code) async {
    settings.languageCode = code;
    update();
    await persist();
    Get.updateLocale(Locale(code));
  }
}
