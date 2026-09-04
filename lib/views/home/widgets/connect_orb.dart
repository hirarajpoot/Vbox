import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/core/theme/app_colors.dart';

class ConnectOrb extends StatefulWidget {
  const ConnectOrb({
    super.key,
    required this.connected,
    required this.connecting,
    required this.onTap,
  });

  final bool connected;
  final bool connecting;
  final VoidCallback onTap;

  @override
  State<ConnectOrb> createState() => _ConnectOrbState();
}

class _ConnectOrbState extends State<ConnectOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _sync();
  }

  @override
  void didUpdateWidget(covariant ConnectOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.connecting || widget.connected) {
      _spin.repeat();
    } else {
      _spin.stop();
      _spin.reset();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.connected
        ? AppColors.mint
        : widget.connecting
            ? AppColors.connecting
            : AppColors.primary;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 196,
        height: 196,
        child: AnimatedBuilder(
          animation: _spin,
          builder: (context, _) {
            return CustomPaint(
              painter: _OrbPainter(
                progress: _spin.value,
                color: color,
                connected: widget.connected,
                connecting: widget.connecting,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: widget.connected
                          ? const [Color(0xFF1A2E22), Color(0xFF0B0908)]
                          : const [Color(0xFF3A2414), Color(0xFF1A1612)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.28),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.connected ? LucideIcons.shield : LucideIcons.zap,
                    size: 42,
                    color: widget.connected
                        ? AppColors.mint
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.progress,
    required this.color,
    required this.connected,
    required this.connecting,
  });

  final double progress;
  final Color color;
  final bool connected;
  final bool connecting;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final track = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final sweep =
        connecting ? 1.4 : (connected ? math.pi * 1.65 : math.pi * 0.7);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + progress * math.pi * 2,
      sweep,
      false,
      arc,
    );

    final inner = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 14, inner);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.connected != connected ||
      oldDelegate.connecting != connecting;
}
