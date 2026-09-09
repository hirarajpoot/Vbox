import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vbox/controllers/nav_controller.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/data/models/server_model.dart';
import 'package:vbox/shared/widgets/espresso_field.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/views/configs/add_server_view.dart';
import 'package:vbox/views/configs/public_servers_view.dart';
import 'package:vbox/views/configs/qr_scan_view.dart';

class ConfigsScreen extends StatelessWidget {
  const ConfigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servers = Get.find<ServerController>();
    return Scaffold(
      backgroundColor: const Color(0xFF17110C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: EspressoFieldPainter(t: 0.18)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Obx(() {
                final empty = servers.servers.isEmpty;
                return Column(
                  children: [
                    _Header(count: servers.servers.length),
                    const SizedBox(height: 16),
                    _ActionRow(servers: servers),
                    const SizedBox(height: 14),
                    if (!empty) ...[
                      _SearchField(servers: servers),
                      const SizedBox(height: 14),
                    ],
                    Expanded(
                      child: empty
                          ? const _EmptyRack()
                          : _NodeList(servers: servers),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

typedef ConfigsView = ConfigsScreen;

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NODE RACK',
              style: TextStyle(
                color: AppColors.copperSoft,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Configs',
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
            color: AppColors.copper.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.copper.withValues(alpha: 0.45)),
          ),
          child: Text(
            '$count  ${count == 1 ? 'NODE' : 'NODES'}',
            style: const TextStyle(
              color: AppColors.copperSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.servers});

  final ServerController servers;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IconAction(
            icon: LucideIcons.activity,
            label: 'Ping',
            onTap: () async {
              if (servers.servers.isEmpty) return;
              await servers.testAllPings();
              Get.snackbar('Ping', 'Finished testing every node');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _IconAction(
            icon: LucideIcons.qrCode,
            label: 'QR',
            onTap: () => Get.to(() => const QrScanScreen()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _IconAction(
            icon: LucideIcons.plus,
            label: 'Add',
            onTap: () => _openAddSheet(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PopupMenuButton<ServerSort>(
            tooltip: 'Sort',
            color: const Color(0xFF241E18),
            onSelected: servers.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ServerSort.ping, child: Text('Sort by Ping')),
              PopupMenuItem(value: ServerSort.name, child: Text('Sort by Name')),
              PopupMenuItem(value: ServerSort.date, child: Text('Sort by Date')),
            ],
            child: const _IconAction(icon: LucideIcons.arrowUpDown, label: 'Sort'),
          ),
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1612),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.copper),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: body,
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.servers});

  final ServerController servers;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => servers.query.value = value,
      style: const TextStyle(color: AppColors.cream, fontSize: 14),
      cursorColor: AppColors.copper,
      decoration: InputDecoration(
        hintText: 'Search the rack',
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        prefixIcon: const Icon(LucideIcons.search, color: AppColors.muted, size: 18),
        filled: true,
        fillColor: const Color(0xCC1A1612),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.85)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.85)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.copper.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _EmptyRack extends StatelessWidget {
  const _EmptyRack();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 28, 18, 22),
          decoration: BoxDecoration(
            color: const Color(0xCC1A1612),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.copper.withValues(alpha: 0.28)),
          ),
          child: Column(
            children: [
              const Text(
                'RACK EMPTY',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No nodes yet',
                style: TextStyle(
                  color: AppColors.cream,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Import a link, scan a QR, or pull a few public hops.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 20),
              PillButton(
                text: 'Browse public nodes',
                onPressed: () => Get.to(() => const PublicServersScreen()),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.to(() => const AddServerScreen()),
                child: const Text(
                  'Add your own',
                  style: TextStyle(color: AppColors.copperSoft),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NodeList extends StatelessWidget {
  const _NodeList({required this.servers});

  final ServerController servers;

  @override
  Widget build(BuildContext context) {
    final groups = servers.grouped.entries.toList();
    if (groups.isEmpty) {
      return const Center(
        child: Text('No match', style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final entry = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                '${entry.key.toUpperCase()}  ·  ${entry.value.length}',
                style: const TextStyle(
                  color: AppColors.copperSoft,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            ...entry.value.map((server) => _NodeCard(server: server)),
          ],
        );
      },
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.server});

  final ServerModel server;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServerController>();
    return Obx(() {
      final selected = controller.selectedServerId.value == server.id;
      final pinging = controller.pingingIds.contains(server.id);
      final pingLabel = pinging
          ? '…'
          : server.ping == null
              ? '—'
              : '${server.ping}ms';
      final hint = [
        server.protocolName,
        if (server.network.isNotEmpty && server.protocol != ServerProtocol.shadowsocks)
          server.network.toUpperCase(),
      ].join('  ·  ');
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final canPop = Navigator.of(context).canPop();
              await controller.selectServer(server.id);
              if (canPop) {
                Get.back();
              } else {
                Get.find<NavController>().go(0);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
              decoration: BoxDecoration(
                color: const Color(0xCC1A1612),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.copper.withValues(alpha: 0.7)
                      : AppColors.border.withValues(alpha: 0.85),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.copper.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
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
                        if (selected)
                          const Text(
                            'ACTIVE EXIT',
                            style: TextStyle(
                              color: AppColors.copperSoft,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        Text(
                          server.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          hint,
                          style: const TextStyle(color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    pingLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: pinging ? AppColors.muted : _pingColor(server.ping),
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF241E18),
                    icon: const Icon(
                      LucideIcons.moreVertical,
                      color: AppColors.muted,
                      size: 18,
                    ),
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
}

void _openAddSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1612),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (context) {
      final maxHeight = MediaQuery.of(context).size.height * 0.72;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ADD TO RACK',
                style: TextStyle(
                  color: AppColors.copperSoft,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _SheetTile(
                icon: LucideIcons.slidersHorizontal,
                title: 'Add manually',
                hint: 'VMess, VLESS, Trojan, SS',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const AddServerScreen());
                },
              ),
              _SheetTile(
                icon: LucideIcons.globe,
                title: 'Public nodes',
                hint: 'Latest from the open list',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const PublicServersScreen());
                },
              ),
              _SheetTile(
                icon: LucideIcons.clipboardPaste,
                title: 'Clipboard',
                hint: 'Paste a share link',
                onTap: () async {
                  Navigator.pop(context);
                  await _importClipboard();
                },
              ),
              _SheetTile(
                icon: LucideIcons.link,
                title: 'Import link',
                hint: 'Type or paste vmess / vless / ss',
                onTap: () {
                  Navigator.pop(context);
                  _importLinkDialog();
                },
              ),
              _SheetTile(
                icon: LucideIcons.qrCode,
                title: 'Scan QR',
                hint: 'Camera or gallery',
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const QrScanScreen());
                },
              ),
            ],
            ),
          ),
        ),
      );
    },
  );
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.copper, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        hint,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: AppColors.muted, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _importLinkDialog() async {
  final input = TextEditingController();
  final raw = await Get.dialog<String>(
    AlertDialog(
      backgroundColor: const Color(0xFF1A1612),
      title: const Text('Import link'),
      content: TextField(
        controller: input,
        maxLines: 4,
        style: const TextStyle(color: AppColors.cream),
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

Future<void> _importClipboard() async {
  try {
    final count = await Get.find<ServerController>().importFromClipboard();
    Get.snackbar('Imported', '$count link(s) from clipboard');
  } catch (error) {
    Get.snackbar('Import failed', error.toString());
  }
}

Color _pingColor(int? ping) {
  if (ping == null) return AppColors.muted;
  if (ping < 100) return AppColors.connected;
  if (ping <= 300) return AppColors.connecting;
  return AppColors.danger;
}
