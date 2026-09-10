import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SubscriptionInfoScreen extends StatelessWidget {
  const SubscriptionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return SubPageScaffold(
      kicker: 'PLAN BAY',
      title: 'Subscription',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const SectionCard(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              'VBox does not sell plans. You bring your own subscription URLs and servers.',
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          const ConsoleSectionLabel('FEEDS'),
          Obx(() {
            if (configs.subscriptions.isEmpty) {
              return const SectionCard(
                padding: EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Text(
                  'No subscriptions added yet.',
                  style: TextStyle(color: AppColors.muted),
                ),
              );
            }
            return Column(
              children: configs.subscriptions
                  .map(
                    (sub) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SectionCard(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.copper.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.copper.withValues(alpha: 0.28),
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.rss,
                                color: AppColors.copper,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sub.name,
                                    style: const TextStyle(
                                      color: AppColors.cream,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    sub.url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
