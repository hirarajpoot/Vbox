import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/row_tile.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/settings/about_view.dart';
import 'package:vbox/views/settings/dns_view.dart';
import 'package:vbox/views/settings/language_view.dart';
import 'package:vbox/views/settings/routing_view.dart';
import 'package:vbox/views/settings/speed_test_view.dart';
import 'package:vbox/views/settings/subscription_info_view.dart';
import 'package:vbox/views/settings/logs_view.dart';
import 'package:vbox/views/settings/subscription_settings_view.dart';
import 'package:vbox/views/settings/tunnel_settings_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final deviceId = settings.settings.deviceId ?? '—';
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const _SectionHeader('DEVICE'),
          SectionCard(
            child: Column(
              children: [
                GetBuilder<SettingsController>(
                  builder: (c) => RowTile(
                    icon: LucideIcons.languages,
                    title: 'Language',
                    trailingText: LanguageScreen.labelFor(c.settings.languageCode)
                        .replaceAll(' (System Default)', ''),
                    onTap: () => Get.to(() => const LanguageScreen()),
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.smartphone,
                  title: 'Device ID',
                  trailingText: _truncateId(deviceId),
                  showChevron: false,
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: deviceId));
                    Get.rawSnackbar(message: 'Copied');
                  },
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.crown,
                  title: 'Subscription Info',
                  onTap: () => Get.to(() => const SubscriptionInfoScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('GENERAL'),
          SectionCard(
            child: Column(
              children: [
                RowTile(
                  icon: LucideIcons.shield,
                  title: 'Tunnel Settings',
                  onTap: () => Get.to(() => const TunnelSettingsScreen()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.globe,
                  title: 'DNS Settings',
                  onTap: () => Get.to(() => const DnsSettingsScreen()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.router,
                  title: 'Route Settings',
                  onTap: () => Get.to(() => const RouteSettingsScreen()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.rss,
                  title: 'Subscription Settings',
                  onTap: () => Get.to(() => const SubscriptionSettingsScreen()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.gauge,
                  title: 'Speed Test',
                  onTap: () => Get.to(() => const SpeedTestScreen()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.scrollText,
                  title: 'Connection log',
                  onTap: () => Get.to(() => const LogsView()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                RowTile(
                  icon: LucideIcons.info,
                  title: 'About',
                  onTap: () => Get.to(() => const AboutScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _truncateId(String id) {
    if (id.length < 16) return id;
    return '${id.substring(0, 8)}…${id.substring(id.length - 4)}';
  }
}

typedef SettingsView = SettingsScreen;

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          letterSpacing: 1,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
