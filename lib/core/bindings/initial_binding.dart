import 'package:get/get.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/controllers/home_controller.dart';
import 'package:vbox/controllers/nav_controller.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/controllers/vpn_controller.dart';
import 'package:vbox/data/local/storage_service.dart';
import 'package:vbox/data/services/subscription_service.dart';
import 'package:vbox/data/services/v2ray_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = Get.find<StorageService>();
    final v2ray = Get.find<V2RayService>();
    final settings = SettingsController(storage);
    final configs = ConfigController(
      storage,
      SubscriptionService(),
      v2ray,
      settings,
    );

    Get.put<SettingsController>(settings, permanent: true);
    Get.put<ConfigController>(configs, permanent: true);
    Get.put<VpnController>(
      VpnController(v2ray, configs, settings),
      permanent: true,
    );
    Get.put<ServerController>(
      ServerController(storage, configs, settings),
      permanent: true,
    );
    Get.put<HomeController>(
      HomeController(
        Get.find<VpnController>(),
        Get.find<ServerController>(),
        settings,
      ),
      permanent: true,
    );
    Get.put<NavController>(NavController(), permanent: true);
  }
}
