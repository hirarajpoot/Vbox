import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SpeedTestView extends StatelessWidget {
  const SpeedTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    final vpn = Get.find<VpnController>();
    return SubPageScaffold(
      title: 'Speed test',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          children: [
            Obx(() {
              final s = vpn.status.value;
              return Column(
                children: [
                  Text(
                    vpn.isConnected ? 'Live session' : 'Ping your server list',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _stat('Down', formatSpeed(s.downloadSpeed), LucideIcons.arrowDown),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _stat('Up', formatSpeed(s.uploadSpeed), LucideIcons.arrowUp),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _stat(
                          'Ping',
                          formatPing(vpn.connectedPing.value),
                          LucideIcons.gauge,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSpacing.section),
            Obx(
              () => GradientButton(
                label: configs.pinging.value ? 'Pinging…' : 'Ping all servers',
                onPressed: configs.pinging.value ? null : configs.pingAll,
                busy: configs.pinging.value,
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            Expanded(
              child: Obx(() {
                final ranked = configs.configs.toList()
                  ..sort((a, b) {
                    final pa = a.lastPing ?? 99999;
                    final pb = b.lastPing ?? 99999;
                    return pa.compareTo(pb);
                  });
                if (ranked.isEmpty) {
                  return Center(child: Text('Add servers first', style: AppText.caption));
                }
                return ListView.separated(
                  itemCount: ranked.length,
                  separatorBuilder: (_, _) => const Divider(color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final config = ranked[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(config.remark, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        formatPing(config.lastPing),
                        style: AppText.body.copyWith(
                          color: (config.lastPing ?? -1) >= 0
                              ? AppColors.mint
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.primarySoft),
        const SizedBox(height: 6),
        Text(value, style: AppText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(label, style: AppText.caption),
      ],
    );
  }
}
