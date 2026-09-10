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
      kicker: 'LOCALE',
      title: 'Language',
      body: GetBuilder<SettingsController>(
        builder: (c) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: options.map((item) {
            final selected = c.settings.languageCode == item.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await c.setLanguage(item.$1);
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xCC1A1612),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? AppColors.copper.withValues(alpha: 0.7)
                            : AppColors.copper.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.$2,
                            style: const TextStyle(
                              color: AppColors.cream,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _RadioDot(selected: selected),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.copper : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.copper : AppColors.muted,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

typedef LanguageView = LanguageScreen;
