import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class LogsView extends StatelessWidget {
  const LogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final format = DateFormat('MMM d  HH:mm:ss');
    return SubPageScaffold(
      kicker: 'EVENT TAPE',
      title: 'Connection log',
      actions: [
        IconButton(
          onPressed: controller.clearLogs,
          icon: const Icon(LucideIcons.trash2, color: AppColors.muted),
        ),
      ],
      body: Obx(() {
        if (controller.logs.isEmpty) {
          return const Center(
            child: Text(
              'No events yet',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          itemCount: controller.logs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = controller.logs[index];
            return Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xCC1A1612),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.copper.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format.format(entry.at),
                    style: const TextStyle(
                      color: AppColors.copperSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.message,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
