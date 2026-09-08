import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SubscriptionInfoScreen extends StatelessWidget {
  const SubscriptionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return SubPageScaffold(
      title: 'Subscription info',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'VBox does not sell plans. You bring your own subscription URLs and servers.',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (configs.subscriptions.isEmpty) {
              return const Text(
                'No subscriptions added yet.',
                style: TextStyle(color: AppColors.muted),
              );
            }
            return Column(
              children: configs.subscriptions
                  .map(
                    (sub) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.crown, color: AppColors.copper),
                      title: Text(sub.name),
                      subtitle: Text(
                        sub.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
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
