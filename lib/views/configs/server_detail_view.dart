import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class ServerDetailView extends StatefulWidget {
  const ServerDetailView({super.key});

  @override
  State<ServerDetailView> createState() => _ServerDetailViewState();
}

class _ServerDetailViewState extends State<ServerDetailView> {
  late final TextEditingController _remark;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as String?;
    final config = id == null ? null : Get.find<ConfigController>().byId(id);
    _remark = TextEditingController(text: config?.remark ?? '');
  }

  @override
  void dispose() {
    _remark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String?;
    final configs = Get.find<ConfigController>();
    final config = id == null ? null : configs.byId(id);
    if (config == null) {
      return const SubPageScaffold(
        title: 'Server',
        body: Center(child: Text('Server not found')),
      );
    }

    return SubPageScaffold(
      title: 'Server detail',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(protocolLabel(config.protocol), style: AppText.caption.copyWith(color: AppColors.primarySoft)),
          const SizedBox(height: 8),
          TextField(
            controller: _remark,
            decoration: const InputDecoration(labelText: 'Remark'),
          ),
          const SizedBox(height: AppSpacing.section),
          Text('Share link', style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SelectableText(config.shareLink, style: AppText.caption.copyWith(height: 1.4)),
          const SizedBox(height: AppSpacing.section),
          Text('Last ping  ${formatPing(config.lastPing)}', style: AppText.caption),
          const SizedBox(height: AppSpacing.section),
          GradientButton(
            label: 'Save changes',
            onPressed: () async {
              await configs.renameConfig(config, _remark.text);
              Get.back();
              Get.snackbar('Saved', 'Server updated');
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => SharePlus.instance.share(ShareParams(text: config.shareLink)),
            icon: const Icon(LucideIcons.share2, size: 18),
            label: const Text('Share'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              await configs.deleteConfig(config);
              Get.back();
            },
            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
            label: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
