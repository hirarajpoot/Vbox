import 'package:flutter/material.dart';
import 'package:vbox/core/theme/app_colors.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 8, 14, 8),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xCC1A1612),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.copper.withValues(alpha: 0.22)),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
