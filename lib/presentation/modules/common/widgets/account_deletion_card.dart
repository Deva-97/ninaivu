import 'package:flutter/material.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountDeletionCard extends StatelessWidget {
  const AccountDeletionCard({super.key});

  static final Uri _deleteAccountUri = Uri.parse(
    'https://devendiran-portfolio.web.app/ninaivu/delete-account',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final responsive = context.responsive;
    final borderRadius = BorderRadius.circular(responsive.scaled(24, min: 20));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
            colorScheme.errorContainer.withValues(alpha: 0.26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.scaled(20, min: 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.scaled(12, min: 10),
                vertical: responsive.scaled(7, min: 6),
              ),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(
                  responsive.scaled(999, min: 999),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: responsive.scaled(18, min: 16),
                    color: colorScheme.error,
                  ),
                  SizedBox(width: responsive.scaled(8, min: 6)),
                  Text(
                    'Account & privacy',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.scaled(16, min: 12)),
            Text(
              'Delete your Ninaivu account',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: responsive.scaled(8, min: 6)),
            Text(
              'Use the official Ninaivu deletion page to request permanent account removal.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            SizedBox(height: responsive.scaled(14, min: 10)),
            Text(
              'This may remove your access and associated app data.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: responsive.scaled(16, min: 12)),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.scaled(16, min: 14),
                    vertical: responsive.scaled(14, min: 12),
                  ),
                ),
                onPressed: () => _confirmAndOpen(context),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Continue to delete account'),
              ),
            ),
            SizedBox(height: responsive.scaled(10, min: 8)),
            Text(
              'Opens your secure web page outside the app.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndOpen(BuildContext context) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'You are leaving the app to continue the Ninaivu account deletion request. '
            'Only continue if you want to permanently remove your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true) {
      return;
    }

    if (!await launchUrl(
      _deleteAccountUri,
      mode: LaunchMode.externalApplication,
    )) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the account deletion page right now. Please try again.',
          ),
        ),
      );
    }
  }
}
