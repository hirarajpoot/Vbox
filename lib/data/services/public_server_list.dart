import 'package:http/http.dart' as http;
import 'package:vbox/core/utils/share_links.dart';

class PublicListSource {
  const PublicListSource({
    required this.label,
    required this.url,
    required this.protocol,
  });

  final String label;
  final String url;
  final String protocol;
}

class PublicServerList {
  static const _file = {
    'vmess': 'vmess_configs.txt',
    'vless': 'vless_configs.txt',
    'ss': 'ss_configs.txt',
    'trojan': 'trojan_configs.txt',
  };

  static const _mirrors = [
    'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main',
    'https://cdn.jsdelivr.net/gh/ebrasha/free-v2ray-public-list@main',
  ];

  /// Light protocol files — not the full all-type subscription.
  static const sources = [
    PublicListSource(label: 'VMess', url: 'vmess', protocol: 'vmess'),
    PublicListSource(label: 'VLESS', url: 'vless', protocol: 'vless'),
    PublicListSource(label: 'Shadowsocks', url: 'ss', protocol: 'ss'),
    PublicListSource(label: 'Trojan', url: 'trojan', protocol: 'trojan'),
  ];

  static const latestLimit = 20;

  Future<List<String>> fetchLatest(PublicListSource source) async {
    final file = _file[source.protocol] ?? 'vmess_configs.txt';
    Object? lastError;
    for (final base in _mirrors) {
      try {
        final response = await http
            .get(Uri.parse('$base/$file'))
            .timeout(const Duration(seconds: 18));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }
        var links = extractShareLinks(response.body)
            .where((link) => detectProtocol(link) == source.protocol)
            .toList();
        if (links.isEmpty) {
          lastError = 'empty list';
          continue;
        }
        if (links.length > latestLimit) {
          links = links.sublist(links.length - latestLimit);
        }
        return links.reversed.toList();
      } catch (error) {
        lastError = error;
      }
    }
    throw Exception(
      'Public list is busy right now (${lastError ?? 'unavailable'}). Try Retry.',
    );
  }
}
