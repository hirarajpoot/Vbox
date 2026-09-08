import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/home_controller.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/shared/widgets/custom_switch.dart';
import 'package:vbox/shared/widgets/espresso_field.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/views/home/widgets/server_selector_sheet.dart';
import 'package:vbox/views/settings/routing_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: const Color(0xFF17110C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _StaticField()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Column(
                children: [
                  _Header(home: home),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        _SessionHero(home: home),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _ExitNodeTile(home: home)),
                            const SizedBox(width: 10),
                            const Expanded(child: _PathTile()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _SmartStrip(home: home),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef HomeView = HomeScreen;

class _StaticField extends CustomPainter {
  const _StaticField();

  @override
  void paint(Canvas canvas, Size size) {
    EspressoFieldPainter(t: 0.18).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Header extends StatelessWidget {
  const _Header({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = home.isConnected.value;
      final connecting = home.isConnecting.value;
      final label = connecting
          ? 'LINKING'
          : connected
              ? 'LIVE'
              : 'IDLE';
      final color = connecting
          ? AppColors.connecting
          : connected
              ? AppColors.connected
              : AppColors.muted;
      return Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TUNNEL CONSOLE',
                style: TextStyle(
                  color: AppColors.copperSoft,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'VBox',
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  height: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SessionHero extends StatelessWidget {
  const _SessionHero({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connected = home.isConnected.value;
      final connecting = home.isConnecting.value;
      final caption = connecting
          ? 'Opening the hop…'
          : connected
              ? 'Traffic is on the selected node'
              : 'Select a node, then start the tunnel';
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        decoration: BoxDecoration(
          color: const Color(0xCC1A1612),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.copper.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.copper.withValues(alpha: connected ? 0.16 : 0.06),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'SESSION',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(home.connectionDuration.value),
              style: const TextStyle(
                color: AppColors.cream,
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                height: 1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _Meter(
                    icon: LucideIcons.arrowUpRight,
                    label: 'UP',
                    value: home.uploadSpeed.value,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Meter(
                    icon: LucideIcons.arrowDownRight,
                    label: 'DOWN',
                    value: home.downloadSpeed.value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (connected)
              _StopBar(onTap: home.toggle)
            else
              PillButton(
                text: connecting ? 'Linking…' : 'Start tunnel',
                onPressed: connecting
                    ? () {}
                    : () {
                        if (home.selectedServer.value == null) {
                          Get.snackbar('No server', 'Select a server first');
                          return;
                        }
                        home.toggle();
                      },
                isLoading: connecting,
              ),
          ],
        ),
      );
    });
  }
}

class _Meter extends StatelessWidget {
  const _Meter({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.copperSoft),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StopBar extends StatelessWidget {
  const _StopBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.ember.withValues(alpha: 0.7)),
            color: AppColors.ember.withValues(alpha: 0.12),
          ),
          child: const Text(
            'Stop tunnel',
            style: TextStyle(
              color: AppColors.copperSoft,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExitNodeTile extends StatelessWidget {
  const _ExitNodeTile({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final server = home.selectedServer.value;
      return _ConsoleTile(
        kicker: 'EXIT NODE',
        title: server?.name ?? 'No node',
        hint: server == null ? 'Tap to choose' : server.protocolName,
        icon: LucideIcons.server,
        onTap: () => showServerSelectorSheet(context),
      );
    });
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      builder: (settings) {
        final mode = settings.settings.routeMode;
        final label = switch (mode) {
          RouteMode.bypassLan => 'Bypass LAN',
          RouteMode.custom => 'Custom',
          _ => 'Global',
        };
        return _ConsoleTile(
          kicker: 'PATH',
          title: label,
          hint: 'Routing',
          icon: LucideIcons.gitBranch,
          onTap: () => Get.to(() => const RouteSettingsScreen()),
        );
      },
    );
  }
}

class _ConsoleTile extends StatelessWidget {
  const _ConsoleTile({
    required this.kicker,
    required this.title,
    required this.hint,
    required this.icon,
    required this.onTap,
  });

  final String kicker;
  final String title;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xCC1A1612),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppColors.copper),
              const SizedBox(height: 12),
              Text(
                kicker,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartStrip extends StatelessWidget {
  const _SmartStrip({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.gauge, size: 18, color: AppColors.copper),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fastest hop',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Ping all nodes, then join the best',
                    style: TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            CustomSwitch(
              value: home.smartConnect.value,
              onChanged: home.toggleSmartConnect,
            ),
          ],
        ),
      );
    });
  }
}

String _formatDuration(Duration d) {
  two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
}
