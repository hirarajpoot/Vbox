import 'package:flutter_test/flutter_test.dart';
import 'package:vbox/core/utils/session_traffic.dart';

void main() {
  test('computes live up/down from two VPN pipe snapshots', () {
    final start = DateTime.utc(2026, 1, 1, 0, 0, 0);
    final prev = TrafficSnapshot(rx: 1000, tx: 200, at: start);
    final next = TrafficSnapshot(rx: 1000 + 50 * 1024, tx: 200 + 10 * 1024, at: start.add(const Duration(seconds: 1)));

    final speed = speedFromSnapshots(prev, next)!;

    expect(speed.downloadBps, 50 * 1024);
    expect(speed.uploadBps, 10 * 1024);
  });

  test('ignores a sample if the clock did not move', () {
    final at = DateTime.utc(2026, 1, 1);
    final prev = TrafficSnapshot(rx: 1, tx: 1, at: at);
    final next = TrafficSnapshot(rx: 999, tx: 999, at: at);
    expect(speedFromSnapshots(prev, next), isNull);
  });
}
