import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/shared/widgets/espresso_field.dart';

class SubPageScaffold extends StatelessWidget {
  const SubPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.kicker,
    this.actions,
    this.bottom,
    this.espressoField = true,
  });

  final String title;
  final Widget body;
  final String? kicker;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool espressoField;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17110C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (espressoField)
            CustomPaint(painter: EspressoFieldPainter(t: 0.18)),
          Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 12, 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            LucideIcons.chevronLeft,
                            color: AppColors.muted,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (kicker != null) ...[
                                Text(
                                  kicker!,
                                  style: const TextStyle(
                                    color: AppColors.copperSoft,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.cream,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...?actions,
                      ],
                    ),
                  ),
                  ?bottom,
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _IconPlate(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.cream,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
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
    );
  }
}

class ConsoleSectionLabel extends StatelessWidget {
  const ConsoleSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.copperSoft,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _IconPlate extends StatelessWidget {
  const _IconPlate({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.copper.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.copper.withValues(alpha: 0.28)),
      ),
      child: Icon(icon, color: AppColors.copper, size: 18),
    );
  }
}
