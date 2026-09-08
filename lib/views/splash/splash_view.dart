import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

typedef SplashView = SplashScreen;

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _bar;
  Timer? _navTimer;
  var _leaving = false;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _bar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..forward();
    _navTimer = Timer(const Duration(milliseconds: 2400), _leave);
  }

  Future<void> _leave() async {
    if (!mounted || _leaving) return;
    _leaving = true;
    _navTimer?.cancel();
    _navTimer = null;
    _spin.stop();
    _bar.stop();

    final box = Hive.box('appSettings');
    final isFirstLaunch = box.get('isFirstLaunch', defaultValue: true) == true;
    if (isFirstLaunch) {
      await box.put('isFirstLaunch', false);
    }
    if (!mounted) return;

    final dest = isFirstLaunch ? AppRoutes.onboarding : AppRoutes.shell;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.offAllNamed(dest);
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _spin.stop();
    _bar.stop();
    _spin.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17110C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _spin,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SplashFieldPainter(t: _spin.value),
                );
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 4),
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _spin,
                    builder: (context, _) {
                      return CustomPaint(
                        size: const Size(176, 176),
                        painter: _VBoxEmblemPainter(turn: _spin.value),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'VBox',
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'SECURE TUNNEL  ·  YOUR SERVERS',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.2,
                  ),
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.fromLTRB(72, 0, 72, 48),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: AnimatedBuilder(
                          animation: _bar,
                          builder: (context, _) {
                            return LinearProgressIndicator(
                              value: Curves.easeInOut.transform(_bar.value),
                              minHeight: 3,
                              backgroundColor: AppColors.surfaceHigh,
                              color: AppColors.copper,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Preparing your tunnel',
                        style: TextStyle(
                          color: AppColors.muted.withValues(alpha: 0.9),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashFieldPainter extends CustomPainter {
  _SplashFieldPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C1C14),
            Color(0xFF17110C),
            Color(0xFF22150F),
          ],
          stops: [0, 0.5, 1],
        ).createShader(bounds),
    );

    final origin = Offset(size.width / 2, size.height * 0.38);
    _orb(
      canvas,
      origin,
      size.shortestSide * 0.72,
      [
        AppColors.copper.withValues(alpha: 0.42),
        AppColors.ember.withValues(alpha: 0.16),
        Colors.transparent,
      ],
    );

    final emberShift = math.sin(t * math.pi * 2) * size.height * 0.03;
    _orb(
      canvas,
      Offset(size.width * 0.06, size.height * 0.94 + emberShift),
      size.shortestSide * 0.55,
      [AppColors.ember.withValues(alpha: 0.38), Colors.transparent],
    );

    final goldShift = math.cos(t * math.pi * 2) * size.height * 0.025;
    _orb(
      canvas,
      Offset(size.width * 0.96, size.height * 0.08 + goldShift),
      size.shortestSide * 0.42,
      [AppColors.copperSoft.withValues(alpha: 0.28), Colors.transparent],
    );
    _orb(
      canvas,
      Offset(size.width * 0.16 + goldShift, size.height * 0.22),
      size.shortestSide * 0.28,
      [AppColors.copper.withValues(alpha: 0.16), Colors.transparent],
    );

    final grid = Paint()
      ..color = AppColors.copper.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    for (var i = 1; i <= 6; i++) {
      canvas.drawCircle(
        origin,
        56.0 * i,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 2 ? 1.4 : 1
          ..color = AppColors.copper.withValues(alpha: i == 2 ? 0.13 : 0.05),
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: size.shortestSide * 0.42),
      t * math.pi * 2,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.copperSoft.withValues(alpha: 0.22),
    );

    final rng = math.Random(7);
    final star = Paint()..color = AppColors.cream.withValues(alpha: 0.14);
    for (var i = 0; i < 28; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        i.isEven ? 1.4 : 0.9,
        star,
      );
    }

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Colors.transparent, Color(0x55120908)],
          stops: [0.52, 1],
        ).createShader(bounds),
    );
  }

  void _orb(Canvas canvas, Offset center, double radius, List<Color> colors) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(colors: colors).createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashFieldPainter oldDelegate) =>
      oldDelegate.t != t;
}

class _VBoxEmblemPainter extends CustomPainter {
  _VBoxEmblemPainter({required this.turn});

  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(
      center,
      radius * 0.92,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.copper.withValues(alpha: 0.28),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.92)),
    );

    final plate = RRect.fromRectAndRadius(
      Rect.fromCircle(center: center, radius: radius * 0.72),
      const Radius.circular(38),
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

    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.84);
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          AppColors.copper.withValues(alpha: 0),
          AppColors.copperSoft,
          AppColors.ember,
          AppColors.copper.withValues(alpha: 0),
        ],
        transform: GradientRotation(turn * math.pi * 2),
      ).createShader(ringRect);
    canvas.drawArc(ringRect, turn * math.pi * 2, math.pi * 1.15, false, sweep);

    final v = Path()
      ..moveTo(center.dx - 34, center.dy - 28)
      ..lineTo(center.dx - 16, center.dy - 28)
      ..lineTo(center.dx, center.dy + 22)
      ..lineTo(center.dx + 16, center.dy - 28)
      ..lineTo(center.dx + 34, center.dy - 28)
      ..lineTo(center.dx + 10, center.dy + 36)
      ..lineTo(center.dx - 10, center.dy + 36)
      ..close();

    canvas.drawPath(
      v,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.copperSoft, AppColors.copper, AppColors.ember],
        ).createShader(v.getBounds()),
    );
  }

  @override
  bool shouldRepaint(covariant _VBoxEmblemPainter oldDelegate) =>
      oldDelegate.turn != turn;
}
