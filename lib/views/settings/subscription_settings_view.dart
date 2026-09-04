import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/app_toggle.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SubscriptionSettingsView extends StatelessWidget {
  const SubscriptionSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return SubPageScaffold(
      title: 'Subscriptions',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          GetBuilder<SettingsController>(
            builder: (c) => AppToggleRow(
              title: 'Auto-update',
              subtitle: 'Refresh groups when the app opens',
              value: c.settings.autoUpdateSubs,
              onChanged: c.toggleAutoUpdate,
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          GradientButton(
            label: 'Add subscription',
            onPressed: () => Get.toNamed(AppRoutes.addSubscription),
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Update all',
            onPressed: () => configs.updateAllSubscriptions(),
          ),
          const SizedBox(height: AppSpacing.section),
          Obx(() {
            if (configs.subscriptions.isEmpty) {
              return Text('No subscriptions yet', style: AppText.caption);
            }
            return Column(
              children: configs.subscriptions
                  .map(
                    (sub) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.rss, color: AppColors.primary),
                      title: Text(sub.name),
                      subtitle: Text(
                        sub.lastUpdated == null
                            ? sub.url
                            : 'Updated ${sub.lastUpdated}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption,
                      ),
                      trailing: IconButton(
                        onPressed: () => configs.deleteSubscription(sub),
                        icon: const Icon(LucideIcons.trash2, color: AppColors.danger, size: 18),
                      ),
                      onTap: () => configs.refreshSubscription(sub),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}
