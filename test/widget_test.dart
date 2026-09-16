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

  test('live speed stays on a stable KB/s scale', () {
    expect(formatLiveSpeed(0), '0.0 KB/s');
    expect(formatLiveSpeed(10 * 1024), '10.0 KB/s');
    expect(formatLiveSpeed(2.5 * 1024 * 1024), '2.5 MB/s');
  });
}
