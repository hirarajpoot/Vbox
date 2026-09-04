import 'package:hive_flutter/hive_flutter.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/data/models/log_entry.dart';
import 'package:vbox/data/models/subscription.dart';
import 'package:vbox/data/models/vpn_config.dart';

class StorageService {
  late Box _configs;
  late Box _subs;
  late Box _settings;
  late Box _logs;
  late Box _appSettings;

  Future<void> init() async {
    await Hive.initFlutter();
    _configs = await Hive.openBox('configs');
    _subs = await Hive.openBox('subscriptions');
    _settings = await Hive.openBox('settings');
    _logs = await Hive.openBox('logs');
    _appSettings = await Hive.openBox('appSettings');
    if (!_appSettings.containsKey('isFirstLaunch')) {
      final existing = loadSettings();
      await _appSettings.put('isFirstLaunch', !existing.onboardingDone);
    }
  }

  List<VpnConfig> loadConfigs() {
    return _configs.values
        .map((raw) => VpnConfig.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveConfig(VpnConfig config) =>
      _configs.put(config.id, config.toMap());

  Future<void> deleteConfig(String id) => _configs.delete(id);

  Future<void> deleteConfigsBySubscription(String subscriptionId) async {
    final ids = loadConfigs()
        .where((c) => c.subscriptionId == subscriptionId)
        .map((c) => c.id)
        .toList();
    await _configs.deleteAll(ids);
  }

  List<Subscription> loadSubscriptions() {
    return _subs.values
        .map(
          (raw) => Subscription.fromMap(Map<String, dynamic>.from(raw as Map)),
        )
        .toList();
  }

  Future<void> saveSubscription(Subscription sub) =>
      _subs.put(sub.id, sub.toMap());

  Future<void> deleteSubscription(String id) => _subs.delete(id);

  AppSettings loadSettings() {
    final raw = _settings.get('app');
    if (raw is Map) return AppSettings.fromMap(Map<String, dynamic>.from(raw));
    return AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) =>
      _settings.put('app', settings.toMap());

  List<LogEntry> loadLogs() {
    return _logs.values
        .map((raw) => LogEntry.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList()
      ..sort((a, b) => b.at.compareTo(a.at));
  }

  Future<void> addLog(String message) async {
    final entry = LogEntry(message: message);
    await _logs.add(entry.toMap());
    if (_logs.length > 250) {
      await _logs.deleteAt(0);
    }
  }

  Future<void> clearLogs() => _logs.clear();

  Future<void> replaceAll({
    required Iterable<VpnConfig> configs,
    required Iterable<Subscription> subscriptions,
  }) async {
    await _configs.clear();
    await _subs.clear();
    for (final config in configs) {
      await _configs.put(config.id, config.toMap());
    }
    for (final sub in subscriptions) {
      await _subs.put(sub.id, sub.toMap());
    }
  }
}
