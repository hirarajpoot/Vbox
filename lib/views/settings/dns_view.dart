import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class DnsView extends StatefulWidget {
  const DnsView({super.key});

  @override
  State<DnsView> createState() => _DnsViewState();
}

class _DnsViewState extends State<DnsView> {
  late final TextEditingController _input;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController(
      text: Get.find<SettingsController>().settings.dnsServers.join('\n'),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await Get.find<SettingsController>().setDns(_input.text.split('\n'));
    Get.back();
    Get.snackbar('DNS saved', 'Applied on the next connect');
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'DNS settings',
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One resolver per line. Injected into the generated V2Ray config before connect.',
              style: AppText.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.card),
            Expanded(
              child: TextField(
                controller: _input,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(hintText: '1.1.1.1'),
              ),
            ),
            const SizedBox(height: AppSpacing.card),
            GradientButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
