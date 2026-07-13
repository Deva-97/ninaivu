import 'package:flutter/material.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/widgets.dart';

import 'app_shell_primitives.dart';
import 'app_shell_scaffold.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
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
    final theme = Theme.of(context);
    return AppSurfaceCard(
      padding: EdgeInsets.all(responsive.scaled(18, min: 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconChip(icon: icon, color: color),
              const Spacer(),
              if (badgeLabel != null) StatusBadge(label: badgeLabel!),
            ],
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.prominent = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.responsive.isMobile ? 0 : 220,
          maxWidth: 260,
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: prominent
                ? color.withValues(alpha: 0.14)
                : theme.brightness == Brightness.dark
                ? AppColors.darkSurfaceSoft
                : AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: prominent
                  ? color.withValues(alpha: 0.26)
                  : theme.colorScheme.outline.withValues(alpha: 0.72),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AppIconChip(icon: icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryValue,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.highlights,
  });

  final String title;
  final String subtitle;
  final int primaryValue;
  final String primaryLabel;
  final IconData primaryIcon;
  final List<DashboardHeroHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = context.responsive;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? const [AppColors.heroBlueDark, Color(0xFF173154)]
              : const [Color(0xFFF7FAFF), Color(0xFFEAF1FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? AppColors.info.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.scaled(22, min: 18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark
                    ? AppColors.infoDarkText
                    : AppColors.infoLightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              primaryValue.toString(),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                AppIconChip(icon: primaryIcon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(primaryLabel, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: highlights
                  .map((item) => _HeroHighlightChip(highlight: item))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHeroHighlight {
  const DashboardHeroHighlight({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class DashboardActionGroup extends StatelessWidget {
  const DashboardActionGroup({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: children),
      ],
    );
  }
}

class UpcomingWorkCard extends StatelessWidget {
  const UpcomingWorkCard({
    super.key,
    required this.title,
    required this.label,
    required this.dateLabel,
    required this.trailingLabel,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String label;
  final String dateLabel;
  final String trailingLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconChip(icon: icon, color: AppColors.actionSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppMetaPill(text: dateLabel),
                      AppMetaPill(text: trailingLabel),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHighlightChip extends StatelessWidget {
  const _HeroHighlightChip({required this.highlight});

  final DashboardHeroHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight.color.withValues(alpha: isDark ? 0.28 : 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            highlight.value.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: highlight.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(highlight.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
