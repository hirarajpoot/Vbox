import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/home_controller.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/formatters.dart';
import 'package:vbox/views/settings/routing_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'VBox',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Obx(
                      () => _Card(
                        onTap: () => _openServerSheet(context, home),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                home.selectedServer.value?.name ??
                                    'No server selected',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.cream,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevronRight,
                              color: AppColors.muted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => _Card(
                        child: Column(
                          children: [
                            _StatRow(
                              icon: LucideIcons.clock,
                              label: 'Duration',
                              value: _formatDuration(home.connectionDuration.value),
                            ),
                            const Divider(color: AppColors.divider, height: 20),
                            _StatRow(
                              icon: LucideIcons.arrowUp,
                              label: 'Upload',
                              value: home.uploadSpeed.value,
                            ),
                            const Divider(color: AppColors.divider, height: 20),
                            _StatRow(
                              icon: LucideIcons.arrowDown,
                              label: 'Download',
                              value: home.downloadSpeed.value,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => _Card(
                        child: Row(
                          children: [
                            const Icon(LucideIcons.sparkles, color: AppColors.copper, size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Smart Connect',
                                style: TextStyle(
                                  color: AppColors.cream,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Tooltip(
                              message: 'Ping every server, then join the fastest.',
                              triggerMode: TooltipTriggerMode.tap,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  LucideIcons.info,
                                  size: 16,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                            Switch(
                              value: home.smartConnect.value,
                              onChanged: home.toggleSmartConnect,
                              activeThumbColor: AppColors.copper,
                              activeTrackColor: AppColors.copper.withValues(alpha: 0.45),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Card(
                      onTap: () => Get.to(() => const RouteSettingsScreen()),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.router, color: AppColors.copper, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Routing',
                              style: TextStyle(
                                color: AppColors.cream,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            color: AppColors.muted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final connected = home.isConnected.value;
                final connecting = home.isConnecting.value;
                final status = connecting
                    ? 'Connecting to your tunnel…'
                    : connected
                        ? 'Traffic is flowing through the selected server'
                        : 'Not connected';
                return Column(
                  children: [
                    Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ConnectButton(home: home),
                    const SizedBox(height: 8),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openServerSheet(BuildContext context, HomeController home) async {
    final servers = Get.find<ServerController>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Obx(() {
            final items = servers.servers;
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'No servers yet. Add one from Configs.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final server = items[index];
                final selected = home.selectedServer.value?.id == server.id;
                return ListTile(
                  onTap: () async {
                    await home.selectServer(server);
                    if (context.mounted) Navigator.pop(context);
                  },
                  leading: Icon(
                    selected ? LucideIcons.shieldCheck : LucideIcons.network,
                    color: selected ? AppColors.connected : AppColors.copper,
                  ),
                  title: Text(server.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${protocolLabel(server.protocol)} · ${formatPing(server.ping)}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

typedef HomeView = HomeScreen;

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.home});

  final HomeController home;

  @override
  Widget build(BuildContext context) {
    final connected = home.isConnected.value;
    final connecting = home.isConnecting.value;
    final Color border;
    final Color fill;
    final String label;
    if (connecting) {
      border = AppColors.copper.withValues(alpha: 0.5);
      fill = AppColors.copper.withValues(alpha: 0.5);
      label = 'Connecting...';
    } else if (connected) {
      border = AppColors.connected;
      fill = AppColors.connected;
      label = 'Connected';
    } else {
      border = AppColors.copper;
      fill = Colors.transparent;
      label = 'Connect';
    }

    return GestureDetector(
      onTap: connecting
          ? null
          : () {
              if (home.selectedServer.value == null) {
                Get.snackbar('No server', 'Select a server first');
                return;
              }
              home.toggle();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 200,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: connected || connecting ? AppColors.bg : AppColors.copper,
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
    if (onTap == null) return body;
    return GestureDetector(onTap: onTap, child: body);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.copper),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.cream,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
