import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/domain/entities/client.dart';
import 'package:ninaivu/domain/entities/follow_up.dart';
import 'package:ninaivu/domain/entities/policy.dart';
import 'package:ninaivu/domain/entities/reminder.dart';

import 'app_shell_primitives.dart';

class ClientCard extends StatelessWidget {
  const ClientCard({
    super.key,
    required this.client,
    required this.onTap,
    this.onCall,
    this.onWhatsApp,
    this.onMenuSelected,
  });

  final Client client;
  final VoidCallback onTap;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final ValueChanged<String>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text(
                        client.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client.mobile,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (onMenuSelected != null)
                  PopupMenuButton<String>(
                    tooltip: TranslationKeys.moreActions.tr,
                    onSelected: onMenuSelected,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'policies',
                        child: Text(TranslationKeys.viewPolicies.tr),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(TranslationKeys.edit.tr),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(TranslationKeys.delete.tr),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppMetaPill(
                  text: client.areaCity ?? TranslationKeys.areaNotSet.tr,
                ),
                AppMetaPill(
                  text: '${client.policyCount} ${TranslationKeys.policies.tr}',
                ),
                StatusBadge(label: normalizeStatus(client.syncStatus)),
              ],
            ),
            if (onCall != null || onWhatsApp != null) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (onCall != null)
                    AppInlineActionButton(
                      icon: Icons.call_outlined,
                      label: TranslationKeys.call.tr,
                      color: AppColors.call,
                      onTap: onCall!,
                    ),
                  if (onWhatsApp != null)
                    AppInlineActionButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: TranslationKeys.whatsapp.tr,
                      color: AppColors.whatsapp,
                      onTap: onWhatsApp!,
                    ),
                ],
              ),
            ],
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
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(policy.endDate);
    final daysUntilExpiry = daysUntilDate(expiryDate);
    final expiryLabel = expiryLabelFor(daysUntilExpiry);
    final expiryColor = expiryColorFor(daysUntilExpiry);
    final dateFormat = DateFormat('dd MMM yyyy');

    return AppSurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconChip(
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
                      Text(
                        '${policy.companyName} • ${policy.insuranceType}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(label: normalizeStatus(policy.renewalStatus)),
                    if (onMenuSelected != null)
                      PopupMenuButton<String>(
                        tooltip: TranslationKeys.moreActions.tr,
                        onSelected: onMenuSelected,
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(TranslationKeys.edit.tr),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(TranslationKeys.delete.tr),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: expiryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: expiryColor.withValues(alpha: 0.16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.validTill.tr,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(expiryDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: expiryLabel),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppMetaPill(
                  text:
                      '${TranslationKeys.premium.tr}: ${policy.premiumAmount.toStringAsFixed(0)}',
                ),
                if ((policy.vehicleNumber ?? '').isNotEmpty)
                  AppMetaPill(text: policy.vehicleNumber!),
                if ((policy.paymentFrequency ?? '').isNotEmpty)
                  AppMetaPill(text: policy.paymentFrequency!),
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
    this.actions,
  });

  final Reminder reminder;
  final String subtitle;
  final VoidCallback onTap;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconChip(
                  icon: Icons.notifications_none_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.clientName ??
                            '${TranslationKeys.clientLabel.tr} ${reminder.clientId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge(label: normalizeStatus(reminder.status)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppMetaPill(
                  text: reminder.policyNumber ?? TranslationKeys.policyLabel.tr,
                ),
                AppMetaPill(
                  text:
                      reminder.companyName ?? TranslationKeys.insuranceLabel.tr,
                ),
              ],
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 10, children: actions!),
            ],
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
    this.actions,
    this.onMenuSelected,
  });

  final FollowUp followUp;
  final String subtitle;
  final VoidCallback onTap;
  final List<Widget>? actions;
  final ValueChanged<String>? onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconChip(
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.info,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        followUp.clientName ??
                            '${TranslationKeys.clientLabel.tr} ${followUp.clientId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(label: normalizeStatus(followUp.status)),
                    if (onMenuSelected != null)
                      PopupMenuButton<String>(
                        tooltip: TranslationKeys.moreActions.tr,
                        onSelected: onMenuSelected,
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(TranslationKeys.edit.tr),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(TranslationKeys.delete.tr),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppMetaPill(text: followUp.type),
                AppMetaPill(
                  text:
                      followUp.policyNumber ??
                      TranslationKeys.noPolicyLinked.tr,
                ),
              ],
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 10, children: actions!),
            ],
          ],
        ),
      ),
    );
  }
}
