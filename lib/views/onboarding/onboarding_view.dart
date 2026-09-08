import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/espresso_field.dart';
import 'package:vbox/shared/widgets/pill_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

typedef OnboardingView = OnboardingScreen;

class _Slide {
  const _Slide({
    required this.kicker,
    required this.title,
    required this.body,
    required this.icon,
    required this.chips,
  });

  final String kicker;
  final String title;
  final String body;
  final IconData icon;
  final List<String> chips;
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _page = PageController();
  late final AnimationController _field;
  var _index = 0;
  var _leaving = false;

  static const _slides = [
    _Slide(
      kicker: 'YOUR CONFIGS',
      title: 'Your servers,\nyour rules',
      body:
          'Import VMess, Shadowsocks, VLESS or Trojan. VBox starts empty — you choose every hop.',
      icon: LucideIcons.shield,
      chips: ['VMess', 'VLESS', 'SS', 'Trojan'],
    ),
    _Slide(
      kicker: 'ONE TAP',
      title: 'Connect in\none motion',
      body:
          'Smart Connect, live ping and traffic sit on Home. No cloned sliders — just the tunnel.',
      icon: LucideIcons.zap,
      chips: ['Ping', 'Smart Connect', 'Live stats'],
    ),
    _Slide(
      kicker: 'FINE CONTROL',
      title: 'Tune the\ntunnel',
      body:
          'DNS, routing, per-app proxy and backups stay one tap away in Settings.',
      icon: LucideIcons.slidersHorizontal,
      chips: ['DNS', 'Route', 'Per-app'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _field = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  Future<void> _goHome({required bool markDone}) async {
    if (!mounted || _leaving) return;
    _leaving = true;
    _field.stop();
    if (markDone) {
      await Get.find<SettingsController>().completeOnboarding();
    }
    await Hive.box('appSettings').put('isFirstLaunch', false);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.shell);
    });
  }

  Future<void> _onPrimary() async {
    if (_index >= _slides.length - 1) {
      await _goHome(markDone: true);
      return;
    }
    await _page.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _field.stop();
    _field.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _slides.length - 1;
    return Scaffold(
      backgroundColor: const Color(0xFF17110C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          EspressoField(tick: _field),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'VBox',
                        style: TextStyle(
                          color: AppColors.cream.withValues(alpha: 0.92),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '0${_index + 1}  /  0${_slides.length}',
                        style: const TextStyle(
                          color: AppColors.copperSoft,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _goHome(markDone: true),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _page,
                      itemCount: _slides.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) {
                        return _OnboardPage(
                          slide: _slides[i],
                          tick: _field,
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.copper
                              : AppColors.border.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: AppColors.copper.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  PillButton(
                    text: last ? 'Enter VBox' : 'Continue',
                    onPressed: _onPrimary,
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

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.slide, required this.tick});

  final _Slide slide;
  final Animation<double> tick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const Spacer(flex: 3),
          SizedBox(
            width: 196,
            height: 196,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: tick,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size(196, 196),
                      painter: _OnboardEmblemPainter(turn: tick.value),
                    );
                  },
                ),
                Icon(slide.icon, size: 52, color: AppColors.copperSoft),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final chip in slide.chips) _Chip(label: chip),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            slide.kicker,
            style: const TextStyle(
              color: AppColors.copperSoft,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1.12,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1612),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.copper.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.cream,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _OnboardEmblemPainter extends CustomPainter {
  _OnboardEmblemPainter({required this.turn});

  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius * 0.94,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.copper.withValues(alpha: 0.26),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.94)),
    );

    for (var i = 3; i >= 1; i--) {
      canvas.drawCircle(
        center,
        radius * (0.58 + i * 0.12),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = AppColors.copper.withValues(alpha: 0.08 + i * 0.02),
      );
    }

    final plate = RRect.fromRectAndRadius(
      Rect.fromCircle(center: center, radius: radius * 0.58),
      const Radius.circular(36),
    );
    canvas.drawRRect(
      plate,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A211A), Color(0xFF14110E)],
        ).createShader(plate.outerRect),
    );
    canvas.drawRRect(
      plate,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.copper.withValues(alpha: 0.55),
    );

    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.72);
    canvas.drawArc(
      ringRect,
      turn * math.pi * 2,
      math.pi * 1.15,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [
            AppColors.copper.withValues(alpha: 0),
            AppColors.copperSoft,
            AppColors.ember,
            AppColors.copper.withValues(alpha: 0),
          ],
          transform: GradientRotation(turn * math.pi * 2),
        ).createShader(ringRect),
    );

  }

  @override
  bool shouldRepaint(covariant _OnboardEmblemPainter oldDelegate) =>
      oldDelegate.turn != turn;
}
