import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final vpn = Get.find<VpnController>();
    return SubPageScaffold(
      title: 'About',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text('VBox', style: AppText.heading),
          const SizedBox(height: 8),
          Text(
            'A Flutter VPN / proxy client with V2Box-level workflows — subscriptions, QR, clipboard import, ping, smart connect — in a purple charcoal interface.',
            style: AppText.body.copyWith(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.section),
          Obx(() => _row('Xray core', vpn.coreVersion.value)),
          _row('Engine', 'flutter_v2ray'),
          _row('State', 'GetX'),
          _row('Storage', 'Hive'),
          _row('Platform', 'Android first · iOS later'),
          const SizedBox(height: AppSpacing.section),
          SettingsNavTile(
            icon: LucideIcons.shield,
            title: 'Privacy policy',
            subtitle: 'What stays on this device',
            onTap: () => Get.toNamed(AppRoutes.privacy),
          ),
          SettingsNavTile(
            icon: LucideIcons.databaseBackup,
            title: 'Backup configuration',
            subtitle: 'Export or restore JSON backup',
            onTap: () => Get.toNamed(AppRoutes.backup),
          ),
          const SizedBox(height: AppSpacing.section),
          Text(
            'No accounts. Configs stay on this device. You bring your own VMess / Shadowsocks / V2Ray servers.',
            style: AppText.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: AppText.caption),
          const Spacer(),
          Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
