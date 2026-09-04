import 'package:vbox/data/models/vpn_config.dart';

class ServerModel {
  const ServerModel({
    required this.id,
    required this.name,
    required this.protocol,
    this.ping,
  });

  final String id;
  final String name;
  final String protocol;
  final int? ping;

  factory ServerModel.fromConfig(VpnConfig config) => ServerModel(
        id: config.id,
        name: config.remark,
        protocol: config.protocol,
        ping: config.lastPing,
      );
}
