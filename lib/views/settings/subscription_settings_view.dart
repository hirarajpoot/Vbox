import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/data/models/subscription.dart';
import 'package:vbox/shared/widgets/custom_switch.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SubscriptionSettingsScreen extends StatelessWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return SubPageScaffold(
      title: 'Subscription Settings',
      actions: [
        IconButton(
          onPressed: () => _showAddDialog(context),
          icon: const Icon(LucideIcons.plus),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SectionCard(
              child: GetBuilder<SettingsController>(
                builder: (c) => Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-update on launch',
                            style: TextStyle(
                              color: AppColors.cream,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Refresh every subscription when the app opens',
                            style: TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    CustomSwitch(
                      value: c.settings.autoUpdateSubs,
                      onChanged: c.toggleAutoUpdate,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
        final items = configs.subscriptions.toList();
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No subscriptions added',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 180,
                    child: GradientButton(
                      label: 'Add subscription',
                      onPressed: () => _showAddDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          itemCount: items.length,
          itemBuilder: (context, index) => _SubscriptionCard(
            subscription: items[index],
            refreshing: configs.refreshingId.value == items[index].id,
            onRefresh: () => _refresh(items[index]),
            onDelete: () => _confirmDelete(context, items[index]),
          ),
        );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh(SubscriptionModel sub) async {
    try {
      await Get.find<ConfigController>().refreshSubscription(sub);
      Get.snackbar('Updated', '${sub.name} refreshed');
    } catch (error) {
      Get.snackbar('Update failed', error.toString());
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SubscriptionModel sub,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete subscription?'),
        content: Text(
          'This removes ${sub.name} and all servers imported from it.',
          style: const TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Get.find<ConfigController>().deleteSubscription(sub);
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final name = TextEditingController();
    final url = TextEditingController();
    var busy = false;
    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Add subscription'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: AppColors.bgElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: url,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    filled: true,
                    fillColor: AppColors.bgElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Get.back(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () async {
                        if (url.text.trim().isEmpty) {
                          Get.snackbar('URL required', 'Paste a subscription URL');
                          return;
                        }
                        setState(() => busy = true);
                        try {
                          await Get.find<ConfigController>().addSubscription(
                            name: name.text,
                            url: url.text,
                          );
                          Get.back();
                          Get.snackbar('Added', 'Subscription imported');
                        } catch (error) {
                          setState(() => busy = false);
                          Get.snackbar('Failed', error.toString());
                        }
                      },
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.copper,
                        ),
                      )
                    : const Text('Add', style: TextStyle(color: AppColors.copper)),
              ),
            ],
          );
        },
      ),
    );
    name.dispose();
    url.dispose();
  }
}

typedef SubscriptionSettingsView = SubscriptionSettingsScreen;

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.subscription,
    required this.refreshing,
    required this.onRefresh,
    required this.onDelete,
  });

  final SubscriptionModel subscription;
  final bool refreshing;
  final VoidCallback onRefresh;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final updated = subscription.lastUpdated == null
        ? 'Never'
        : DateFormat('MMM d, HH:mm').format(subscription.lastUpdated!);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subscription.name,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subscription.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Last updated: $updated',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: refreshing ? null : onRefresh,
                icon: refreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.copper,
                        ),
                      )
                    : const Icon(LucideIcons.refreshCw, size: 18, color: AppColors.copper),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
