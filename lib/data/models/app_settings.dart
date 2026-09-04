class AppSettings {
  AppSettings({
    this.proxyOnly = false,
    this.bypassLan = true,
    this.autoConnect = false,
    this.autoUpdateSubs = true,
    this.smartConnect = false,
    this.selectedConfigId,
    this.dnsServers = const ['1.1.1.1', '8.8.8.8'],
    this.blockedApps = const [],
    this.customBypassSubnets = const [],
    this.totalUpload = 0,
    this.totalDownload = 0,
    this.onboardingDone = false,
    this.languageCode = 'en',
  });

  bool proxyOnly;
  bool bypassLan;
  bool autoConnect;
  bool autoUpdateSubs;
  bool smartConnect;
  String? selectedConfigId;
  List<String> dnsServers;
  List<String> blockedApps;
  List<String> customBypassSubnets;
  int totalUpload;
  int totalDownload;
  bool onboardingDone;
  String languageCode;

  Map<String, dynamic> toMap() => {
        'proxyOnly': proxyOnly,
        'bypassLan': bypassLan,
        'autoConnect': autoConnect,
        'autoUpdateSubs': autoUpdateSubs,
        'smartConnect': smartConnect,
        'selectedConfigId': selectedConfigId,
        'dnsServers': dnsServers,
        'blockedApps': blockedApps,
        'customBypassSubnets': customBypassSubnets,
        'totalUpload': totalUpload,
        'totalDownload': totalDownload,
        'onboardingDone': onboardingDone,
        'languageCode': languageCode,
      };

  factory AppSettings.fromMap(Map map) => AppSettings(
        proxyOnly: map['proxyOnly'] as bool? ?? false,
        bypassLan: map['bypassLan'] as bool? ?? true,
        autoConnect: map['autoConnect'] as bool? ?? false,
        autoUpdateSubs: map['autoUpdateSubs'] as bool? ?? true,
        smartConnect: map['smartConnect'] as bool? ?? false,
        selectedConfigId: map['selectedConfigId'] as String?,
        dnsServers: List<String>.from(
          map['dnsServers'] as List? ?? const ['1.1.1.1', '8.8.8.8'],
        ),
        blockedApps: List<String>.from(map['blockedApps'] as List? ?? const []),
        customBypassSubnets: List<String>.from(
          map['customBypassSubnets'] as List? ?? const [],
        ),
        totalUpload: map['totalUpload'] as int? ?? 0,
        totalDownload: map['totalDownload'] as int? ?? 0,
        onboardingDone: map['onboardingDone'] as bool? ?? false,
        languageCode: map['languageCode'] as String? ?? 'en',
      );
}
