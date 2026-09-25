import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/data/models/vpn_config.dart';
import 'package:vbox/data/services/v2ray_service.dart';

List<String> _tags(Map<String, dynamic> map) {
  return (map['outbounds'] as List)
      .map((item) => (item as Map)['tag']?.toString() ?? '')
      .toList();
}

void main() {
  final service = V2RayService();
  const ssLink = 'ss://YWVzLTI1Ni1nY206dGVzdA==@10.0.0.1:8388#node';

  test('share-link config enables stats the Android plugin can query', () {
    final json = service.buildConfiguration(
      VpnConfig(
        id: '1',
        remark: 'node',
        shareLink: ssLink,
        protocol: 'ss',
      ),
      AppSettings(),
    );
    final map = jsonDecode(json) as Map<String, dynamic>;

    expect(map.containsKey('stats'), isTrue);
    expect(map['policy'], isA<Map>());
    final system = (map['policy'] as Map)['system'] as Map;
    expect(system['statsOutboundUplink'], isTrue);
    expect(system['statsOutboundDownlink'], isTrue);

    final tags = _tags(map);
    expect(tags.contains('proxy'), isTrue);
    expect(tags.contains('block'), isTrue);
    expect(tags.first, 'proxy');
  });

  test('bypass LAN keeps private IPs on the direct outbound', () {
    final json = service.buildConfiguration(
      VpnConfig(
        id: '1',
        remark: 'node',
        shareLink: ssLink,
        protocol: 'ss',
      ),
      AppSettings(routeMode: RouteMode.bypassLan),
    );
    final map = jsonDecode(json) as Map<String, dynamic>;
    final rules = (map['routing'] as Map)['rules'] as List;
    expect(
      rules.any(
        (rule) =>
            rule is Map &&
            rule['outboundTag'] == 'direct' &&
            (rule['ip'] as List).contains('geoip:private'),
      ),
      isTrue,
    );
  });

  test('config exposes a local HTTP inbound so IP can be checked through the tunnel', () {
    final json = service.buildConfiguration(
      VpnConfig(
        id: '1',
        remark: 'node',
        shareLink: ssLink,
        protocol: 'ss',
      ),
      AppSettings(),
    );
    final map = jsonDecode(json) as Map<String, dynamic>;
    final inbounds = map['inbounds'] as List;
    expect(
      inbounds.any(
        (item) =>
            item is Map &&
            item['protocol'] == 'http' &&
            item['port'] == 10809,
      ),
      isTrue,
    );
    expect(
      inbounds.any(
        (item) =>
            item is Map &&
            item['protocol'] == 'socks' &&
            item['port'] == 10808,
      ),
      isTrue,
    );
    final httpIn = inbounds.firstWhere(
      (item) => item is Map && item['port'] == 10809,
    ) as Map;
    final socks = inbounds.firstWhere(
      (item) => item is Map && item['port'] == 10808,
    ) as Map;
    expect((socks['sniffing'] as Map)['destOverride'], ['http', 'tls']);
    expect(json.toLowerCase().contains('fakedns'), isFalse);
  });

  test('json config with a custom outbound tag is renamed to proxy and moved first', () {
    const raw = '''
{
  "inbounds": [{"port": 1080, "protocol": "socks", "settings": {"udp": true, "auth": "noauth"}}],
  "outbounds": [
    {"protocol": "freedom", "tag": "direct"},
    {"protocol": "shadowsocks", "tag": "myss", "settings": {"servers": [{"address": "1.2.3.4", "port": 8388, "method": "aes-256-gcm", "password": "x"}]}},
    {"protocol": "blackhole", "tag": "blackhole"}
  ],
  "routing": {
    "rules": [
      {"type": "field", "outboundTag": "myss", "network": "tcp,udp"}
    ]
  }
}
''';
    final json = service.buildConfiguration(
      VpnConfig(
        id: '2',
        remark: 'json',
        shareLink: raw,
        protocol: 'json',
      ),
      AppSettings(),
    );
    final map = jsonDecode(json) as Map<String, dynamic>;
    final tags = _tags(map);
    expect(tags.first, 'proxy');
    expect(tags.contains('block'), isTrue);
    expect(tags.contains('myss'), isFalse);

    final rules = (map['routing'] as Map)['rules'] as List;
    expect(
      rules.any(
        (rule) => rule is Map && rule['outboundTag'] == 'dns-out',
      ),
      isTrue,
    );
    expect(
      rules.any(
        (rule) => rule is Map && rule['outboundTag'] == 'proxy',
      ),
      isTrue,
    );
  });
}
