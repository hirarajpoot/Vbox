import 'package:flutter/material.dart';
import 'package:vbox/shared/widgets/pill_button.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null && !busy ? 0.45 : 1,
      child: PillButton(
        text: label,
        onPressed: onPressed ?? () {},
        isLoading: busy,
      ),
    );
  }
}
