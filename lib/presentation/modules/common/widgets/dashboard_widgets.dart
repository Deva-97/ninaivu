import 'package:flutter/material.dart';

import 'package:ninaivu/core/widgets/status_badge.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

/// Reusable metric tile used by both admin and agent dashboards.
class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badgeLabel,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Container(
      padding: EdgeInsets.all(responsive.scaled(15, min: 12)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(responsive.scaled(20, min: 16)),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: responsive.scaled(14, min: 10),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(responsive.scaled(8, min: 7)),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(
                    responsive.scaled(14, min: 10),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: responsive.scaled(20, min: 16),
                ),
              ),
              const Spacer(),
              if (badgeLabel != null)
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topRight,
                      child: StatusBadge(label: badgeLabel!),
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value.toString(),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: responsive.scaled(28, min: 24),
            ),
          ),
          SizedBox(height: responsive.scaled(4, min: 3)),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: responsive.scaled(13, min: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight action button style for dashboard shortcuts.
class DashboardQuickAction extends StatelessWidget {
  const DashboardQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: color.withValues(alpha: 0.12),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.scaled(16, min: 12),
          vertical: responsive.scaled(16, min: 12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.scaled(18, min: 14)),
        ),
      ),
    );
  }
}
