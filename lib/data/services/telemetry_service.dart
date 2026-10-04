import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TelemetryService {
  var ready = false;

  static TelemetryService get instance {
    if (Get.isRegistered<TelemetryService>()) {
      return Get.find<TelemetryService>();
    }
    return TelemetryService();
  }

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await Firebase.initializeApp();
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      ready = true;
      await event('vbox_open');
    } catch (error, stack) {
      debugPrint('Telemetry skipped: $error\n$stack');
    }
  }

  Future<void> event(String name, [Map<String, Object>? params]) async {
    if (!ready) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: params,
      );
    } catch (_) {}
  }

  Future<void> error(Object error, [StackTrace? stack]) async {
    if (!ready) return;
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack);
    } catch (_) {}
  }
}
