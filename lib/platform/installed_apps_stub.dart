class AppInfo {
  AppInfo({
    required this.name,
    required this.packageName,
  });

  final String name;
  final String packageName;
}

class InstalledApps {
  static Future<List<AppInfo>> getInstalledApps(
    bool excludeSystemApps,
    bool withIcon,
  ) async =>
      const [];
}
