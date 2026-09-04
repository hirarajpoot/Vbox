import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class LogsView extends StatelessWidget {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final format = DateFormat('MMM d  HH:mm:ss');
    return SubPageScaffold(
      title: 'Connection log',
      actions: [
        IconButton(
          onPressed: controller.clearLogs,
          icon: const Icon(LucideIcons.trash2),
        ),
      ],
      body: Obx(() {
        if (controller.logs.isEmpty) {
          return Center(
            child: Text('No events yet', style: AppText.body.copyWith(color: AppColors.textSecondary)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screen),
          itemCount: controller.logs.length,
          separatorBuilder: (_, _) => const Divider(color: AppColors.divider),
          itemBuilder: (context, index) {
            final entry = controller.logs[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(format.format(entry.at), style: AppText.caption),
                const SizedBox(height: 4),
                Text(entry.message, style: AppText.body),
              ],
            );
          },
        );
      }),
    );
  }
}
