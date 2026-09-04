import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  static const _languages = [
    ('en', 'English'),
    ('ur', 'اردو'),
    ('ar', 'العربية'),
    ('zh', '中文'),
    ('fa', 'فارسی'),
  ];

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Language',
      body: GetBuilder<SettingsController>(
        builder: (c) => ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: _languages.map((item) {
            final selected = c.settings.languageCode == item.$1;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.$2, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
              trailing: Icon(
                selected ? LucideIcons.check : LucideIcons.circle,
                color: selected ? AppColors.mint : AppColors.divider,
                size: 20,
              ),
              onTap: () => c.setLanguage(item.$1),
            );
          }).toList(),
        ),
      ),
    );
  }
}
