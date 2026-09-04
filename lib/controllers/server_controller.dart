import 'package:get/get.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/data/models/server_model.dart';
import 'package:vbox/data/models/vpn_config.dart';

class ServerController extends GetxController {
  ServerController(this._configs);

  final ConfigController _configs;

  final servers = <ServerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _sync();
    ever(_configs.configs, (_) => _sync());
  }

  void _sync() {
    servers.assignAll(
      _configs.configs.map(ServerModel.fromConfig),
    );
  }

  VpnConfig? configById(String id) =>
      _configs.configs.firstWhereOrNull((c) => c.id == id);

  Future<void> select(ServerModel server) async {
    final config = configById(server.id);
    if (config == null) return;
    await _configs.select(config);
  }
}
