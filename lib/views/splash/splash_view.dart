import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/onboarding/onboarding_view.dart';
import 'package:vbox/views/shell/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

typedef SplashView = SplashScreen;

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logo;
  late final AnimationController _dots;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _logo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _logo, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.68, end: 1).animate(
      CurvedAnimation(parent: _logo, curve: Curves.easeOutBack),
    );
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _logo.forward();
    Future<void>.delayed(const Duration(milliseconds: 1800), _leave);
  }

  Future<void> _leave() async {
    if (!mounted) return;
    final box = Hive.box('appSettings');
    final isFirstLaunch = box.get('isFirstLaunch', defaultValue: true) == true;
    if (isFirstLaunch) {
      await box.put('isFirstLaunch', false);
      if (!mounted) return;
      Get.offAll(() => const OnboardingScreen());
    } else {
      Get.offAll(() => const MainNavWrapper());
    }
  }

  @override
  void dispose() {
    _logo.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  children: [
                    const Icon(
                      LucideIcons.zap,
                      size: 100,
                      color: AppColors.copper,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'VBox',
                      style: TextStyle(
                        color: AppColors.cream,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: AnimatedBuilder(
                animation: _dots,
                builder: (context, _) => _PulsingDots(t: _dots.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends StatelessWidget {
  const _PulsingDots({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final wave = 0.5 + 0.5 * math.sin((t + i * 0.22) * math.pi * 2);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Opacity(
            opacity: 0.28 + 0.72 * wave,
            child: Transform.scale(
              scale: 0.75 + 0.35 * wave,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.copper,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
