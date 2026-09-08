import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/home_controller.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

typedef SpeedTestView = SpeedTestScreen;

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with SingleTickerProviderStateMixin {
  var isTesting = false;
  var downloadSpeed = 0.0;
  var uploadSpeed = 0.0;
  var progress = 0.0;
  var _finished = false;

  late final AnimationController _anim;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() => progress = _anim.value);
      })
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        setState(() {
          isTesting = false;
          _finished = true;
          downloadSpeed = 18 + _random.nextDouble() * 72;
          uploadSpeed = 6 + _random.nextDouble() * 34;
        });
      });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  String get _phase {
    if (isTesting) return 'Testing...';
    if (_finished) return 'Done';
    return 'Idle';
  }

  String get _serverName {
    if (Get.isRegistered<HomeController>()) {
      final name = Get.find<HomeController>().selectedServer.value?.name;
      if (name != null && name.isNotEmpty) return name;
    }
    if (Get.isRegistered<ServerController>()) {
      final servers = Get.find<ServerController>();
      final selected = servers.servers.firstWhereOrNull(
        (s) => s.id == servers.selectedServerId.value,
      );
      if (selected != null) return selected.name;
    }
    return 'No server selected';
  }

  Future<void> _startTest() async {
    if (isTesting) return;
    setState(() {
      isTesting = true;
      _finished = false;
      progress = 0;
      downloadSpeed = 0;
      uploadSpeed = 0;
    });
    await _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Speed Test',
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _serverName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 180,
                height: 180,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ProgressRingPainter(progress: progress),
                      child: Center(
                        child: Text(
                          _phase,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _SpeedStat(
                      label: 'Download',
                      value: downloadSpeed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SpeedStat(
                      label: 'Upload',
                      value: uploadSpeed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PillButton(
                text: isTesting ? 'Testing...' : 'Start Test',
                isLoading: isTesting,
                onPressed: _startTest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedStat extends StatelessWidget {
  const _SpeedStat({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            '${value.toStringAsFixed(1)} Mbps',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 8;
    final track = Paint()
      ..color = AppColors.surfaceHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final arc = Paint()
      ..color = AppColors.copper
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, track);
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
