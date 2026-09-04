import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/ember_card.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          8,
          AppSpacing.screen,
          28,
        ),
        children: [
          Text('Settings', style: AppText.heading),
          const SizedBox(height: AppSpacing.section),
          EmberCard(
            child: Column(
              children: [
                SettingsNavTile(
                  icon: LucideIcons.shield,
                  title: 'Tunnel settings',
                  subtitle: 'VPN mode, smart connect, per-app',
                  onTap: () => Get.toNamed(AppRoutes.tunnel),
                ),
                SettingsNavTile(
                  icon: LucideIcons.globe,
                  title: 'DNS settings',
                  subtitle: 'Resolvers used on connect',
                  onTap: () => Get.toNamed(AppRoutes.dns),
                ),
                SettingsNavTile(
                  icon: LucideIcons.router,
                  title: 'Route settings',
                  subtitle: 'Bypass LAN and custom subnets',
                  onTap: () => Get.toNamed(AppRoutes.routing),
                ),
                SettingsNavTile(
                  icon: LucideIcons.rss,
                  title: 'Subscription settings',
                  subtitle: 'Auto-update and manage groups',
                  onTap: () => Get.toNamed(AppRoutes.subscriptions),
                ),
                SettingsNavTile(
                  icon: LucideIcons.gauge,
                  title: 'Speed test',
                  subtitle: 'Ping servers and live session speed',
                  onTap: () => Get.toNamed(AppRoutes.speedTest),
                ),
                SettingsNavTile(
                  icon: LucideIcons.languages,
                  title: 'Language',
                  subtitle: 'App locale',
                  onTap: () => Get.toNamed(AppRoutes.language),
                ),
                SettingsNavTile(
                  icon: LucideIcons.info,
                  title: 'About',
                  subtitle: 'Privacy policy and backup',
                  onTap: () => Get.toNamed(AppRoutes.about),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
