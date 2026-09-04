import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class AddSubscriptionView extends StatefulWidget {
  const AddSubscriptionView({super.key});

  @override
  State<AddSubscriptionView> createState() => _AddSubscriptionViewState();
}

class _AddSubscriptionViewState extends State<AddSubscriptionView> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_url.text.trim().isEmpty) {
      Get.snackbar('URL required', 'Paste a V2Ray / Xray subscription link');
      return;
    }
    setState(() => _busy = true);
    try {
      await Get.find<ConfigController>().addSubscription(
        name: _name.text,
        url: _url.text,
      );
      Get.back();
      Get.snackbar('Added', 'Subscription imported');
    } catch (error) {
      Get.snackbar('Failed', error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Add subscription',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(
            'Name the group, paste the subscription URL, then configs appear under Configs.',
            style: AppText.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.section),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Subscription URL'),
          ),
          const SizedBox(height: AppSpacing.section),
          GradientButton(
            label: 'Fetch & save',
            onPressed: _busy ? null : _save,
            busy: _busy,
          ),
        ],
      ),
    );
  }
}
