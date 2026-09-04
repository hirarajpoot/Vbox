import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/routes/app_pages.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/core/theme/app_theme.dart';

class VBoxApp extends StatelessWidget {
  const VBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0B0908),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final language = Get.find<SettingsController>().settings.languageCode;

    return GetMaterialApp(
      title: 'VBox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      defaultTransition: Transition.cupertino,
      locale: Locale(language),
      fallbackLocale: const Locale('en'),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
