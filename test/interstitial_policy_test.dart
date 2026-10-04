import 'package:flutter_test/flutter_test.dart';
import 'package:vbox/core/ads/interstitial_policy.dart';

void main() {
  final now = DateTime.utc(2026, 10, 4, 12);

  bool allow({
    bool ready = true,
    bool userStopped = true,
    bool connected = false,
    bool connecting = false,
    Duration session = const Duration(seconds: 30),
    DateTime? lastShown,
  }) {
    return InterstitialPolicy.allow(
      ready: ready,
      userStopped: userStopped,
      connected: connected,
      connecting: connecting,
      session: session,
      now: now,
      lastShown: lastShown,
    );
  }

  test('shows after a real session when idle', () {
    expect(allow(), isTrue);
  });

  test('skips splash connect and live tunnel', () {
    expect(allow(ready: false), isFalse);
    expect(allow(connected: true), isFalse);
    expect(allow(connecting: true), isFalse);
    expect(allow(userStopped: false), isFalse);
  });

  test('skips accidental quick toggle', () {
    expect(allow(session: const Duration(seconds: 5)), isFalse);
  });

  test('waits out the cooldown', () {
    expect(allow(lastShown: now.subtract(const Duration(minutes: 2))), isFalse);
    expect(allow(lastShown: now.subtract(const Duration(minutes: 9))), isTrue);
  });
}
