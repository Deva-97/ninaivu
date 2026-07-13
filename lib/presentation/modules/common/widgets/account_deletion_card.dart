import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
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
    final subtitleStyle =
        theme.listTileTheme.subtitleTextStyle ?? theme.textTheme.bodyMedium;

    return Card(
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
                    TranslationKeys.accountAndPrivacy.tr,
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
              TranslationKeys.deleteNinaivuAccount.tr,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: responsive.scaled(8, min: 6)),
            Text(
              TranslationKeys.deleteAccountSubtitle.tr,
              style: subtitleStyle?.copyWith(height: 1.4),
            ),
            SizedBox(height: responsive.scaled(14, min: 10)),
            Text(
              TranslationKeys.deleteAccountWarning.tr,
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
                label: Text(TranslationKeys.continueToDeleteAccount.tr),
              ),
            ),
            SizedBox(height: responsive.scaled(10, min: 8)),
            Text(
              TranslationKeys.opensSecureWebPage.tr,
              style: subtitleStyle?.copyWith(
                fontSize: theme.textTheme.bodySmall?.fontSize,
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
          title: Text(TranslationKeys.deleteAccount.tr),
          content: Text(TranslationKeys.deleteAccountDialogMessage.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(TranslationKeys.cancel.tr),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(TranslationKeys.continueLabel.tr),
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
        SnackBar(
          content: Text(TranslationKeys.unableToOpenDeleteAccountPage.tr),
        ),
      );
    }
  }
}
