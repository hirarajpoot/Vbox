import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:vbox/controllers/home_controller.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/core/ads/ad_ids.dart';
import 'package:vbox/core/ads/interstitial_policy.dart';
import 'package:vbox/data/services/telemetry_service.dart';

class AdsService extends GetxController {
  final ready = false.obs;
  final status = 'waiting'.obs;
  final note = ''.obs;
  final bannerFailed = false.obs;
  var interstitialPlacement = AdIds.interstitial;
  DateTime? _lastInterstitial;
  var _offering = false;
  var _started = false;

  static AdsService get instance {
    if (Get.isRegistered<AdsService>()) {
      return Get.find<AdsService>();
    }
    return AdsService();
  }

  Future<void> init() async {
    if (_started) return;
    if (kIsWeb || !GetPlatform.isAndroid) {
      status.value = 'skipped';
      note.value = 'Android only';
      return;
    }
    if (!AdIds.configured) {
      status.value = 'need_id';
      note.value = 'Unity Game ID required';
      return;
    }
    _started = true;
    status.value = 'starting';
    try {
      await UnityAds.init(
        gameId: AdIds.androidGameId.trim(),
        testMode: true,
        onComplete: () {
          ready.value = true;
          status.value = 'ready';
          note.value = 'Game ${AdIds.androidGameId}';
          unawaited(_loadInterstitial());
          unawaited(TelemetryService.instance.event('ad_ready'));
        },
        onFailed: (error, message) {
          ready.value = false;
          status.value = 'failed';
          note.value = '$error $message'.trim();
          debugPrint('Unity Ads init skipped: $error $message');
        },
      );
    } catch (error, stack) {
      ready.value = false;
      status.value = 'failed';
      note.value = error.toString();
      debugPrint('Unity Ads skipped: $error\n$stack');
    }
  }

  Future<void> onUserStoppedTunnel() => showInterstitial();

  Future<void> showInterstitial({bool force = false}) async {
    if (_offering) return;
    _offering = true;
    try {
      if (!force) {
        await Future<void>.delayed(InterstitialPolicy.afterStopDelay);
        if (!_canShowNow()) return;
      } else if (!_canForceNow()) {
        Get.snackbar('Ads', note.value.isEmpty ? status.value : note.value);
        return;
      }
      var shown = false;
      for (final placement in AdIds.interstitialIds) {
        interstitialPlacement = placement;
        final ok = await _showOne(placement);
        if (ok) {
          shown = true;
          break;
        }
      }
      if (force && !shown) {
        Get.snackbar(
          'Ads',
          ready.value
              ? 'No ad placement is available. Check the Unity Game ID.'
              : 'Ads are not ready: ${note.value}',
        );
      }
    } catch (error) {
      debugPrint('Unity interstitial skipped: $error');
      if (force) Get.snackbar('Ads', error.toString());
    } finally {
      _offering = false;
    }
  }

  Future<bool> _showOne(String placement) async {
    try {
      await UnityAds.load(placementId: placement);
      var failed = false;
      await UnityAds.showVideoAd(
        placementId: placement,
        onComplete: (_) => _afterInterstitial(),
        onSkipped: (_) => _afterInterstitial(),
        onFailed: (placementId, error, message) {
          failed = true;
          debugPrint('Unity interstitial failed: $error $message');
        },
      );
      return !failed;
    } catch (error) {
      debugPrint('Unity interstitial $placement skipped: $error');
      return false;
    }
  }

  bool _canForceNow() {
    if (!ready.value) return false;
    final vpn = Get.isRegistered<VpnController>()
        ? Get.find<VpnController>()
        : null;
    return vpn == null || (!vpn.isConnected && !vpn.isConnecting);
  }

  bool _canShowNow() {
    final vpn = Get.isRegistered<VpnController>()
        ? Get.find<VpnController>()
        : null;
    final home = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    return InterstitialPolicy.allow(
      ready: ready.value,
      userStopped: vpn?.stoppedByUser ?? true,
      connected: vpn?.isConnected ?? false,
      connecting: vpn?.isConnecting ?? false,
      session: home?.connectionDuration.value ?? Duration.zero,
      now: DateTime.now(),
      lastShown: _lastInterstitial,
    );
  }

  void _afterInterstitial() {
    _lastInterstitial = DateTime.now();
    unawaited(TelemetryService.instance.event('ad_interstitial'));
    unawaited(_loadInterstitial());
  }

  Future<void> _loadInterstitial() async {
    if (!ready.value) return;
    try {
      await UnityAds.load(placementId: interstitialPlacement);
    } catch (error) {
      debugPrint('Unity interstitial load skipped: $error');
    }
  }
}
