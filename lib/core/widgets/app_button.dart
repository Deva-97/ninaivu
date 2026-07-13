import 'package:flutter/material.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: responsive.scaled(18, min: 16),
            height: responsive.scaled(18, min: 16),
            child: CircularProgressIndicator(strokeWidth: 2.2),
          )
        else if (icon != null)
          Icon(icon, size: responsive.scaled(18, min: 16)),
        if (isLoading || icon != null)
          SizedBox(width: responsive.scaled(10, min: 8)),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    final button = outlined
        ? OutlinedButton(onPressed: isLoading ? null : onPressed, child: child)
        : ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);

    if (!expanded) {
      return button;
    }
    return SizedBox(width: double.infinity, child: button);
  }
}
