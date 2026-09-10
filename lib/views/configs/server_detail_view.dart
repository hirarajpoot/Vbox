import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/shared/widgets/section_card.dart';
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
        kicker: 'NODE CARD',
        title: 'Server',
        body: Center(
          child: Text(
            'Server not found',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    return SubPageScaffold(
      kicker: 'NODE CARD',
      title: 'Server',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            protocolLabel(config.protocol),
            style: const TextStyle(
              color: AppColors.copperSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _remark,
                  style: const TextStyle(color: AppColors.cream),
                  decoration: InputDecoration(
                    labelText: 'Remark',
                    labelStyle: const TextStyle(color: AppColors.muted),
                    filled: true,
                    fillColor: const Color(0x6617100C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.copper.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share link',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  config.shareLink,
                  style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Last ping  ${formatPing(config.lastPing)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PillButton(
            text: 'Save changes',
            onPressed: () async {
              await configs.renameConfig(config, _remark.text);
              Get.back();
              Get.snackbar('Saved', 'Server updated');
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: config.shareLink),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.copperSoft,
              side: BorderSide(color: AppColors.copper.withValues(alpha: 0.45)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
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
            label: const Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
