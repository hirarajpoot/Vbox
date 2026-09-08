import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/settings_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/data/models/app_settings.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class RouteSettingsScreen extends StatelessWidget {
  const RouteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Route Settings',
      body: GetBuilder<SettingsController>(
        builder: (c) {
          final mode = c.settings.routeMode;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _ModeCard(
                title: 'Global',
                description: 'All traffic goes through the proxy server',
                selected: mode == RouteMode.global,
                onTap: () => c.setRouteMode(RouteMode.global),
              ),
              _ModeCard(
                title: 'Bypass Local/LAN',
                description: 'Only non-local traffic uses the proxy',
                selected: mode == RouteMode.bypassLan,
                onTap: () => c.setRouteMode(RouteMode.bypassLan),
              ),
              _ModeCard(
                title: 'Custom Rules',
                description: 'Define your own routing rules',
                selected: mode == RouteMode.custom,
                showChevron: true,
                onTap: () => c.setRouteMode(RouteMode.custom),
                onChevronTap: () {
                  c.setRouteMode(RouteMode.custom);
                  Get.to(() => const CustomRulesScreen());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

typedef RoutingView = RouteSettingsScreen;

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    this.showChevron = false,
    this.onChevronTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  final bool showChevron;
  final VoidCallback? onChevronTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.copper : AppColors.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _RadioDot(selected: selected),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showChevron)
                  IconButton(
                    onPressed: onChevronTap,
                    icon: const Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.copper : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.copper : AppColors.muted,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class CustomRulesScreen extends StatelessWidget {
  const CustomRulesScreen({super.key});

  static const _placeholders = [
    'geoip:private → direct',
    'geosite:cn → direct',
    'geosite:geolocation-!cn → proxy',
  ];

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Custom Rules',
      body: GetBuilder<SettingsController>(
        builder: (c) {
          final rules = c.settings.customBypassSubnets
              .where((s) => s.trim().isNotEmpty)
              .toList();
          final items = rules.isEmpty ? _placeholders : rules;
          final usingPlaceholders = rules.isEmpty;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: items.length + (usingPlaceholders ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (usingPlaceholders && index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Placeholder rules. Saved bypass subnets will appear here.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                );
              }
              final rule = items[usingPlaceholders ? index - 1 : index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.route, color: AppColors.copper, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
