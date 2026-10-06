class AdIds {
  /// Paste Unity Monetization Dashboard → Android Game ID here.
  /// Package must be com.vbox.vbox. Empty = ads stay off (no fake demo ID).
  static const androidGameId = String.fromEnvironment(
    'UNITY_ANDROID_GAME_ID',
    defaultValue: '800390185',
  );

  static const bannerIds = ['BP_Banner_Android', 'Banner_Android'];
  static const interstitialIds = ['BP_Interstitial_Android', 'Interstitial_Android'];

  static String get banner => bannerIds.first;
  static String get interstitial => interstitialIds.first;

  static bool get configured => androidGameId.trim().isNotEmpty;
}
