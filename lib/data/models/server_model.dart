import 'package:vbox/core/utils/share_links.dart';
import 'package:vbox/data/models/vpn_config.dart';

enum ServerProtocol { shadowsocks, vmess, vless, trojan }

enum ServerSort { ping, name, date }

ServerProtocol protocolFromString(String raw) {
  switch (raw.toLowerCase()) {
    case 'ss':
    case 'shadowsocks':
      return ServerProtocol.shadowsocks;
    case 'vless':
      return ServerProtocol.vless;
    case 'trojan':
      return ServerProtocol.trojan;
    default:
      return ServerProtocol.vmess;
  }
}

class ServerModel {
  ServerModel({
    required this.id,
    required this.name,
    required this.protocol,
    required this.address,
    required this.port,
    required this.password,
    this.uuid,
    this.ping,
    this.group = 'My Servers',
    this.isFavorite = false,
    this.shareLink = '',
    this.encryption = 'aes-256-gcm',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  ServerProtocol protocol;
  String address;
  int port;
  String password;
  String? uuid;
  int? ping;
  String group;
  bool isFavorite;
  String shareLink;
  String encryption;
  final DateTime createdAt;

  String get protocolName {
    switch (protocol) {
      case ServerProtocol.shadowsocks:
        return 'Shadowsocks';
      case ServerProtocol.vmess:
        return 'VMess';
      case ServerProtocol.vless:
        return 'VLESS';
      case ServerProtocol.trojan:
        return 'Trojan';
    }
  }

  String get protocolKey {
    switch (protocol) {
      case ServerProtocol.shadowsocks:
        return 'ss';
      case ServerProtocol.vmess:
        return 'vmess';
      case ServerProtocol.vless:
        return 'vless';
      case ServerProtocol.trojan:
        return 'trojan';
    }
  }

  String get connectLink {
    if (address.trim().isNotEmpty && port > 0) {
      return _buildLink();
    }
    if (shareLink.trim().isNotEmpty) return shareLink;
    return _buildLink();
  }

  String _buildLink() {
    switch (protocol) {
      case ServerProtocol.vmess:
        return buildVmessLink(
          remark: name,
          address: address,
          port: '$port',
          uuid: uuid ?? '',
          security: encryption,
        );
      case ServerProtocol.shadowsocks:
        return buildShadowsocksLink(
          remark: name,
          address: address,
          port: '$port',
          method: encryption,
          password: password,
        );
      case ServerProtocol.vless:
        return 'vless://${uuid ?? ''}@$address:$port#${Uri.encodeComponent(name)}';
      case ServerProtocol.trojan:
        return 'trojan://$password@$address:$port#${Uri.encodeComponent(name)}';
    }
  }

  factory ServerModel.fromConfig(VpnConfig config, {String group = 'Manual'}) {
    return ServerModel(
      id: config.id,
      name: config.remark,
      protocol: protocolFromString(config.protocol),
      address: '',
      port: 0,
      password: '',
      ping: config.lastPing,
      group: group,
      shareLink: config.shareLink,
      createdAt: config.createdAt,
    );
  }

  VpnConfig toVpnConfig() => VpnConfig(
        id: id,
        remark: name,
        shareLink: connectLink,
        protocol: protocolKey,
        lastPing: ping,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'protocol': protocol.name,
        'address': address,
        'port': port,
        'password': password,
        'uuid': uuid,
        'ping': ping,
        'group': group,
        'isFavorite': isFavorite,
        'shareLink': shareLink,
        'encryption': encryption,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServerModel.fromMap(Map map) => ServerModel(
        id: map['id'] as String,
        name: map['name'] as String? ?? 'Server',
        protocol: protocolFromString(map['protocol'] as String? ?? 'vmess'),
        address: map['address'] as String? ?? '',
        port: map['port'] as int? ?? 0,
        password: map['password'] as String? ?? '',
        uuid: map['uuid'] as String?,
        ping: map['ping'] as int?,
        group: map['group'] as String? ?? 'Manual',
        isFavorite: map['isFavorite'] as bool? ?? false,
        shareLink: map['shareLink'] as String? ?? '',
        encryption: map['encryption'] as String? ?? 'aes-256-gcm',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
