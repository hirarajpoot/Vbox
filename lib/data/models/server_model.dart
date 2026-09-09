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
    this.network = 'tcp',
    this.streamSecurity = 'none',
    this.host = '',
    this.path = '',
    this.sni = '',
    this.fingerprint = '',
    this.flow = '',
    this.publicKey = '',
    this.shortId = '',
    this.spiderX = '',
    this.serviceName = '',
    this.alpn = '',
    this.alterId = '0',
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
  String network;
  String streamSecurity;
  String host;
  String path;
  String sni;
  String fingerprint;
  String flow;
  String publicKey;
  String shortId;
  String spiderX;
  String serviceName;
  String alpn;
  String alterId;
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
          network: network,
          host: host,
          path: path.isNotEmpty ? path : serviceName,
          tls: streamSecurity == 'none' ? '' : streamSecurity,
          sni: sni,
          fingerprint: fingerprint,
          alpn: alpn,
          alterId: alterId,
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
        return buildVlessLink(
          remark: name,
          address: address,
          port: '$port',
          uuid: uuid ?? '',
          network: network,
          security: streamSecurity,
          host: host,
          path: path,
          sni: sni,
          fingerprint: fingerprint,
          flow: flow,
          publicKey: publicKey,
          shortId: shortId,
          spiderX: spiderX,
          serviceName: serviceName,
          alpn: alpn,
        );
      case ServerProtocol.trojan:
        return buildTrojanLink(
          remark: name,
          address: address,
          port: '$port',
          password: password,
          network: network,
          security: streamSecurity == 'none' ? 'tls' : streamSecurity,
          host: host,
          path: path,
          sni: sni,
          fingerprint: fingerprint,
          serviceName: serviceName,
          alpn: alpn,
        );
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
        'network': network,
        'streamSecurity': streamSecurity,
        'host': host,
        'path': path,
        'sni': sni,
        'fingerprint': fingerprint,
        'flow': flow,
        'publicKey': publicKey,
        'shortId': shortId,
        'spiderX': spiderX,
        'serviceName': serviceName,
        'alpn': alpn,
        'alterId': alterId,
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
        network: map['network'] as String? ?? 'tcp',
        streamSecurity: map['streamSecurity'] as String? ?? 'none',
        host: map['host'] as String? ?? '',
        path: map['path'] as String? ?? '',
        sni: map['sni'] as String? ?? '',
        fingerprint: map['fingerprint'] as String? ?? '',
        flow: map['flow'] as String? ?? '',
        publicKey: map['publicKey'] as String? ?? '',
        shortId: map['shortId'] as String? ?? '',
        spiderX: map['spiderX'] as String? ?? '',
        serviceName: map['serviceName'] as String? ?? '',
        alpn: map['alpn'] as String? ?? '',
        alterId: map['alterId']?.toString() ?? '0',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
