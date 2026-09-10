import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/nav_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/views/configs/configs_view.dart';
import 'package:vbox/views/home/home_view.dart';
import 'package:vbox/views/settings/settings_view.dart';

class MainNavWrapper extends StatefulWidget {
  const MainNavWrapper({super.key});

  @override
  State<MainNavWrapper> createState() => _MainNavWrapperState();
}

class _MainNavWrapperState extends State<MainNavWrapper> {
  static const _pages = [HomeScreen(), ConfigsScreen(), SettingsScreen()];

  var _index = 0;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<NavController>()) {
      _index = Get.find<NavController>().index.value;
    }
  }

  void _go(int index) {
    setState(() => _index = index);
    if (Get.isRegistered<NavController>()) {
      Get.find<NavController>().go(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17110C),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF21A1612),
          border: Border(
            top: BorderSide(color: AppColors.copper.withValues(alpha: 0.22)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _go,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.copperSoft,
          unselectedItemColor: AppColors.muted,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.zap),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.network),
              label: 'Configs',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
