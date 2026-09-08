import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/parse_server_link.dart';
import 'package:vbox/views/configs/add_server_view.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

typedef QrScanView = QrScanScreen;

class _QrScanScreenState extends State<QrScanScreen> {
  final _scanner = MobileScannerController();
  var _handled = false;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _handleRaw(String? raw) async {
    if (_handled) return;
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return;
    _handled = true;
    await _scanner.stop();
    final lower = value.toLowerCase();
    final valid = lower.startsWith('vmess://') ||
        lower.startsWith('ss://') ||
        lower.startsWith('vless://') ||
        lower.startsWith('trojan://');
    if (!valid) {
      _handled = false;
      await _scanner.start();
      Get.snackbar('Invalid QR code', 'Need a vmess / ss / vless / trojan link');
      return;
    }
    final model = parseServerLink(value);
    if (model == null) {
      _handled = false;
      await _scanner.start();
      Get.snackbar('Invalid QR code', 'Could not parse this share link');
      return;
    }
    Get.off(() => AddServerScreen(server: model));
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
    await _handleRaw(value);
  }

  Future<void> _fromGallery() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null) return;
    try {
      final capture = await _scanner.analyzeImage(path);
      final value = capture?.barcodes
          .map((b) => b.rawValue)
          .whereType<String>()
          .firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
      if (value == null || value.isEmpty) {
        Get.snackbar('Invalid QR code', 'No QR found in this image');
        return;
      }
      await _handleRaw(value);
    } catch (error) {
      Get.snackbar('Scan failed', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _scanner, onDetect: _onDetect),
          const Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.copper, width: 3),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
                    ),
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _scanner,
                      builder: (context, state, _) {
                        final on = state.torchState == TorchState.on;
                        return IconButton(
                          onPressed: _scanner.toggleTorch,
                          icon: Icon(
                            on ? LucideIcons.flashlightOff : LucideIcons.flashlight,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _fromGallery,
                      child: const Text(
                        'Import from Gallery',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
