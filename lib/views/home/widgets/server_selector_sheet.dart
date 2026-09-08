import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';

Future<void> showServerSelectorSheet(BuildContext context) {
  final servers = Get.find<ServerController>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Server',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final items = servers.servers;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No servers yet',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final server = items[index];
                      final selected =
                          servers.selectedServerId.value == server.id;
                      return ListTile(
                        onTap: () {
                          servers.selectServer(server.id);
                          Navigator.pop(context);
                        },
                        title: Text(
                          server.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.cream,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              server.ping == null ? 'N/A' : '${server.ping}ms',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _pingColor(server.ping),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _RadioDot(selected: selected),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.copper : AppColors.muted,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.copper,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

Color _pingColor(int? ping) {
  if (ping == null) return AppColors.muted;
  if (ping < 100) return AppColors.connected;
  if (ping <= 300) return AppColors.connecting;
  return AppColors.danger;
}
