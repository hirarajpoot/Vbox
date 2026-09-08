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
  static const _base =
      'https://raw.githubusercontent.com/ebrasha/free-v2ray-public-list/refs/heads/main';

  /// Light protocol files — not the full all-type subscription.
  static const sources = [
    PublicListSource(
      label: 'VMess',
      url: '$_base/vmess_configs.txt',
      protocol: 'vmess',
    ),
    PublicListSource(
      label: 'VLESS',
      url: '$_base/vless_configs.txt',
      protocol: 'vless',
    ),
    PublicListSource(
      label: 'Shadowsocks',
      url: '$_base/ss_configs.txt',
      protocol: 'ss',
    ),
    PublicListSource(
      label: 'Trojan',
      url: '$_base/trojan_configs.txt',
      protocol: 'trojan',
    ),
  ];

  static const latestLimit = 20;

  Future<List<String>> fetchLatest(PublicListSource source) async {
    final response = await http
        .get(Uri.parse(source.url))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('List HTTP ${response.statusCode}');
    }
    var links = extractShareLinks(response.body)
        .where((link) => detectProtocol(link) == source.protocol)
        .toList();
    if (links.length > latestLimit) {
      links = links.sublist(links.length - latestLimit);
    }
    return links.reversed.toList();
  }
}
