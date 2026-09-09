import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/custom_switch.dart';
import 'package:vbox/shared/widgets/section_card.dart';
import 'package:vbox/views/settings/per_app_view.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class TunnelSettingsScreen extends StatefulWidget {
  const TunnelSettingsScreen({super.key});

  @override
  State<TunnelSettingsScreen> createState() => _TunnelSettingsScreenState();
}

typedef TunnelSettingsView = TunnelSettingsScreen;

class _TunnelSettingsScreenState extends State<TunnelSettingsScreen> {
  late final TextEditingController _mtu;

  @override
  void initState() {
    super.initState();
    _mtu = TextEditingController(
      text: '${Get.find<SettingsController>().settings.mtuSize}',
    );
  }

  @override
  void dispose() {
    _mtu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Tunnel Settings',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          SectionCard(
            child: GetBuilder<SettingsController>(
              builder: (c) => Column(
                children: [
                  _ToggleBlock(
                    title: 'Per-app Proxy',
                    description: 'Choose which apps use the VPN tunnel',
                    value: c.settings.perAppProxy,
                    onChanged: c.setPerAppProxy,
                    onRowTap: () => Get.to(() => const PerAppProxyScreen()),
                  ),
                  const Divider(color: AppColors.divider, height: 24, thickness: 1),
                  _ToggleBlock(
                    title: 'Bypass LAN',
                    description: "Local network traffic won't go through VPN",
                    value: c.settings.bypassLan,
                    onChanged: c.toggleBypassLan,
                  ),
                  const Divider(color: AppColors.divider, height: 24, thickness: 1),
                  _ToggleBlock(
                    title: 'Auto Reconnect',
                    description: 'Automatically reconnect if connection drops',
                    value: c.settings.autoReconnect,
                    onChanged: c.setAutoReconnect,
                  ),
                  const Divider(color: AppColors.divider, height: 24, thickness: 1),
                  _ToggleBlock(
                    title: 'Auto Connect',
                    description: 'Start the tunnel when the app opens',
                    value: c.settings.autoConnect,
                    onChanged: c.toggleAutoConnect,
                  ),
                  const Divider(color: AppColors.divider, height: 24, thickness: 1),
                  _ToggleBlock(
                    title: 'Proxy only',
                    description: 'Skip system VPN — use local SOCKS/HTTP only',
                    value: c.settings.proxyOnly,
                    onChanged: c.toggleProxyOnly,
                  ),
                  const Divider(color: AppColors.divider, height: 24, thickness: 1),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'MTU Size',
                          style: TextStyle(
                            color: AppColors.cream,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 88,
                        child: TextFormField(
                          controller: _mtu,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: '1500',
                            isDense: true,
                            filled: true,
                            fillColor: AppColors.bgElevated,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
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
                          onChanged: c.setMtuSize,
                          onFieldSubmitted: c.setMtuSize,
                        ),
                      ),
                    ],
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
    this.onRowTap,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onRowTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRowTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
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
        ),
      ),
    );
  }
}
