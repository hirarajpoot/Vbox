import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class BackupView extends StatelessWidget {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return SubPageScaffold(
      title: 'Backup',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Export configs, subscriptions and settings as a JSON file. Import restores them on this device.',
            style: AppText.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.section),
          GradientButton(
            label: 'Export backup',
            onPressed: () async {
              final json = const JsonEncoder.withIndent('  ').convert(configs.exportBackup());
              await SharePlus.instance.share(ShareParams(text: json, title: 'VBox backup'));
            },
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Import backup',
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: const ['json', 'txt'],
                withData: true,
              );
              final bytes = result?.files.single.bytes;
              if (bytes == null) return;
              try {
                final map = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
                await configs.importBackup(map);
                Get.snackbar('Restored', 'Backup imported');
              } catch (error) {
                Get.snackbar('Import failed', error.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}
