import 'dart:convert';

String detectProtocol(String raw) {
  final value = raw.trim().toLowerCase();
  if (value.startsWith('vmess://')) return 'vmess';
  if (value.startsWith('vless://')) return 'vless';
  if (value.startsWith('ss://') || value.startsWith('ssr://')) return 'ss';
  if (value.startsWith('trojan://')) return 'trojan';
  if (value.startsWith('hysteria2://') || value.startsWith('hy2://')) {
    return 'hysteria2';
  }
  if (value.startsWith('{')) return 'json';
  return 'unknown';
}

bool isShareLink(String raw) {
  final protocol = detectProtocol(raw);
  return protocol != 'unknown' && protocol != 'json';
}

String remarkFromShareLink(String link) {
  final trimmed = link.trim();
  if (trimmed.isEmpty) return 'Imported';

  if (trimmed.toLowerCase().startsWith('vmess://')) {
    try {
      final payload =
          trimmed.substring(8).split('#').first.split('?').first;
      final decoded = utf8.decode(
        base64.decode(_padBase64(payload.replaceAll(RegExp(r'\s'), ''))),
      );
      final map = jsonDecode(decoded);
      if (map is Map &&
          (map['ps']?.toString().trim().isNotEmpty ?? false)) {
        return map['ps'].toString();
      }
    } catch (_) {}
  }

  final hashIndex = trimmed.indexOf('#');
  if (hashIndex >= 0 && hashIndex < trimmed.length - 1) {
    final fragment = trimmed.substring(hashIndex + 1);
    try {
      final decoded = Uri.decodeComponent(fragment);
      if (decoded.trim().isNotEmpty) return decoded;
    } catch (_) {
      if (fragment.trim().isNotEmpty) return fragment;
    }
  }

  return 'Imported';
}

List<String> extractShareLinks(String input) {
  final decoded = _maybeDecodeSubscription(input);
  final links = <String>[];
  for (final line in decoded.split(RegExp(r'[\r\n]+'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (isShareLink(trimmed) || detectProtocol(trimmed) == 'json') {
      links.add(trimmed);
    }
  }
  if (links.isEmpty && isShareLink(input.trim())) {
    links.add(input.trim());
  }
  return links;
}

String _maybeDecodeSubscription(String body) {
  final trimmed = body.trim();
  if (trimmed.startsWith('vmess://') ||
      trimmed.startsWith('vless://') ||
      trimmed.startsWith('ss://') ||
      trimmed.startsWith('trojan://') ||
      trimmed.startsWith('{')) {
    return trimmed;
  }
  try {
    final normalized = trimmed.replaceAll(RegExp(r'\s'), '');
    final decoded = utf8.decode(base64.decode(_padBase64(normalized)));
    if (decoded.contains('://') || decoded.trim().startsWith('{')) {
      return decoded;
    }
  } catch (_) {}
  return trimmed;
}

String _padBase64(String value) {
  final remainder = value.length % 4;
  if (remainder == 0) return value;
  return value.padRight(value.length + (4 - remainder), '=');
}

String buildVmessLink({
  required String remark,
  required String address,
  required String port,
  required String uuid,
  String alterId = '0',
  String security = 'auto',
  String network = 'tcp',
  String host = '',
  String path = '',
  String tls = '',
}) {
  final payload = {
    'v': '2',
    'ps': remark,
    'add': address,
    'port': port,
    'id': uuid,
    'aid': alterId,
    'scy': security,
    'net': network,
    'type': 'none',
    'host': host,
    'path': path,
    'tls': tls,
  };
  return 'vmess://${base64Encode(utf8.encode(jsonEncode(payload)))}';
}

String buildShadowsocksLink({
  required String remark,
  required String address,
  required String port,
  required String method,
  required String password,
}) {
  final userInfo = base64Url
      .encode(utf8.encode('$method:$password'))
      .replaceAll('=', '');
  return 'ss://$userInfo@$address:$port#${Uri.encodeComponent(remark)}';
}
