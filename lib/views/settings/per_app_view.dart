import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/platform/installed_apps_compat.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

/// Searchable installed-app picker. Uses `installed_apps` on Android
/// (`device_apps`-style placeholder on web/desktop via the stub).
class PerAppProxyScreen extends StatefulWidget {
  const PerAppProxyScreen({super.key});

  @override
  State<PerAppProxyScreen> createState() => _PerAppProxyScreenState();
}

typedef PerAppView = PerAppProxyScreen;

class _PerAppProxyScreenState extends State<PerAppProxyScreen> {
  final _query = TextEditingController();
  List<AppInfo> _apps = [];
  var _loading = true;
  late Set<String> _blocked;

  @override
  void initState() {
    super.initState();
    _blocked = Get.find<SettingsController>().settings.blockedApps.toSet();
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final apps = await InstalledApps.getInstalledApps(true, false);
      apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() {
        _apps = apps;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String package, bool usesVpn) async {
    setState(() {
      if (usesVpn) {
        _blocked.remove(package);
      } else {
        _blocked.add(package);
      }
    });
    await Get.find<SettingsController>().setBlockedApps(_blocked.toList());
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final visible = _apps.where((app) {
      if (q.isEmpty) return true;
      return app.name.toLowerCase().contains(q) ||
          app.packageName.toLowerCase().contains(q);
    }).toList();

    return SubPageScaffold(
      kicker: 'APP GATE',
      title: 'Per-app Proxy',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.cream, fontSize: 14),
              cursorColor: AppColors.copper,
              decoration: InputDecoration(
                hintText: 'Search apps',
                hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                prefixIcon: const Icon(
                  LucideIcons.search,
                  color: AppColors.muted,
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xCC1A1612),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.85),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.85),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.copper.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.copper))
                : visible.isEmpty
                    ? const Center(
                        child: Text(
                          'No installed apps found on this device.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const Divider(
                          color: AppColors.divider,
                          height: 1,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final app = visible[index];
                          final usesVpn = !_blocked.contains(app.packageName);
                          return CheckboxListTile(
                            value: usesVpn,
                            onChanged: (checked) =>
                                _toggle(app.packageName, checked ?? false),
                            activeColor: AppColors.copper,
                            checkColor: AppColors.bg,
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Text(
                              app.name,
                              style: const TextStyle(
                                color: AppColors.cream,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              app.packageName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
