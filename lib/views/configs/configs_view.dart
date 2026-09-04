import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/data/models/subscription.dart';
import 'package:vbox/data/models/vpn_config.dart';
import 'package:vbox/views/widgets/ember_card.dart';
import 'package:vbox/views/widgets/gradient_button.dart';

class ConfigsView extends StatelessWidget {
  const ConfigsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfigController>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 8, 8, 0),
            child: Row(
              children: [
                Expanded(child: Text('Configs', style: AppText.heading)),
                Obx(
                  () => IconButton(
                    onPressed: controller.pinging.value
                        ? null
                        : () => controller.pingAll(),
                    icon: controller.pinging.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.gauge, size: 22),
                    color: AppColors.primarySoft,
                    tooltip: 'Ping all',
                  ),
                ),
                IconButton(
                  onPressed: () => _openAddSheet(context),
                  icon: const Icon(LucideIcons.plus, size: 22),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              12,
              AppSpacing.screen,
              8,
            ),
            child: TextField(
              onChanged: controller.query.call,
              decoration: const InputDecoration(
                hintText: 'Search remark or protocol',
                prefixIcon: Icon(LucideIcons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.configs.isEmpty) {
                return const _EmptyConfigs();
              }
              final groups = controller.grouped.entries.toList();
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  4,
                  AppSpacing.screen,
                  24,
                ),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final entry = groups[index];
                  final title = controller.subscriptionName(entry.key);
                  final sub = controller.subscriptions
                      .firstWhereOrNull((s) => s.id == entry.key);
                  return _GroupBlock(
                    title: title,
                    subscription: sub,
                    configs: entry.value,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    Get.bottomSheet(
      const _AddSheet(),
      isScrollControlled: true,
    );
  }
}

class _EmptyConfigs extends StatelessWidget {
  const _EmptyConfigs();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.network, size: 52, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('No configs yet', style: AppText.title),
            const SizedBox(height: 8),
            Text(
              'Add a subscription, paste a share link, or scan a QR.',
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.section),
            GradientButton(
              label: 'Add subscription',
              onPressed: () => Get.toNamed(AppRoutes.addSubscription),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSheet extends StatelessWidget {
  const _AddSheet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfigController>();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Add configs', style: AppText.title),
          ),
          const SizedBox(height: 8),
          _SheetTile(
            icon: LucideIcons.rss,
            title: 'Add subscription',
            subtitle: 'V2Ray / Xray subscription URL',
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.addSubscription);
            },
          ),
          _SheetTile(
            icon: LucideIcons.clipboard,
            title: 'Import from clipboard',
            subtitle: 'vmess://  ss://  vless://  trojan://',
            onTap: () async {
              Get.back();
              try {
                final added = await controller.importClipboard();
                Get.snackbar('Imported', '$added config(s) added');
              } catch (error) {
                Get.snackbar('Import failed', error.toString());
              }
            },
          ),
          _SheetTile(
            icon: LucideIcons.scanLine,
            title: 'Scan QR',
            subtitle: 'Subscription or share link',
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.qrScan);
            },
          ),
          _SheetTile(
            icon: LucideIcons.fileCode,
            title: 'Paste link or JSON',
            subtitle: 'Manual paste of share links / JSON',
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.importConfig);
            },
          ),
          _SheetTile(
            icon: LucideIcons.slidersHorizontal,
            title: 'Manual VMess / Shadowsocks',
            subtitle: 'Fill server fields yourself',
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.manualAdd);
            },
          ),
          _SheetTile(
            icon: LucideIcons.refreshCw,
            title: 'Update all subscriptions',
            subtitle: 'Refresh every saved URL',
            onTap: () async {
              Get.back();
              await controller.updateAllSubscriptions();
              Get.snackbar('Updated', 'Subscriptions refreshed');
            },
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppText.caption),
      ),
    );
  }
}

class _GroupBlock extends StatelessWidget {
  const _GroupBlock({
    required this.title,
    required this.configs,
    this.subscription,
  });

  final String title;
  final Subscription? subscription;
  final List<VpnConfig> configs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfigController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppText.caption.copyWith(
                    color: AppColors.primarySoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (subscription != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.refreshSubscription(subscription!),
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  color: AppColors.textSecondary,
                ),
              if (subscription != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.deleteSubscription(subscription!),
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  color: AppColors.danger,
                ),
            ],
          ),
          ...configs.map((config) => _ConfigTile(config: config)),
        ],
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({required this.config});

  final VpnConfig config;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfigController>();
    final selected = controller.selected?.id == config.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EmberCard(
        glow: selected,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => controller.select(config),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.protocol(config.protocol).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                protocolLabel(config.protocol),
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.protocol(config.protocol),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.remark,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(formatPing(config.lastPing), style: AppText.caption),
                ],
              ),
            ),
            IconButton(
              onPressed: () => controller.pingOne(config),
              icon: const Icon(LucideIcons.activity, size: 18),
              color: AppColors.textSecondary,
            ),
            PopupMenuButton<String>(
              color: AppColors.surfaceHigh,
              icon: const Icon(LucideIcons.moreVertical, color: AppColors.textSecondary),
              onSelected: (value) async {
                if (value == 'edit') {
                  Get.toNamed(AppRoutes.serverDetail, arguments: config.id);
                } else if (value == 'share') {
                  await SharePlus.instance.share(
                    ShareParams(text: config.shareLink),
                  );
                } else if (value == 'delete') {
                  await controller.deleteConfig(config);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'share', child: Text('Share')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
