import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/app_toggle.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

typedef RouteSettingsScreen = RoutingView;

class RoutingView extends StatefulWidget {
  const RoutingView({super.key});

  @override
  State<RoutingView> createState() => _RoutingViewState();
}

class _RoutingViewState extends State<RoutingView> {
  late final TextEditingController _subnets;

  @override
  void initState() {
    super.initState();
    _subnets = TextEditingController(
      text: Get.find<SettingsController>()
          .settings
          .customBypassSubnets
          .join('\n'),
    );
  }

  @override
  void dispose() {
    _subnets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Route settings',
      body: GetBuilder<SettingsController>(
        builder: (c) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            AppToggleRow(
              title: 'Bypass LAN',
              subtitle: 'Keep local network traffic off the tunnel',
              value: c.settings.bypassLan,
              onChanged: c.toggleBypassLan,
            ),
            const SizedBox(height: AppSpacing.section),
            Text('Custom bypass subnets', style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _subnets,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '10.0.0.0/8\n192.168.0.0/16',
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            GradientButton(
              label: 'Save',
              onPressed: () async {
                await c.setCustomSubnets(_subnets.text.split('\n'));
                Get.back();
                Get.snackbar('Routing saved', 'Applied on the next connect');
              },
            ),
          ],
        ),
      ),
    );
  }
}
