import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/shared/widgets/section_card.dart';
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

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      filled: true,
      fillColor: const Color(0x6617100C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.copper.withValues(alpha: 0.75)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      kicker: 'FEED ADD',
      title: 'Add subscription',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Text(
            'Name the group, paste the subscription URL, then configs appear under Configs.',
            style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          SectionCard(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            child: Column(
              children: [
                TextField(
                  controller: _name,
                  style: const TextStyle(color: AppColors.cream),
                  decoration: _input('Name'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(color: AppColors.cream),
                  decoration: _input('Subscription URL'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PillButton(
            text: 'Fetch & save',
            isLoading: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
