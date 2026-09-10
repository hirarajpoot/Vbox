import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/espresso_field.dart';
import 'package:vbox/shared/widgets/row_tile.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/settings/about_view.dart';
import 'package:vbox/views/settings/dns_view.dart';
import 'package:vbox/views/settings/language_view.dart';
import 'package:vbox/views/settings/logs_view.dart';
import 'package:vbox/views/settings/routing_view.dart';
import 'package:vbox/views/settings/speed_test_view.dart';
import 'package:vbox/views/settings/subscription_info_view.dart';
import 'package:vbox/views/settings/subscription_settings_view.dart';
import 'package:vbox/views/settings/tunnel_settings_view.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final deviceId = settings.settings.deviceId ?? '—';
    return Scaffold(
      backgroundColor: const Color(0xFF17110C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: EspressoFieldPainter(t: 0.18)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Column(
                children: [
                  const _Header(),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        const ConsoleSectionLabel('DEVICE'),
                        SectionCard(
                          child: Column(
                            children: [
                              GetBuilder<SettingsController>(
                                builder: (c) => RowTile(
                                  icon: LucideIcons.languages,
                                  title: 'Language',
                                  trailingText: LanguageScreen.labelFor(
                                    c.settings.languageCode,
                                  ).replaceAll(' (System Default)', ''),
                                  onTap: () =>
                                      Get.to(() => const LanguageScreen()),
                                ),
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
                              RowTile(
                                icon: LucideIcons.smartphone,
                                title: 'Device ID',
                                trailingText: _truncateId(deviceId),
                                showChevron: false,
                                onTap: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: deviceId),
                                  );
                                  Get.rawSnackbar(message: 'Copied');
                                },
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
                              RowTile(
                                icon: LucideIcons.crown,
                                title: 'Subscription Info',
                                onTap: () => Get.to(
                                  () => const SubscriptionInfoScreen(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const ConsoleSectionLabel('GENERAL'),
                        SectionCard(
                          child: Column(
                            children: [
                              RowTile(
                                icon: LucideIcons.shield,
                                title: 'Tunnel Settings',
                                onTap: () => Get.to(
                                  () => const TunnelSettingsScreen(),
                                ),
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
                              RowTile(
                                icon: LucideIcons.globe,
                                title: 'DNS Settings',
                                onTap: () =>
                                    Get.to(() => const DnsSettingsScreen()),
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
                              RowTile(
                                icon: LucideIcons.router,
                                title: 'Route Settings',
                                onTap: () =>
                                    Get.to(() => const RouteSettingsScreen()),
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
                              RowTile(
                                icon: LucideIcons.rss,
                                title: 'Subscription Settings',
                                onTap: () => Get.to(
                                  () => const SubscriptionSettingsScreen(),
                                ),
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
                              RowTile(
                                icon: LucideIcons.gauge,
                                title: 'Speed Test',
                                onTap: () =>
                                    Get.to(() => const SpeedTestScreen()),
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
                              RowTile(
                                icon: LucideIcons.scrollText,
                                title: 'Connection log',
                                onTap: () => Get.to(() => const LogsView()),
                              ),
                              Divider(
                                color: AppColors.border.withValues(alpha: 0.7),
                                height: 1,
                                thickness: 1,
                              ),
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
                  ),
                ],
              ),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONTROL DECK',
              style: TextStyle(
                color: AppColors.copperSoft,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Settings',
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
