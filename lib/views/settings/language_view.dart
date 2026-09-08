import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const options = [
    ('auto', 'Auto (System Default)'),
    ('en', 'English'),
    ('ur', 'Urdu'),
  ];

  static String labelFor(String code) {
    return options
        .firstWhere(
          (item) => item.$1 == code,
          orElse: () => options.first,
        )
        .$2;
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Language',
      body: GetBuilder<SettingsController>(
        builder: (c) => ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
          children: options.map((item) {
            final selected = c.settings.languageCode == item.$1;
            return ListTile(
              title: Text(
                item.$2,
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: selected
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.copper,
                    )
                  : null,
              onTap: () async {
                await c.setLanguage(item.$1);
                Get.back();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

typedef LanguageView = LanguageScreen;
