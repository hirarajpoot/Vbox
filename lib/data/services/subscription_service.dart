import 'package:http/http.dart' as http;
import 'package:vbox/core/utils/share_links.dart';

class SubscriptionService {
  Future<List<String>> fetchLinks(String url) async {
    final response = await http
        .get(Uri.parse(url.trim()))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Subscription HTTP ${response.statusCode}');
    }
    final links = extractShareLinks(response.body);
    if (links.isEmpty) {
      throw Exception('No VMess / Shadowsocks links found');
    }
    return links;
  }
}
