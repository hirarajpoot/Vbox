class InterstitialPolicy {
  static const minGap = Duration(minutes: 8);
  static const minSession = Duration(seconds: 12);
  static const afterStopDelay = Duration(milliseconds: 900);

  static bool allow({
    required bool ready,
    required bool userStopped,
    required bool connected,
    required bool connecting,
    required Duration session,
    required DateTime now,
    DateTime? lastShown,
  }) {
    if (!ready || !userStopped) return false;
    if (connected || connecting) return false;
    if (session < minSession) return false;
    if (lastShown != null && now.difference(lastShown) < minGap) return false;
    return true;
  }
}
