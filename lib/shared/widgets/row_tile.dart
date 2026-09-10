import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/core/theme/app_colors.dart';

class RowTile extends StatelessWidget {
  const RowTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.copper.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.copper.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(icon, color: AppColors.copper, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.cream,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              if (showChevron) ...[
                const SizedBox(width: 6),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.muted,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
