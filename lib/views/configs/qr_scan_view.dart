import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/parse_server_link.dart';
import 'package:vbox/shared/widgets/espresso_field.dart';
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
      backgroundColor: const Color(0xFF17110C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: EspressoFieldPainter(t: 0.18)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(
                          LucideIcons.chevronLeft,
                          color: AppColors.cream,
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NODE SCAN',
                              style: TextStyle(
                                color: AppColors.copperSoft,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Scan QR',
                              style: TextStyle(
                                color: AppColors.cream,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Point at a VMess, VLESS, Shadowsocks or Trojan code.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: _scanner,
                              onDetect: _onDetect,
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(
                                  color: AppColors.copper.withValues(alpha: 0.7),
                                  width: 1.6,
                                ),
                              ),
                            ),
                            const Center(
                              child: SizedBox(
                                width: 196,
                                height: 196,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(18),
                                    ),
                                    border: Border.fromBorderSide(
                                      BorderSide(
                                        color: AppColors.copper,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: _scanner,
                          builder: (context, state, _) {
                            final on = state.torchState == TorchState.on;
                            return _ScanAction(
                              icon: on
                                  ? LucideIcons.flashlightOff
                                  : LucideIcons.flashlight,
                              label: on ? 'Torch on' : 'Torch',
                              onTap: _scanner.toggleTorch,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ScanAction(
                          icon: LucideIcons.image,
                          label: 'Gallery',
                          onTap: _fromGallery,
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

class _ScanAction extends StatelessWidget {
  const _ScanAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xCC1A1612),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.copper, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
