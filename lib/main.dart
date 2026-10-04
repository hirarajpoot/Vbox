import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/app.dart';
import 'package:vbox/core/bindings/initial_binding.dart';
import 'package:vbox/data/local/storage_service.dart';
import 'package:vbox/data/services/ads_service.dart';
import 'package:vbox/data/services/telemetry_service.dart';
import 'package:vbox/data/services/v2ray_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  final v2ray = V2RayService();
  await Future.wait([
    storage.init(),
    v2ray.init(),
  ]);

  Get.put<StorageService>(storage, permanent: true);
  Get.put<V2RayService>(v2ray, permanent: true);

  final telemetry = TelemetryService();
  Get.put<TelemetryService>(telemetry, permanent: true);

  final ads = AdsService();
  Get.put<AdsService>(ads, permanent: true);

  InitialBinding().dependencies();
  runApp(const VBoxApp());
  unawaited(telemetry.init());
  unawaited(Future<void>.delayed(const Duration(seconds: 2), ads.init));
}
