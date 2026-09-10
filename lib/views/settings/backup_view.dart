import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configs = Get.find<ConfigController>();
    return SubPageScaffold(
      kicker: 'VAULT',
      title: 'Backup',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const SectionCard(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              'Export all servers as a JSON file and share it. Import restores a backup on this device.',
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
          ),
          const SizedBox(height: 20),
          PillButton(
            text: 'Export backup',
            onPressed: () => _export(context),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
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
              borderRadius: BorderRadius.circular(100),
              child: Ink(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.copper.withValues(alpha: 0.45),
                  ),
                  color: const Color(0xCC1A1612),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.upload, size: 18, color: AppColors.copperSoft),
                    SizedBox(width: 8),
                    Text(
                      'Import backup',
                      style: TextStyle(
                        color: AppColors.cream,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
