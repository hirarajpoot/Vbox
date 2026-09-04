import 'package:get/get.dart';
import 'package:vbox/core/routes/app_routes.dart';
import 'package:vbox/views/configs/add_subscription_view.dart';
import 'package:vbox/views/configs/import_view.dart';
import 'package:vbox/views/configs/manual_add_view.dart';
import 'package:vbox/views/configs/qr_scan_view.dart';
import 'package:vbox/views/configs/server_detail_view.dart';
import 'package:vbox/views/onboarding/onboarding_view.dart';
import 'package:vbox/views/settings/about_view.dart';
import 'package:vbox/views/settings/backup_view.dart';
import 'package:vbox/views/settings/dns_view.dart';
import 'package:vbox/views/settings/language_view.dart';
import 'package:vbox/views/settings/logs_view.dart';
import 'package:vbox/views/settings/per_app_view.dart';
import 'package:vbox/views/settings/privacy_view.dart';
import 'package:vbox/views/settings/routing_view.dart';
import 'package:vbox/views/settings/speed_test_view.dart';
import 'package:vbox/views/settings/subscription_settings_view.dart';
import 'package:vbox/views/settings/tunnel_settings_view.dart';
import 'package:vbox/views/shell/main_shell.dart';
import 'package:vbox/views/splash/splash_view.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: AppRoutes.shell, page: () => const MainShell()),
    GetPage(name: AppRoutes.addSubscription, page: () => const AddSubscriptionView()),
    GetPage(name: AppRoutes.importConfig, page: () => const ImportView()),
    GetPage(name: AppRoutes.qrScan, page: () => const QrScanView()),
    GetPage(name: AppRoutes.manualAdd, page: () => const ManualAddView()),
    GetPage(name: AppRoutes.serverDetail, page: () => const ServerDetailView()),
    GetPage(name: AppRoutes.tunnel, page: () => const TunnelSettingsView()),
    GetPage(name: AppRoutes.dns, page: () => const DnsView()),
    GetPage(name: AppRoutes.routing, page: () => const RoutingView()),
    GetPage(name: AppRoutes.perApp, page: () => const PerAppView()),
    GetPage(name: AppRoutes.subscriptions, page: () => const SubscriptionSettingsView()),
    GetPage(name: AppRoutes.speedTest, page: () => const SpeedTestView()),
    GetPage(name: AppRoutes.language, page: () => const LanguageView()),
    GetPage(name: AppRoutes.logs, page: () => const LogsView()),
    GetPage(name: AppRoutes.about, page: () => const AboutView()),
    GetPage(name: AppRoutes.privacy, page: () => const PrivacyView()),
    GetPage(name: AppRoutes.backup, page: () => const BackupView()),
  ];
}
