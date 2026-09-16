import 'package:flutter_test/flutter_test.dart';
import 'package:vbox/core/utils/public_ip.dart';

void main() {
  test('reads a plain IPv4 body from an IP check service', () {
    expect(parsePublicIp('  203.0.113.10\n'), '203.0.113.10');
  });

  test('rejects html or empty replies', () {
    expect(parsePublicIp(''), isNull);
    expect(parsePublicIp('<html>not an ip</html>'), isNull);
  });

  test('reads the IP from a raw HTTP response through the local tunnel', () {
    expect(
      parsePublicIpFromHttp(
        'HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n198.51.100.20\n',
      ),
      '198.51.100.20',
    );
  });

  test('reads ip= from Cloudflare trace, not the resolver address', () {
    expect(
      parsePublicIpFromHttp(
        'fl=123\nh=1.1.1.1\nip=203.0.113.44\nts=1.0\n',
      ),
      '203.0.113.44',
    );
  });
}
