import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vbox/core/theme/app_colors.dart';

class EspressoField extends StatelessWidget {
  const EspressoField({super.key, required this.tick});

  final Animation<double> tick;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: tick,
        builder: (context, _) {
          return CustomPaint(
            painter: EspressoFieldPainter(t: tick.value),
          );
        },
      ),
    );
  }
}

class EspressoFieldPainter extends CustomPainter {
  EspressoFieldPainter({required this.t});

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
  bool shouldRepaint(covariant EspressoFieldPainter oldDelegate) =>
      oldDelegate.t != t;
}
