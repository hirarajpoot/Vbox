import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/app_toggle.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class PerAppView extends StatefulWidget {
  const PerAppView({super.key});

  @override
  State<PerAppView> createState() => _PerAppViewState();
}

class _PerAppViewState extends State<PerAppView> {
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
      apps.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        _apps = apps;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggle(String package) async {
    setState(() {
      if (_blocked.contains(package)) {
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
      title: 'Per-app proxy',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search installed apps',
                prefixIcon: Icon(LucideIcons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Text(
              'On apps stay off the VPN (flutter_v2ray blockedApps).',
              style: AppText.caption,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      8,
                      AppSpacing.screen,
                      24,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final app = visible[index];
                      final pkg = app.packageName;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppToggleRow(
                          title: app.name,
                          subtitle: pkg,
                          value: _blocked.contains(pkg),
                          onChanged: (_) => _toggle(pkg),
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
