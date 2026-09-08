class AppSettings {
  AppSettings({
    this.proxyOnly = false,
    this.bypassLan = true,
    this.autoConnect = false,
    this.autoUpdateSubs = true,
    this.smartConnect = false,
    this.selectedConfigId,
    this.enableLocalDns = true,
    this.enableFakeDns = false,
    this.vpnDns = '1.1.1.1',
    this.dnsServers = const ['1.1.1.1', '8.8.8.8'],
    this.blockedApps = const [],
    this.perAppProxy = false,
    this.autoReconnect = false,
    this.mtuSize = 1500,
    this.customBypassSubnets = const [],
    this.routeMode = RouteMode.bypassLan,
    this.totalUpload = 0,
    this.totalDownload = 0,
    this.onboardingDone = false,
    this.languageCode = 'auto',
    this.deviceId,
  });

  bool proxyOnly;
  bool bypassLan;
  bool autoConnect;
  bool autoUpdateSubs;
  bool smartConnect;
  String? selectedConfigId;
  bool enableLocalDns;
  bool enableFakeDns;
  String vpnDns;
  List<String> dnsServers;
  List<String> blockedApps;
  bool perAppProxy;
  bool autoReconnect;
  int mtuSize;
  List<String> customBypassSubnets;
  String routeMode;
  int totalUpload;
  int totalDownload;
  bool onboardingDone;
  String languageCode;
  String? deviceId;

  Map<String, dynamic> toMap() => {
        'proxyOnly': proxyOnly,
        'bypassLan': bypassLan,
        'autoConnect': autoConnect,
        'autoUpdateSubs': autoUpdateSubs,
        'smartConnect': smartConnect,
        'selectedConfigId': selectedConfigId,
        'enableLocalDns': enableLocalDns,
        'enableFakeDns': enableFakeDns,
        'vpnDns': vpnDns,
        'dnsServers': dnsServers,
        'blockedApps': blockedApps,
        'perAppProxy': perAppProxy,
        'autoReconnect': autoReconnect,
        'mtuSize': mtuSize,
        'customBypassSubnets': customBypassSubnets,
        'routeMode': routeMode,
        'totalUpload': totalUpload,
        'totalDownload': totalDownload,
        'onboardingDone': onboardingDone,
        'languageCode': languageCode,
        'language': languageCode,
        'deviceId': deviceId,
      };

  factory AppSettings.fromMap(Map map) => AppSettings(
        proxyOnly: map['proxyOnly'] as bool? ?? false,
        bypassLan: map['bypassLan'] as bool? ?? true,
        autoConnect: map['autoConnect'] as bool? ?? false,
        autoUpdateSubs: map['autoUpdateSubs'] as bool? ?? true,
        smartConnect: map['smartConnect'] as bool? ?? false,
        selectedConfigId: map['selectedConfigId'] as String?,
        enableLocalDns: map['enableLocalDns'] as bool? ?? true,
        enableFakeDns: map['enableFakeDns'] as bool? ?? false,
        vpnDns: _readVpnDns(map),
        dnsServers: List<String>.from(
          map['dnsServers'] as List? ?? const ['1.1.1.1', '8.8.8.8'],
        ),
        blockedApps: List<String>.from(map['blockedApps'] as List? ?? const []),
        perAppProxy: map['perAppProxy'] as bool? ?? false,
        autoReconnect: map['autoReconnect'] as bool? ?? false,
        mtuSize: _readMtu(map),
        customBypassSubnets: List<String>.from(
          map['customBypassSubnets'] as List? ?? const [],
        ),
        routeMode: _readRouteMode(map),
        totalUpload: map['totalUpload'] as int? ?? 0,
        totalDownload: map['totalDownload'] as int? ?? 0,
        onboardingDone: map['onboardingDone'] as bool? ?? false,
        languageCode: map['language'] as String? ??
            map['languageCode'] as String? ??
            'auto',
        deviceId: map['deviceId'] as String?,
      );

  static String _readVpnDns(Map map) {
    final stored = map['vpnDns'] as String?;
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();
    final servers = map['dnsServers'];
    if (servers is List && servers.isNotEmpty) {
      final first = servers.first.toString().trim();
      if (first.isNotEmpty) return first;
    }
    return '1.1.1.1';
  }

  static int _readMtu(Map map) {
    final raw = map['mtuSize'];
    if (raw is int && raw > 0) return raw;
    if (raw is String) return int.tryParse(raw) ?? 1500;
    return 1500;
  }

  static String _readRouteMode(Map map) {
    final stored = map['routeMode'] as String?;
    if (stored == RouteMode.global ||
        stored == RouteMode.bypassLan ||
        stored == RouteMode.custom) {
      return stored!;
    }
    return (map['bypassLan'] as bool? ?? true)
        ? RouteMode.bypassLan
        : RouteMode.global;
  }
}

abstract class RouteMode {
  static const global = 'global';
  static const bypassLan = 'bypassLan';
  static const custom = 'custom';
}
