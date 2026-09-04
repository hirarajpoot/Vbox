import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/share_links.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class QrScanView extends StatefulWidget {
  const QrScanView({super.key});

  @override
  State<QrScanView> createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  var _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
    if (value.isEmpty) return;
    _handled = true;
    try {
      final links = extractShareLinks(value);
      if (links.isEmpty && value.startsWith('http')) {
        await Get.find<ConfigController>().addSubscription(
          name: 'QR subscription',
          url: value,
        );
      } else {
        final added = await Get.find<ConfigController>().importLinks(
          links.isEmpty ? [value] : links,
        );
        if (added == 0) throw Exception('QR had no valid config');
      }
      Get.back();
      Get.snackbar('Imported', 'QR content added');
    } catch (error) {
      _handled = false;
      Get.snackbar('QR failed', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Scan QR',
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.bg.withValues(alpha: 0.72),
              child: Text(
                'Point at a V2Ray share link or subscription QR.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
