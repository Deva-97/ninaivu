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
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

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
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }
}
