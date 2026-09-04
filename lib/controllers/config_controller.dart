import 'package:flutter/services.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/utils/share_links.dart';
import 'package:vbox/data/local/storage_service.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/data/models/subscription.dart';
import 'package:vbox/data/models/vpn_config.dart';
import 'package:vbox/data/services/subscription_service.dart';
import 'package:vbox/data/services/v2ray_service.dart';

class ConfigController extends GetxController {
  ConfigController(this._storage, this._subs, this._v2ray, this._settings);

  final StorageService _storage;
  final SubscriptionService _subs;
  final V2RayService _v2ray;
  final SettingsController _settings;
  final _uuid = const Uuid();

  final configs = <VpnConfig>[].obs;
  final subscriptions = <Subscription>[].obs;
  final pinging = false.obs;
  final updating = false.obs;
  final query = ''.obs;

  VpnConfig? get selected {
    final id = _settings.settings.selectedConfigId;
    if (id == null) return null;
    return configs.firstWhereOrNull((c) => c.id == id);
  }

  List<VpnConfig> get filtered {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return configs;
    return configs
        .where(
          (c) =>
              c.remark.toLowerCase().contains(q) ||
              c.protocol.toLowerCase().contains(q),
        )
        .toList();
  }

  Map<String?, List<VpnConfig>> get grouped {
    final map = <String?, List<VpnConfig>>{};
    for (final config in filtered) {
      map.putIfAbsent(config.subscriptionId, () => []).add(config);
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    configs.assignAll(_storage.loadConfigs());
    subscriptions.assignAll(_storage.loadSubscriptions());
  }

  Future<void> select(VpnConfig config) async {
    _settings.settings.selectedConfigId = config.id;
    await _settings.persist();
    update();
    configs.refresh();
  }

  Future<int> importLinks(
    Iterable<String> links, {
    String? subscriptionId,
  }) async {
    var added = 0;
    final existing = configs.map((c) => c.shareLink.trim()).toSet();
    for (final raw in links) {
      final link = raw.trim();
      if (link.isEmpty || existing.contains(link)) continue;
      try {
        String remark = 'Imported';
        var protocol = detectProtocol(link);
        if (protocol == 'json' || V2RayService.detectJson(link)) {
          protocol = 'json';
          remark = 'JSON config';
        } else {
          final parsed = FlutterV2ray.parseFromURL(link);
          remark = parsed.remark.trim().isEmpty ? 'Imported' : parsed.remark;
        }
        final config = VpnConfig(
          id: _uuid.v4(),
          remark: remark,
          shareLink: link,
          protocol: protocol,
          subscriptionId: subscriptionId,
        );
        await _storage.saveConfig(config);
        configs.insert(0, config);
        existing.add(link);
        added++;
      } catch (_) {}
    }
    if (added > 0 && selected == null) {
      await select(configs.first);
    }
    configs.refresh();
    return added;
  }

  Future<int> importClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text ?? '';
    final links = extractShareLinks(text);
    if (links.isEmpty) {
      throw Exception('Clipboard has no VMess / Shadowsocks / V2Ray links');
    }
    return importLinks(links);
  }

  Future<int> importRaw(String text) => importLinks(extractShareLinks(text));

  Future<void> addManual({
    required String remark,
    required String link,
  }) async {
    await importLinks([link]);
    if (configs.isNotEmpty && remark.trim().isNotEmpty) {
      final config = configs.first;
      config.remark = remark.trim();
      await _storage.saveConfig(config);
      configs.refresh();
    }
  }

  Future<void> deleteConfig(VpnConfig config) async {
    await _storage.deleteConfig(config.id);
    configs.removeWhere((c) => c.id == config.id);
    if (_settings.settings.selectedConfigId == config.id) {
      _settings.settings.selectedConfigId =
          configs.isEmpty ? null : configs.first.id;
      await _settings.persist();
    }
    configs.refresh();
  }

  Future<void> addSubscription({
    required String name,
    required String url,
  }) async {
    final sub = Subscription(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'Subscription' : name.trim(),
      url: url.trim(),
    );
    await _storage.saveSubscription(sub);
    subscriptions.add(sub);
    await refreshSubscription(sub);
  }

