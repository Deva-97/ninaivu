import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

import 'app_shell_primitives.dart';

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
              color: theme.colorScheme.outline.withValues(alpha: 0.48),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
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
                const SizedBox(height: 6),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
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
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        ...switch (trailing) {
          final widget? => [widget],
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
    final theme = Theme.of(context);
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: theme.brightness == Brightness.dark
            ? AppColors.darkSurfaceSoft
            : AppColors.surfaceHighlight,
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.72),
        ),
      ),
      icon: Icon(icon, size: 20),
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
    return AppSurfaceCard(
      padding: EdgeInsets.all(responsive.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title, subtitle: subtitle),
          SizedBox(height: responsive.itemGap),
          ...withVerticalSpacing(children, responsive.itemGap),
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
    return AppSurfaceCard(
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
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (statusLabel != null) ...[
                  const SizedBox(height: 10),
                  StatusBadge(label: statusLabel!),
                ],
              ],
            ),
          ),
          ...switch (trailing) {
            final widget? => [widget],
            null => const <Widget>[],
          },
        ],
      ),
    );
  }
}

class DetailFieldRow extends StatelessWidget {
  const DetailFieldRow({super.key, required this.label, required this.value});

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
