import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return SubPageScaffold(
      title: 'Backup',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Export all servers as a JSON file and share it. Import restores a backup on this device.',
            style: AppText.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.section),
          GradientButton(
            label: 'Export backup',
            onPressed: () => _export(context),
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
                final map =
                    jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
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

  Future<void> _export(BuildContext context) async {
    final configs = Get.find<ConfigController>();
    final servers = Get.isRegistered<ServerController>()
        ? Get.find<ServerController>().servers
        : const [];
    final payload = {
      ...configs.exportBackup(),
      'servers': servers.map((s) => s.toMap()).toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(payload);
    try {
      final file = XFile.fromData(
        utf8.encode(json),
        mimeType: 'application/json',
        name: 'vbox-servers.json',
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          title: 'VBox backup',
          subject: 'VBox backup',
        ),
      );
    } catch (error) {
      await SharePlus.instance.share(
        ShareParams(text: json, title: 'VBox backup'),
      );
    }
  }
}

typedef BackupView = BackupScreen;
