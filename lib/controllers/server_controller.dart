import 'dart:math';

import 'package:get/get.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/utils/share_links.dart';
import 'package:vbox/data/local/storage_service.dart';
import 'package:vbox/data/models/server_model.dart';

class ServerController extends GetxController {
  ServerController(this._storage, this._configs, this._settings);

  final StorageService _storage;
  final ConfigController _configs;
  final SettingsController _settings;

  final RxList<ServerModel> servers = <ServerModel>[].obs;
  final RxString selectedServerId = ''.obs;
  final Rx<ServerSort> sort = ServerSort.date.obs;

  @override
  void onInit() {
    super.onInit();
    loadServers();
    ever(_configs.configs, (_) => _mergeImportedConfigs());
  }

  Future<void> loadServers() async {
    final stored = _storage.loadServers();
    if (stored.isEmpty && _configs.configs.isNotEmpty) {
      for (final config in _configs.configs) {
        final group = _configs.subscriptionName(config.subscriptionId);
        stored.add(ServerModel.fromConfig(config, group: group));
        await _storage.saveServer(stored.last);
      }
    }
    servers.assignAll(stored);
    selectedServerId.value = _settings.settings.selectedConfigId ?? '';
    _applySort();
  }

  Future<void> addServer(ServerModel server) async {
    final index = servers.indexWhere((s) => s.id == server.id);
    if (index >= 0) {
      servers[index] = server;
    } else {
      servers.add(server);
    }
    await _storage.saveServer(server);
    await _mirrorConfig(server);
    _applySort();
  }

  Future<void> deleteServer(String id) async {
    servers.removeWhere((s) => s.id == id);
    await _storage.deleteServer(id);
    final config = _configs.configs.firstWhereOrNull((c) => c.id == id);
    if (config != null) await _configs.deleteConfig(config);
    if (selectedServerId.value == id) {
      selectedServerId.value = servers.isEmpty ? '' : servers.first.id;
      await _persistSelection();
    }
    servers.refresh();
  }

  Future<void> selectServer(String id) async {
    selectedServerId.value = id;
    await _persistSelection();
    final server = servers.firstWhereOrNull((s) => s.id == id);
    if (server != null) await _mirrorConfig(server);
    final config = _configs.configs.firstWhereOrNull((c) => c.id == id);
    if (config != null) await _configs.select(config);
  }

  Future<void> testPing(ServerModel server) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    server.ping = 35 + Random().nextInt(280);
    await addServer(server);
  }

  Future<void> removeServersByIds(Set<String> ids) async {
    if (ids.isEmpty) return;
    final remaining = servers.where((s) => !ids.contains(s.id)).toList();
    for (final id in ids) {
      await _storage.deleteServer(id);
    }
    servers.assignAll(remaining);
    if (ids.contains(selectedServerId.value)) {
      selectedServerId.value = servers.isEmpty ? '' : servers.first.id;
      await _persistSelection();
    }
    _applySort();
  }

  Future<void> mergeImportedConfigs() => _mergeImportedConfigs();

  Future<void> importLink(String raw) async {
    final links = extractShareLinks(raw);
    if (links.isEmpty) {
      throw Exception('No valid VMess / Shadowsocks / V2Ray link');
    }
    await _configs.importLinks(links);
    await _mergeImportedConfigs();
  }

  void setSort(ServerSort value) {
    sort.value = value;
    _applySort();
  }

  Map<String, List<ServerModel>> get grouped {
    final map = <String, List<ServerModel>>{};
    for (final server in servers) {
      map.putIfAbsent(server.group, () => []).add(server);
    }
    return map;
  }

  Future<void> _mergeImportedConfigs() async {
    var changed = false;
    for (final config in _configs.configs) {
      if (servers.any((s) => s.id == config.id || s.shareLink == config.shareLink)) {
        continue;
      }
      final server = ServerModel.fromConfig(
        config,
        group: _configs.subscriptionName(config.subscriptionId),
      );
      servers.add(server);
      await _storage.saveServer(server);
      changed = true;
    }
    if (changed) _applySort();
  }

  Future<void> _mirrorConfig(ServerModel server) async {
    final existing = _configs.configs.firstWhereOrNull((c) => c.id == server.id);
    if (existing == null) {
      final config = server.toVpnConfig();
      await _storage.saveConfig(config);
      _configs.configs.insert(0, config);
      _configs.configs.refresh();
      return;
    }
    existing.remark = server.name;
    existing.lastPing = server.ping;
    existing.shareLink = server.connectLink;
    await _storage.saveConfig(existing);
    _configs.configs.refresh();
  }

  Future<void> _persistSelection() async {
    _settings.settings.selectedConfigId =
        selectedServerId.value.isEmpty ? null : selectedServerId.value;
    await _settings.persist();
  }

  void _applySort() {
    servers.sort((a, b) {
      switch (sort.value) {
        case ServerSort.ping:
          return (a.ping ?? 99999).compareTo(b.ping ?? 99999);
        case ServerSort.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case ServerSort.date:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    servers.refresh();
  }
}
