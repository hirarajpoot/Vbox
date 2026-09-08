import 'package:hive_flutter/hive_flutter.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/data/models/log_entry.dart';
import 'package:vbox/data/models/server_model.dart';
import 'package:vbox/data/models/subscription.dart';
import 'package:vbox/data/models/vpn_config.dart';

class StorageService {
  late Box _configs;
  late Box _subs;
  late Box _settings;
  late Box _logs;
  late Box _appSettings;
  late Box _servers;

  Future<void> init() async {
    await Hive.initFlutter();
    _configs = await Hive.openBox('configs');
    _subs = await Hive.openBox('subscriptionsBox');
    _settings = await Hive.openBox('settings');
    _logs = await Hive.openBox('logs');
    _appSettings = await Hive.openBox('appSettings');
    _servers = await Hive.openBox('serversBox');
    await _migrateLegacySubscriptions();
    if (!_appSettings.containsKey('isFirstLaunch')) {
      final existing = loadSettings();
      await _appSettings.put('isFirstLaunch', !existing.onboardingDone);
    }
  }

  Future<void> _migrateLegacySubscriptions() async {
    if (_subs.isNotEmpty) return;
    final legacy = await Hive.openBox('subscriptions');
    if (legacy.isEmpty) return;
    for (final key in legacy.keys) {
      await _subs.put(key, legacy.get(key));
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
    final settings = raw is Map
        ? AppSettings.fromMap(Map<String, dynamic>.from(raw))
        : AppSettings();
    if (_appSettings.containsKey('enableLocalDns')) {
      settings.enableLocalDns =
          _appSettings.get('enableLocalDns') as bool? ?? settings.enableLocalDns;
    }
    if (_appSettings.containsKey('enableFakeDns')) {
      settings.enableFakeDns =
          _appSettings.get('enableFakeDns') as bool? ?? settings.enableFakeDns;
    }
    final storedDns = _appSettings.get('vpnDns');
    if (storedDns is String && storedDns.trim().isNotEmpty) {
      settings.vpnDns = storedDns.trim();
      settings.dnsServers = [settings.vpnDns];
    }
    if (_appSettings.containsKey('perAppProxy')) {
      settings.perAppProxy =
          _appSettings.get('perAppProxy') as bool? ?? settings.perAppProxy;
    }
    if (_appSettings.containsKey('bypassLan')) {
      settings.bypassLan =
          _appSettings.get('bypassLan') as bool? ?? settings.bypassLan;
    }
    if (_appSettings.containsKey('autoReconnect')) {
      settings.autoReconnect =
          _appSettings.get('autoReconnect') as bool? ?? settings.autoReconnect;
    }
    final storedMtu = _appSettings.get('mtuSize');
    if (storedMtu is int && storedMtu > 0) {
      settings.mtuSize = storedMtu;
    } else if (storedMtu is String) {
      settings.mtuSize = int.tryParse(storedMtu) ?? settings.mtuSize;
    }
    final storedBlocked = _appSettings.get('blockedApps');
    if (storedBlocked is List) {
      settings.blockedApps = List<String>.from(storedBlocked);
    }
    final storedMode = _appSettings.get('routeMode');
    if (storedMode is String && storedMode.isNotEmpty) {
      settings.routeMode = storedMode;
      settings.bypassLan = storedMode == RouteMode.bypassLan;
    }
    final storedLanguage = _appSettings.get('language');
    if (storedLanguage is String && storedLanguage.isNotEmpty) {
      settings.languageCode = storedLanguage;
    }
    return settings;
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settings.put('app', settings.toMap());
    await _appSettings.put('enableLocalDns', settings.enableLocalDns);
    await _appSettings.put('enableFakeDns', settings.enableFakeDns);
    await _appSettings.put('vpnDns', settings.vpnDns);
    await _appSettings.put('perAppProxy', settings.perAppProxy);
    await _appSettings.put('bypassLan', settings.bypassLan);
    await _appSettings.put('autoReconnect', settings.autoReconnect);
    await _appSettings.put('mtuSize', settings.mtuSize);
    await _appSettings.put('blockedApps', settings.blockedApps);
    await _appSettings.put('routeMode', settings.routeMode);
    await _appSettings.put('language', settings.languageCode);
  }

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

  List<ServerModel> loadServers() {
    return _servers.values
        .map((raw) => ServerModel.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();
  }

  Future<void> saveServer(ServerModel server) =>
      _servers.put(server.id, server.toMap());

  Future<void> deleteServer(String id) => _servers.delete(id);

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
