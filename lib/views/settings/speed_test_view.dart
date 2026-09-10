import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  var isTesting = false;
  var downloadSpeed = 0.0;
  var uploadSpeed = 0.0;
  var progress = 0.0;
  var _finished = false;
  var _phase = 'Idle';

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
      _phase = 'Download';
    });
    try {
      final down = await _measureDownload((p) {
        if (!mounted) return;
        setState(() => progress = p * 0.55);
      });
      if (!mounted) return;
      setState(() {
        downloadSpeed = down;
        _phase = 'Upload';
      });
      final up = await _measureUpload((p) {
        if (!mounted) return;
        setState(() => progress = 0.55 + p * 0.45);
      });
      if (!mounted) return;
      setState(() {
        uploadSpeed = up;
        progress = 1;
        isTesting = false;
        _finished = true;
        _phase = 'Done';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isTesting = false;
        _phase = 'Failed';
      });
      Get.snackbar('Speed test failed', error.toString());
    }
  }

  Future<double> _measureDownload(void Function(double) onProgress) async {
    final bytesWanted = kIsWeb ? 400000 : 2000000;
    final uri = kIsWeb
        ? Uri.parse('https://httpbin.org/bytes/$bytesWanted')
        : Uri.parse('https://speed.cloudflare.com/__down?bytes=$bytesWanted');
    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      final sw = Stopwatch()..start();
      final response = await client.send(request).timeout(
            const Duration(seconds: 25),
          );
      if (response.statusCode >= 400) {
        throw Exception('Download HTTP ${response.statusCode}');
      }
      var received = 0;
      await for (final chunk in response.stream) {
        received += chunk.length;
        onProgress((received / bytesWanted).clamp(0.0, 1.0));
      }
      sw.stop();
      final seconds = sw.elapsedMilliseconds / 1000.0;
      if (seconds <= 0 || received <= 0) return 0;
      return (received * 8) / seconds / 1e6;
    } finally {
      client.close();
    }
  }

  Future<double> _measureUpload(void Function(double) onProgress) async {
    final size = kIsWeb ? 200000 : 512000;
    final payload = Uint8List(size);
    final uri = kIsWeb
        ? Uri.parse('https://httpbin.org/post')
        : Uri.parse('https://speed.cloudflare.com/__up');
    onProgress(0.15);
    final sw = Stopwatch()..start();
    final response = await http
        .post(uri, body: payload)
        .timeout(const Duration(seconds: 25));
    sw.stop();
    onProgress(1);
    if (response.statusCode >= 400) {
      throw Exception('Upload HTTP ${response.statusCode}');
    }
    final seconds = sw.elapsedMilliseconds / 1000.0;
    if (seconds <= 0) return 0;
    return (size * 8) / seconds / 1e6;
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      kicker: 'LINE TEST',
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
              const SizedBox(height: 8),
              const Text(
                'Measures a real file transfer — not a random number.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: _ProgressRingPainter(progress: progress),
                  child: Center(
                    child: Text(
                      isTesting
                          ? _phase
                          : _finished
                              ? 'Done'
                              : 'Idle',
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
        color: const Color(0xCC1A1612),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.copper.withValues(alpha: 0.22)),
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
