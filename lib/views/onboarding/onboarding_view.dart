import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/shell/main_shell.dart';
import 'package:vbox/views/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

typedef OnboardingView = OnboardingScreen;

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  var _index = 0;

  static const _slides = [
    (
      icon: LucideIcons.shield,
      title: 'Your servers, your rules',
      body: 'Import VMess, Shadowsocks and V2Ray subscriptions. Nothing is pre-loaded.',
    ),
    (
      icon: LucideIcons.zap,
      title: 'Connect in one tap',
      body: 'Ping, smart connect and live traffic sit on Home — not a V2Box clone slider.',
    ),
    (
      icon: LucideIcons.slidersHorizontal,
      title: 'Tune the tunnel',
      body: 'DNS, routing, per-app proxy and backups stay one tap away in Settings.',
    ),
  ];

  Future<void> _goHome({required bool markDone}) async {
    if (markDone) {
      await Get.find<SettingsController>().completeOnboarding();
    }
    await Hive.box('appSettings').put('isFirstLaunch', false);
    Get.off(() => const MainNavWrapper());
  }

  Future<void> _onPrimary() async {
    if (_index >= _slides.length - 1) {
      await _goHome(markDone: true);
      return;
    }
    await _page.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _goHome(markDone: true),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 72,
                            color: AppColors.copper,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.copper : AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: last ? 'Get Started' : 'Next',
                onPressed: _onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
