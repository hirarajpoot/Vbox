import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/data/models/vpn_config.dart';

class ServerSelectorSheet extends StatelessWidget {
  const ServerSelectorSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet(
      const ServerSelectorSheet(),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(child: Text('Select server', style: AppText.title)),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.manualAdd);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final items = configs.configs;
                  if (items.isEmpty) {
                    return Center(
                      child: Text('No servers yet', style: AppText.caption),
                    );
                  }
                  return ListView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final config = items[index];
                      final selected = configs.selected?.id == config.id;
                      return _tile(configs, config, selected);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(ConfigController configs, VpnConfig config, bool selected) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () async {
          await configs.select(config);
          Get.back();
        },
        leading: Icon(
          selected ? LucideIcons.shieldCheck : LucideIcons.network,
          color: selected ? AppColors.mint : AppColors.primary,
        ),
        title: Text(config.remark, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${protocolLabel(config.protocol)} · ${formatPing(config.lastPing)}',
          style: AppText.caption,
        ),
        trailing: IconButton(
          onPressed: () {
            Get.back();
            Get.toNamed(AppRoutes.serverDetail, arguments: config.id);
          },
          icon: const Icon(LucideIcons.pencil, size: 18),
        ),
      ),
    );
  }
}
