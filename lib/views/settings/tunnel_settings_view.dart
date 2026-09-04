import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/widgets/app_toggle.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class TunnelSettingsView extends StatelessWidget {
  const TunnelSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Tunnel settings',
      body: GetBuilder<SettingsController>(
        builder: (c) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            AppToggleRow(
              title: 'VPN tunnel',
              subtitle: c.settings.proxyOnly
                  ? 'Proxy only — no system VPN'
                  : 'Route device traffic through the tunnel',
              value: !c.settings.proxyOnly,
              onChanged: (v) => c.toggleProxyOnly(!v),
            ),
            AppToggleRow(
              title: 'Smart connect',
              subtitle: 'Ping all, then join the fastest',
              value: c.settings.smartConnect,
              onChanged: c.toggleSmartConnect,
            ),
            AppToggleRow(
              title: 'Auto connect',
              subtitle: 'Start the last server on launch',
              value: c.settings.autoConnect,
              onChanged: c.toggleAutoConnect,
            ),
            const SizedBox(height: 8),
            SettingsNavTile(
              icon: LucideIcons.layoutGrid,
              title: 'Per-app proxy',
              subtitle: 'Exclude apps from the tunnel',
              onTap: () => Get.toNamed(AppRoutes.perApp),
            ),
          ],
        ),
      ),
    );
  }
}
