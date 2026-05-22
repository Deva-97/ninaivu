import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/entities/reminder.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

enum AppShellTab { dashboard, clients, policies, followUps, settings }

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({
    super.key,
    required this.currentTab,
    required this.body,
    required this.dashboardRoute,
    this.title,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
  });

  final AppShellTab currentTab;
  final Widget body;
  final String dashboardRoute;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.pagePadding,
                  responsive.pagePadding,
                  responsive.pagePadding,
                  responsive.itemGap,
                ),
                child: AppPageHeader(
                  title: title!,
                  subtitle: subtitle,
                  actions: actions ?? const [],
                ),
              ),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: AppShellTab.values.indexOf(currentTab),
          onDestinationSelected: (index) => _navigate(index),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.space_dashboard_outlined),
              selectedIcon: const Icon(Icons.space_dashboard_rounded),
              label: TranslationKeys.dashboard.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded),
              selectedIcon: const Icon(Icons.people_rounded),
              label: TranslationKeys.clients.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.description_outlined),
              selectedIcon: const Icon(Icons.description_rounded),
              label: TranslationKeys.policies.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.pending_actions_outlined),
              selectedIcon: const Icon(Icons.pending_actions_rounded),
              label: TranslationKeys.followUps.tr,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings_rounded),
              label: TranslationKeys.settings.tr,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(int index) {
    final target = switch (AppShellTab.values[index]) {
      AppShellTab.dashboard => dashboardRoute,
      AppShellTab.clients => AppRoutes.clients,
      AppShellTab.policies => AppRoutes.policies,
      AppShellTab.followUps => AppRoutes.followUps,
      AppShellTab.settings => AppRoutes.settings,
    };
    if (Get.currentRoute != target) {
      Get.offNamed(target);
    }
  }
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (actions case final nonEmptyActions when nonEmptyActions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Wrap(spacing: 8, children: nonEmptyActions),
        ],
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle case final subtitleText?) ...[
                const SizedBox(height: 2),
                Text(subtitleText, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        ...switch (trailing) {
          final trailingWidget? => [trailingWidget],
          null => const <Widget>[],
        },
      ],
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.8),
        ),
      ),
      icon: Icon(icon, size: 20),
    );
  }
}

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
    return _SurfaceCard(
      padding: EdgeInsets.all(responsive.scaled(16, min: 14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconChip(icon: icon, color: color),
              const Spacer(),
              if (badgeLabel != null) StatusBadge(label: badgeLabel!),
            ],
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
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
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconChip(icon: icon, color: color),
              const SizedBox(width: 10),
              Flexible(
                child: Text(label, style: Theme.of(context).textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    required this.hintText,
    this.onSubmitted,
    this.onRefresh,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: onRefresh == null
            ? null
            : IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
      ),
    );
  }
}

class AppFilterChips extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.items,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<MapEntry<String, String>> items;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return SizedBox(
      height: responsive.chipBarHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.pagePadding,
          vertical: responsive.scaled(10, min: 8),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item.key == selectedKey;
          return ChoiceChip(
            label: Text(item.value),
            selected: selected,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : null,
            ),
            onSelected: (_) => onSelected(item.key),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
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
    final responsive = context.responsive;
    return _SurfaceCard(
      padding: EdgeInsets.all(responsive.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title, subtitle: subtitle),
          SizedBox(height: responsive.itemGap),
          ..._withSpacing(children, responsive.itemGap),
        ],
      ),
    );
  }
}

class ProfileAvatarBlock extends StatelessWidget {
  const ProfileAvatarBlock({
    super.key,
    required this.name,
    this.subtitle,
    this.statusLabel,
    this.imagePath,
    this.imageData,
    this.onTap,
    this.trailing,
  });

  final String name;
  final String? subtitle;
  final String? statusLabel;
  final String? imagePath;
  final String? imageData;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return _SurfaceCard(
      padding: EdgeInsets.all(responsive.pagePadding),
      child: Row(
        children: [
          ProfileAvatar(
            name: name,
            imagePath: imagePath,
            imageData: imageData,
            radius: responsive.scaled(30, min: 28),
            onTap: onTap,
          ),
          SizedBox(width: responsive.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (statusLabel case final badgeLabel?) ...[
                  const SizedBox(height: 10),
                  StatusBadge(label: badgeLabel),
                ],
              ],
            ),
          ),
          ...switch (trailing) {
            final trailingWidget? => [trailingWidget],
            null => const <Widget>[],
          },
        ],
      ),
    );
  }
}

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    this.onMenuSelected,
  });

  final Client client;
  final VoidCallback onTap;
  final ValueChanged<String>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileAvatar(
              name: client.name,
              imagePath: client.profileImagePath,
              radius: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(client.mobile, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaPill(text: client.areaCity ?? 'Area not set'),
                      _MetaPill(text: 'Policies ${client.policyCount}'),
                      StatusBadge(label: client.syncStatus),
                    ],
                  ),
                ],
              ),
            ),
            if (onMenuSelected != null)
              PopupMenuButton<String>(
                onSelected: onMenuSelected,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'call', child: Text('Call')),
                  PopupMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  PopupMenuItem(value: 'policies', child: Text('View policies')),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class PolicyCard extends StatelessWidget {
  const PolicyCard({
    super.key,
    required this.policy,
    required this.subtitle,
    required this.onTap,
    this.onMenuSelected,
  });

  final Policy policy;
  final String subtitle;
  final VoidCallback onTap;
  final ValueChanged<String>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconChip(
              icon: Icons.description_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policy.policyNumber,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaPill(text: policy.insuranceType),
                      _MetaPill(text: policy.companyName),
                      StatusBadge(label: policy.renewalStatus),
                    ],
                  ),
                ],
              ),
            ),
            if (onMenuSelected != null)
              PopupMenuButton<String>(
                onSelected: onMenuSelected,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.subtitle,
    required this.onTap,
  });

  final Reminder reminder;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _IconChip(icon: Icons.notifications_none_rounded, color: AppColors.warning),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.clientName ?? 'Client ${reminder.clientId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(label: _normalize(reminder.status)),
          ],
        ),
      ),
    );
  }
}

class FollowUpCard extends StatelessWidget {
  const FollowUpCard({
    super.key,
    required this.followUp,
    required this.subtitle,
    required this.onTap,
    this.onMenuSelected,
  });

  final FollowUp followUp;
  final String subtitle;
  final VoidCallback onTap;
  final ValueChanged<String>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _IconChip(icon: Icons.pending_actions_outlined, color: AppColors.info),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    followUp.clientName ?? 'Client ${followUp.clientId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (onMenuSelected case final onSelect?)
              PopupMenuButton<String>(
                onSelected: onSelect,
                child: StatusBadge(label: followUp.status),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              )
            else
              StatusBadge(label: followUp.status),
          ],
        ),
      ),
    );
  }
}

class DetailFieldRow extends StatelessWidget {
  const DetailFieldRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: responsive.detailLabelWidth,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    if (onTap == null) {
      return card;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: theme.textTheme.labelMedium),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

List<Widget> _withSpacing(List<Widget> children, double gap) {
  final items = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    items.add(children[i]);
    if (i != children.length - 1) {
      items.add(SizedBox(height: gap));
    }
  }
  return items;
}

String _normalize(String value) {
  if (value.isEmpty) {
    return 'Pending';
  }
  return value[0].toUpperCase() + value.substring(1);
}
