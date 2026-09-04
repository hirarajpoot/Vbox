import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/app.dart';
import 'package:vbox/core/bindings/initial_binding.dart';
import 'package:vbox/data/local/storage_service.dart';
import 'package:vbox/data/services/v2ray_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();
  Get.put<StorageService>(storage, permanent: true);

  final v2ray = V2RayService();
  await v2ray.init();
  Get.put<V2RayService>(v2ray, permanent: true);

  InitialBinding().dependencies();
  runApp(const VBoxApp());
}
