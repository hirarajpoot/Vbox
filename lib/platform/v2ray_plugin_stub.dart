class V2RayStatus {
  V2RayStatus({
    this.duration = '00:00:00',
    this.uploadSpeed = 0,
    this.downloadSpeed = 0,
    this.upload = 0,
    this.download = 0,
    this.state = 'DISCONNECTED',
  });

  final String duration;
  final int uploadSpeed;
  final int downloadSpeed;
  final int upload;
  final int download;
  final String state;
}

class _ParsedUrl {
  _ParsedUrl({required this.remark});

  final String remark;
  Map<String, dynamic> dns = {};

  String getFullConfiguration({int indent = 2}) => '{}';
}

class FlutterV2ray {
  FlutterV2ray({required void Function(V2RayStatus status) onStatusChanged});

  static _ParsedUrl parseFromURL(String url) {
    final hash = url.indexOf('#');
    var remark = 'Imported';
    if (hash >= 0 && hash < url.length - 1) {
      remark = Uri.decodeComponent(url.substring(hash + 1));
    }
    return _ParsedUrl(remark: remark);
  }

  Future<void> initializeV2Ray({
    String notificationIconResourceType = 'mipmap',
    String notificationIconResourceName = 'ic_launcher',
  }) async {}

  Future<bool> requestPermission() async => false;

  Future<void> startV2Ray({
    required String remark,
    required String config,
    List<String>? blockedApps,
    List<String>? bypassSubnets,
    bool proxyOnly = false,
    String notificationDisconnectButtonName = 'DISCONNECT',
  }) async {
    throw UnsupportedError('VPN core is not available on web.');
  }

  Future<void> stopV2Ray() async {}

  Future<int> getServerDelay({
    required String config,
    String url = 'https://google.com/generate_204',
  }) async =>
      -1;

  Future<int> getConnectedServerDelay({
    String url = 'https://google.com/generate_204',
  }) async =>
      -1;

  Future<String> getCoreVersion() async => 'web preview';
}