  Future<void> refreshSubscription(Subscription sub) async {
    updating.value = true;
    try {
      final links = await _subs.fetchLinks(sub.url);
      await _storage.deleteConfigsBySubscription(sub.id);
      configs.removeWhere((c) => c.subscriptionId == sub.id);
      await importLinks(links, subscriptionId: sub.id);
      sub.lastUpdated = DateTime.now();
      await _storage.saveSubscription(sub);
      subscriptions.refresh();
      await _settings.log('Updated ${sub.name} (${links.length} configs)');
    } finally {
      updating.value = false;
    }
  }

  Future<void> updateAllSubscriptions() async {
    updating.value = true;
    try {
      for (final sub in subscriptions.toList()) {
        try {
          await refreshSubscription(sub);
        } catch (error) {
          await _settings.log('Failed ${sub.name}: $error');
        }
      }
    } finally {
      updating.value = false;
    }
  }

  Future<void> deleteSubscription(Subscription sub) async {
    await _storage.deleteConfigsBySubscription(sub.id);
    await _storage.deleteSubscription(sub.id);
    configs.removeWhere((c) => c.subscriptionId == sub.id);
    subscriptions.removeWhere((s) => s.id == sub.id);
    configs.refresh();
  }

  Future<void> pingOne(VpnConfig config) async {
    final delay = await _v2ray.pingConfig(config, _settings.settings);
    config.lastPing = delay;
    await _storage.saveConfig(config);
    configs.refresh();
  }

  Future<void> pingAll() async {
    pinging.value = true;
    try {
      final items = configs.toList();
      for (var i = 0; i < items.length; i += 3) {
        final chunk = items.skip(i).take(3);
        await Future.wait(chunk.map(pingOne));
      }
    } finally {
      pinging.value = false;
    }
  }

  Future<VpnConfig?> fastest() async {
    await pingAll();
    final live = configs.where((c) => (c.lastPing ?? -1) >= 0).toList()
      ..sort((a, b) => (a.lastPing ?? 99999).compareTo(b.lastPing ?? 99999));
    return live.isEmpty ? null : live.first;
  }

  String subscriptionName(String? id) {
    if (id == null) return 'Manual';
    return subscriptions.firstWhereOrNull((s) => s.id == id)?.name ??
        'Subscription';
  }

  Future<void> renameConfig(VpnConfig config, String remark) async {
    final next = remark.trim();
    if (next.isEmpty) return;
    config.remark = next;
    await _storage.saveConfig(config);
    configs.refresh();
  }

  VpnConfig? byId(String id) =>
      configs.firstWhereOrNull((c) => c.id == id);

  Map<String, dynamic> exportBackup() => {
        'version': 1,
        'settings': _settings.settings.toMap(),
        'configs': configs.map((c) => c.toMap()).toList(),
        'subscriptions': subscriptions.map((s) => s.toMap()).toList(),
      };

  Future<void> importBackup(Map<String, dynamic> data) async {
    final rawConfigs = List<Map>.from(data['configs'] as List? ?? const []);
    final rawSubs = List<Map>.from(data['subscriptions'] as List? ?? const []);
    await _storage.replaceAll(
      configs: rawConfigs.map((m) => VpnConfig.fromMap(Map<String, dynamic>.from(m))),
      subscriptions: rawSubs.map((m) => Subscription.fromMap(Map<String, dynamic>.from(m))),
    );
    if (data['settings'] is Map) {
      final imported = AppSettings.fromMap(
        Map<String, dynamic>.from(data['settings'] as Map),
      );
      imported.onboardingDone = true;
      _settings.settings.proxyOnly = imported.proxyOnly;
      _settings.settings.bypassLan = imported.bypassLan;
      _settings.settings.autoConnect = imported.autoConnect;
      _settings.settings.autoUpdateSubs = imported.autoUpdateSubs;
      _settings.settings.smartConnect = imported.smartConnect;
      _settings.settings.selectedConfigId = imported.selectedConfigId;
      _settings.settings.dnsServers = imported.dnsServers;
      _settings.settings.blockedApps = imported.blockedApps;
      _settings.settings.customBypassSubnets = imported.customBypassSubnets;
      await _settings.persist();
    }
    configs.assignAll(_storage.loadConfigs());
    subscriptions.assignAll(_storage.loadSubscriptions());
    _settings.update();
  }
}
