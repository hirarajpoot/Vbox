import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';

Future<void> showServerSelectorSheet(BuildContext context) {
  final servers = Get.find<ServerController>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1A1612),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SELECT EXIT',
                    style: TextStyle(
                      color: AppColors.copperSoft,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final server = items[index];
                      final selected =
                          servers.selectedServerId.value == server.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              servers.selectServer(server.id);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: const Color(0xCC17110C),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.copper.withValues(alpha: 0.7)
                                      : AppColors.copper.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      server.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.cream,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    server.ping == null
                                        ? 'N/A'
                                        : '${server.ping}ms',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _pingColor(server.ping),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _RadioDot(selected: selected),
                                ],
                              ),
                            ),
                          ),
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
