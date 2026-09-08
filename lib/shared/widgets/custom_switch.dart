import 'package:flutter/material.dart';
import 'package:vbox/core/theme/app_colors.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.copper,
      activeTrackColor: AppColors.copper.withValues(alpha: 0.45),
      inactiveThumbColor: AppColors.muted,
      inactiveTrackColor: AppColors.surfaceHigh,
    );
  }
}
