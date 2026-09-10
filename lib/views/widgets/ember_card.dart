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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xCC1A1612),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: glow
                  ? AppColors.copper.withValues(alpha: 0.55)
                  : AppColors.copper.withValues(alpha: 0.22),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
