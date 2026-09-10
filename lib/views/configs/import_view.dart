import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class ImportView extends StatefulWidget {
  const ImportView({super.key});

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> {
  final _input = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final added = await Get.find<ConfigController>().importRaw(_input.text);
      if (added == 0) throw Exception('No valid links found');
      Get.back();
      Get.snackbar('Imported', '$added config(s) added');
    } catch (error) {
      Get.snackbar('Import failed', error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt', 'json', 'conf'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    _input.text = String.fromCharCodes(bytes);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      kicker: 'INTAKE',
      title: 'Import link',
      actions: [
        IconButton(
          onPressed: _fromFile,
          icon: const Icon(LucideIcons.paperclip, color: AppColors.muted),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Paste vmess://, ss://, vless://, trojan:// links or a raw V2Ray JSON config.',
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TextField(
                controller: _input,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: AppColors.cream, fontSize: 13),
                cursorColor: AppColors.copper,
                decoration: InputDecoration(
                  hintText: 'vmess://...\nss://...\n{ "inbounds": ... }',
                  hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xCC1A1612),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: AppColors.copper.withValues(alpha: 0.22),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: AppColors.copper.withValues(alpha: 0.22),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: AppColors.copper.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            PillButton(
              text: _busy ? 'Importing…' : 'Import',
              isLoading: _busy,
              onPressed: _import,
            ),
          ],
        ),
      ),
    );
  }
}
