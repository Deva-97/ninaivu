import 'package:flutter/material.dart';

import 'package:insurance_reminders/core/widgets/status_badge.dart';

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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              if (badgeLabel != null) StatusBadge(label: badgeLabel!),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: color.withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
