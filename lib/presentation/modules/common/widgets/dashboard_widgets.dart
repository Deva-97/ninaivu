import 'app_shell.dart';

class DashboardMetricCard extends MetricCard {
  const DashboardMetricCard({
    super.key,
    required super.title,
    required super.value,
    required super.icon,
    required super.color,
    super.badgeLabel,
  });
}

class DashboardQuickAction extends QuickActionCard {
  const DashboardQuickAction({
    super.key,
    required super.label,
    required super.icon,
    required super.color,
    required super.onTap,
  });
}
