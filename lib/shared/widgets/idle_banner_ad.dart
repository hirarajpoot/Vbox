import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:vbox/controllers/home_controller.dart';
import 'package:vbox/core/ads/ad_ids.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/data/services/ads_service.dart';

class IdleBannerAd extends StatelessWidget {
  const IdleBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();
    if (!Get.isRegistered<AdsService>() || !Get.isRegistered<HomeController>()) {
      return const SizedBox.shrink();
    }
    final ads = Get.find<AdsService>();
    final home = Get.find<HomeController>();
    return Obx(() {
      if (home.isConnected.value || home.isConnecting.value) {
        return const SizedBox.shrink();
      }
      if (ads.ready.value && !ads.bannerFailed.value) {
        return SizedBox(
          height: 50,
          width: double.infinity,
          child: UnityBannerAd(
            placementId: AdIds.banner,
            onFailed: (placementId, error, message) {
              ads.bannerFailed.value = true;
              ads.note.value = '$error $message'.trim();
              debugPrint('Unity banner skipped: $error $message');
            },
          ),
        );
      }
      if (!kDebugMode) return const SizedBox.shrink();
      return Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.copper.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.copper.withValues(alpha: 0.45)),
        ),
        child: const Text(
          'ADVERTISEMENT',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.copperSoft,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      );
    });
  }
}
