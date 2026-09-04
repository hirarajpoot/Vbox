import 'package:flutter/material.dart';
import 'package:vbox/core/theme/app_colors.dart';

class EmberCard extends StatelessWidget {
  const EmberCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.card),
    this.onTap,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(
              color: glow
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.divider,
            ),
            boxShadow: [
              ...AppShadows.card,
              if (glow)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
