class AdIds {
  /// Paste Unity Monetization Dashboard → Android Game ID here.
  /// Package must be com.vbox.vbox. Empty = ads stay off (no fake demo ID).
  static const androidGameId = String.fromEnvironment(
    'UNITY_ANDROID_GAME_ID',
    defaultValue: '',
  );

  static const bannerIds = ['Banner_Android', 'banner'];
  static const interstitialIds = ['Interstitial_Android', 'video'];

  static String get banner => bannerIds.first;
  static String get interstitial => interstitialIds.first;

  static bool get configured => androidGameId.trim().isNotEmpty;
}
