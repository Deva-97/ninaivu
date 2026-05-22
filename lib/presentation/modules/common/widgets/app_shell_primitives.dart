import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}

class AppMetaPill extends StatelessWidget {
  const AppMetaPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurfaceHighlight
            : AppColors.lightSurfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: theme.textTheme.labelMedium),
    );
  }
}

class AppIconChip extends StatelessWidget {
  const AppIconChip({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class AppInlineActionButton extends StatelessWidget {
  const AppInlineActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String normalizeStatus(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return TranslationKeys.pending.tr;
  }
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

int daysUntilDate(DateTime date) {
  final now = DateTime.now();
  final target = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  return target.difference(today).inDays;
}

String expiryLabelFor(int daysUntilExpiry) {
  if (daysUntilExpiry < 0) {
    return '${daysUntilExpiry.abs()} ${TranslationKeys.expiredDaysAgo.tr}';
  }
  if (daysUntilExpiry == 0) {
    return TranslationKeys.dueToday.tr;
  }
  return '$daysUntilExpiry ${TranslationKeys.daysLeft.tr}';
}

Color expiryColorFor(int daysUntilExpiry) {
  if (daysUntilExpiry < 0) {
    return AppColors.danger;
  }
  if (daysUntilExpiry <= 7) {
    return AppColors.warning;
  }
  return AppColors.success;
}

List<Widget> withVerticalSpacing(List<Widget> children, double gap) {
  final items = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    items.add(children[i]);
    if (i != children.length - 1) {
      items.add(SizedBox(height: gap));
    }
  }
  return items;
}
