import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/nav_controller.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/data/models/server_model.dart';
import 'package:vbox/views/configs/add_server_view.dart';
import 'package:vbox/views/configs/public_servers_view.dart';
import 'package:vbox/views/configs/qr_scan_view.dart';

class ConfigsScreen extends StatelessWidget {
  const ConfigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servers = Get.find<ServerController>();
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
            'Configs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Scan QR',
            onPressed: () => Get.to(() => const QrScanScreen()),
            icon: const Icon(Icons.qr_code_scanner),
            color: AppColors.copper,
          ),
          IconButton(
            tooltip: 'Add',
            onPressed: () => _openAddSheet(context),
            icon: const Icon(Icons.add),
            color: AppColors.copper,
          ),
          PopupMenuButton<ServerSort>(
            tooltip: 'Sort',
            color: AppColors.surfaceHigh,
            icon: const Icon(Icons.sort, color: AppColors.copper),
            onSelected: servers.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ServerSort.ping, child: Text('Sort by Ping')),
              PopupMenuItem(value: ServerSort.name, child: Text('Sort by Name')),
              PopupMenuItem(value: ServerSort.date, child: Text('Sort by Date')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (servers.servers.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.network, size: 80, color: AppColors.muted),
                  const SizedBox(height: 16),
                  const Text(
                    'No servers yet',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const PublicServersScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.copper,
                      foregroundColor: AppColors.bg,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('Browse latest public servers'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Get.to(() => const AddServerScreen()),
                    child: const Text(
                      'Or add your own',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final groups = servers.grouped.entries.toList();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final entry = groups[index];
            return Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true,
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                iconColor: AppColors.copper,
                collapsedIconColor: AppColors.muted,
                title: Text(
                  '${entry.key} (${entry.value.length})',
                  style: const TextStyle(
                    color: AppColors.copperSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: entry.value
                    .map((server) => _ServerCard(server: server))
                    .toList(),
              ),
            );
          },
        );
      }),
    );
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.slidersHorizontal, color: AppColors.copper),
                  title: const Text('Add Manually'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const AddServerScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.globe, color: AppColors.copper),
                  title: const Text('Latest public servers'),
                  subtitle: const Text(
                    'Try a few from the public list',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const PublicServersScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.link, color: AppColors.copper),
                  title: const Text('Import Link'),
                  onTap: () {
                    Navigator.pop(context);
                    _importLinkDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner, color: AppColors.copper),
                  title: const Text('Scan QR'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const QrScanScreen());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _importLinkDialog() async {
    final input = TextEditingController();
    final raw = await Get.dialog<String>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Import link'),
        content: TextField(
          controller: input,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'vmess://  ss://  vless://  trojan://',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: input.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    input.dispose();
    if (raw == null || raw.trim().isEmpty) return;
    try {
      await Get.find<ServerController>().importLink(raw);
      Get.snackbar('Imported', 'Link added to Configs');
    } catch (error) {
      Get.snackbar('Import failed', error.toString());
    }
  }
}

typedef ConfigsView = ConfigsScreen;

class _ServerCard extends StatelessWidget {
  const _ServerCard({required this.server});

  final ServerModel server;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerController>();
    return Obx(() {
      final selected = controller.selectedServerId.value == server.id;
      return GestureDetector(
        onTap: () async {
          final canPop = Navigator.of(context).canPop();
          await controller.selectServer(server.id);
          if (canPop) {
            Get.back();
          } else {
            Get.find<NavController>().go(0);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.copper : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.protocol(server.protocolKey),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      server.protocolName,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                server.ping == null ? 'N/A' : '${server.ping}ms',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _pingColor(server.ping),
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.surfaceHigh,
                icon: const Icon(LucideIcons.moreVertical, color: AppColors.muted, size: 18),
                onSelected: (value) => _onMenu(value, controller),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'ping', child: Text('Test Ping')),
                  PopupMenuItem(value: 'share', child: Text('Share')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _onMenu(String value, ServerController controller) async {
    if (value == 'edit') {
      Get.to(() => AddServerScreen(server: server));
    } else if (value == 'ping') {
      await controller.testPing(server);
    } else if (value == 'share') {
      await SharePlus.instance.share(ShareParams(text: server.connectLink));
    } else if (value == 'delete') {
      await controller.deleteServer(server.id);
    }
  }

  Color _pingColor(int? ping) {
    if (ping == null) return AppColors.muted;
    if (ping < 100) return AppColors.connected;
    if (ping <= 300) return AppColors.connecting;
    return AppColors.danger;
  }
}
