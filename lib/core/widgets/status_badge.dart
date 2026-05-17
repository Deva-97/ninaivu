import 'package:flutter/material.dart';

import 'package:ninaivu/core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final lowerLabel = label.trim().toLowerCase();

    Color backgroundColor;
    Color foregroundColor;

    switch (lowerLabel) {
      case 'completed':
      case 'renewed':
        backgroundColor = brightness == Brightness.dark
            ? AppColors.successDarkBg
            : AppColors.successLightBg;
        foregroundColor = brightness == Brightness.dark
            ? AppColors.successDarkText
            : AppColors.successLightText;
        break;
      case 'upcoming':
      case 'pending':
        backgroundColor = brightness == Brightness.dark
            ? AppColors.warningDarkBg
            : AppColors.warningLightBg;
        foregroundColor = brightness == Brightness.dark
            ? AppColors.warningDarkText
            : AppColors.warningLightText;
        break;
      case 'expired':
      case 'missed':
        backgroundColor = brightness == Brightness.dark
            ? AppColors.dangerDarkBg
            : AppColors.dangerLightBg;
        foregroundColor = brightness == Brightness.dark
            ? AppColors.dangerDarkText
            : AppColors.dangerLightText;
        break;
      default:
        backgroundColor = brightness == Brightness.dark
            ? AppColors.infoDarkBg
            : AppColors.infoLightBg;
        foregroundColor = brightness == Brightness.dark
            ? AppColors.infoDarkText
            : AppColors.infoLightText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
