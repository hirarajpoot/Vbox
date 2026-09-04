import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
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
      title: 'Import link',
      actions: [
        IconButton(
          onPressed: _fromFile,
          icon: const Icon(LucideIcons.paperclip),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          children: [
            Text(
              'Paste vmess://, ss://, vless://, trojan:// links or a raw V2Ray JSON config.',
              style: AppText.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.card),
            Expanded(
              child: TextField(
                controller: _input,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'vmess://...\nss://...\n{ "inbounds": ... }',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.card),
            GradientButton(
              label: _busy ? 'Importing…' : 'Import',
              onPressed: _busy ? null : _import,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }
}
