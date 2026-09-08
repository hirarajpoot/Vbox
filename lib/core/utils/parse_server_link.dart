import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:vbox/core/utils/share_links.dart';
import 'package:vbox/data/models/server_model.dart';

ServerModel? parseServerLink(String raw) {
  final links = extractShareLinks(raw);
  final link = links.isEmpty ? raw.trim() : links.first;
  final lower = link.toLowerCase();
  try {
    if (lower.startsWith('vmess://')) return _parseVmess(link);
    if (lower.startsWith('ss://')) return _parseShadowsocks(link);
    if (lower.startsWith('vless://')) return _parseUri(link, ServerProtocol.vless);
    if (lower.startsWith('trojan://')) {
      return _parseUri(link, ServerProtocol.trojan);
    }
  } catch (_) {}
  return null;
}

ServerModel _parseVmess(String link) {
  final payload = link.substring(8).split('#').first.split('?').first;
  final decoded = utf8.decode(
    base64.decode(_pad(payload.replaceAll(RegExp(r'\s'), ''))),
  );
  final map = jsonDecode(decoded);
  if (map is! Map) throw const FormatException('Invalid vmess');
  final address = map['add']?.toString() ?? '';
  final port = int.tryParse(map['port']?.toString() ?? '') ?? 0;
  final uuid = map['id']?.toString() ?? '';
  final name = map['ps']?.toString().trim().isNotEmpty == true
      ? map['ps'].toString()
      : remarkFromShareLink(link);
  return ServerModel(
    id: const Uuid().v4(),
    name: name,
    protocol: ServerProtocol.vmess,
    address: address,
    port: port,
    password: '',
    uuid: uuid,
    group: 'My Servers',
    shareLink: link,
    encryption: map['scy']?.toString() ?? 'aes-256-gcm',
  );
}

ServerModel _parseShadowsocks(String link) {
  final hash = link.indexOf('#');
  final body = hash >= 0 ? link.substring(5, hash) : link.substring(5);
  final name = remarkFromShareLink(link);
  var method = 'aes-256-gcm';
  var password = '';
  var address = '';
  var port = 0;

  if (body.contains('@')) {
    final uri = Uri.parse('ss://$body');
    address = uri.host;
    port = uri.port;
    final userInfo = uri.userInfo;
    final decoded = _tryDecode(userInfo) ?? userInfo;
    final split = decoded.split(':');
    if (split.length >= 2) {
      method = split.first;
      password = split.sublist(1).join(':');
    }
  } else {
    final decoded = _tryDecode(body.split('?').first) ?? body;
    final at = decoded.lastIndexOf('@');
    if (at > 0) {
      final creds = decoded.substring(0, at);
      final host = decoded.substring(at + 1);
      final credSplit = creds.split(':');
      if (credSplit.length >= 2) {
        method = credSplit.first;
        password = credSplit.sublist(1).join(':');
      }
      final hostSplit = host.split(':');
      address = hostSplit.first;
      port = int.tryParse(hostSplit.length > 1 ? hostSplit.last : '') ?? 0;
    }
  }

  return ServerModel(
    id: const Uuid().v4(),
    name: name,
    protocol: ServerProtocol.shadowsocks,
    address: address,
    port: port,
    password: password,
    group: 'My Servers',
    shareLink: link,
    encryption: method,
  );
}

ServerModel _parseUri(String link, ServerProtocol protocol) {
  final uri = Uri.parse(link);
  final secret = Uri.decodeComponent(uri.userInfo);
  return ServerModel(
    id: const Uuid().v4(),
    name: remarkFromShareLink(link),
    protocol: protocol,
    address: uri.host,
    port: uri.hasPort ? uri.port : 0,
    password: protocol == ServerProtocol.trojan ? secret : '',
    uuid: protocol == ServerProtocol.vless ? secret : null,
    group: 'My Servers',
    shareLink: link,
  );
}

String? _tryDecode(String value) {
  try {
    return utf8.decode(base64.decode(_pad(value.replaceAll(RegExp(r'\s'), ''))));
  } catch (_) {
    try {
      return utf8.decode(base64Url.decode(_pad(value.replaceAll(RegExp(r'\s'), ''))));
    } catch (_) {
      return null;
    }
  }
}

String _pad(String value) {
  final remainder = value.length % 4;
  if (remainder == 0) return value;
  return value.padRight(value.length + (4 - remainder), '=');
}
