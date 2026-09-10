import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/settings/backup_view.dart';
import 'package:vbox/views/settings/privacy_view.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

typedef AboutView = AboutScreen;

class _AboutScreenState extends State<AboutScreen> {
  static const _supportEmail = 'your-email@example.com';
  static const _storeUrl =
      'https://play.google.com/store/apps/details?id=com.vbox.vbox';

  var _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = '${info.version} (${info.buildNumber})');
    } catch (_) {}
  }

  Future<void> _openStore() async {
    final uri = Uri.parse(_storeUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      Get.snackbar('Unable to open store', _storeUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpn = Get.find<VpnController>();
    return SubPageScaffold(
      kicker: 'HOUSE MARK',
      title: 'About',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          SectionCard(
            child: Column(
              children: [
                Obx(
                  () => _ValueRow(
                    label: 'Core Version',
                    value: vpn.coreVersion.value,
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                _ValueRow(label: 'App Version', value: _appVersion),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                _LinkRow(label: 'Rate App', onTap: _openStore),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                _LinkRow(
                  label: 'Privacy Policy',
                  onTap: () => Get.to(() => const PrivacyPolicyScreen()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                _LinkRow(
                  label: 'Backup Configuration',
                  onTap: () => Get.to(() => const BackupScreen()),
                ),
                const Divider(color: AppColors.divider, height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Support Email: $_supportEmail',
                          style: TextStyle(
                            color: AppColors.cream,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            const ClipboardData(text: _supportEmail),
                          );
                          Get.rawSnackbar(message: 'Copied');
                        },
                        icon: const Icon(
                          LucideIcons.copy,
                          size: 18,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.copper,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
