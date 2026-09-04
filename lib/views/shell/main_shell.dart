import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/nav_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/theme/app_theme.dart';
import 'package:vbox/views/configs/configs_view.dart';
import 'package:vbox/views/home/home_view.dart';
import 'package:vbox/views/settings/settings_view.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavController>();
    const pages = [HomeScreen(), ConfigsView(), SettingsView()];

    return Scaffold(
      body: Obx(
        () => IndexedStack(index: nav.index.value, children: pages),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 12),
          child: Obx(() {
            final current = nav.index.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  _Tab(
                    icon: LucideIcons.zap,
                    label: 'Home',
                    selected: current == 0,
                    onTap: () => nav.go(0),
                  ),
                  _Tab(
                    icon: LucideIcons.network,
                    label: 'Configs',
                    selected: current == 1,
                    onTap: () => nav.go(1),
                  ),
                  _Tab(
                    icon: LucideIcons.settings,
                    label: 'Settings',
                    selected: current == 2,
                    onTap: () => nav.go(2),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primarySoft : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef MainNavWrapper = MainShell;

