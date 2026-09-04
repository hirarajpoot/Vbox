import 'package:flutter_test/flutter_test.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/core/utils/share_links.dart';

void main() {
  test('formats bytes and detects share links', () {
    expect(formatBytes(0), '0 B');
    expect(detectProtocol('vmess://abc'), 'vmess');
    expect(detectProtocol('ss://abc'), 'ss');
    expect(extractShareLinks('vmess://one\nss://two').length, 2);
  });
}
