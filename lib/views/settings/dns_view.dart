import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/custom_switch.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class DnsSettingsScreen extends StatefulWidget {
  const DnsSettingsScreen({super.key});

  @override
  State<DnsSettingsScreen> createState() => _DnsSettingsScreenState();
}

typedef DnsView = DnsSettingsScreen;

class _DnsSettingsScreenState extends State<DnsSettingsScreen> {
  late final TextEditingController _vpnDns;

  @override
  void initState() {
    super.initState();
    _vpnDns = TextEditingController(
      text: Get.find<SettingsController>().settings.vpnDns,
    );
  }

  @override
  void dispose() {
    _vpnDns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'DNS Settings',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          SectionCard(
            child: GetBuilder<SettingsController>(
              builder: (c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ToggleBlock(
                    title: 'Enable Local DNS',
                    description:
                        "DNS processed by core's DNS module (Recommended if need routing bypassing LAN and mainland address)",
                    value: c.settings.enableLocalDns,
                    onChanged: c.setEnableLocalDns,
                  ),
                  const Divider(color: AppColors.divider, height: 24, thickness: 1),
                  _ToggleBlock(
                    title: 'Enable Fake DNS',
                    description:
                        'Local DNS returns fake IP address (faster, but it may not work for some apps)',
                    value: c.settings.enableFakeDns,
                    onChanged: c.setEnableFakeDns,
                  ),
                  const Divider(color: AppColors.divider, height: 24, thickness: 1),
                  const Text(
                    'VPN DNS (only IPv4/v6)',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _vpnDns,
                    keyboardType: TextInputType.url,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: '1.1.1.1',
                      filled: true,
                      fillColor: AppColors.bgElevated,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.copper,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onChanged: c.setVpnDns,
                    onFieldSubmitted: c.setVpnDns,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleBlock extends StatelessWidget {
  const _ToggleBlock({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            CustomSwitch(value: value, onChanged: onChanged),
          ],
        ),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
