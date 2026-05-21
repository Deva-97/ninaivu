import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_lock_settings_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

enum AccountAction { appLock, deleteAccount, signOut }

class AccountActionsMenu extends StatelessWidget {
  const AccountActionsMenu({
    super.key,
    required this.onSignOut,
    required this.isSigningOut,
  });

  static final Uri _deleteAccountUri = Uri.parse(
    'https://devendiran-portfolio.web.app/ninaivu/delete-account',
  );

  final Future<void> Function() onSignOut;
  final bool isSigningOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<AccountAction>(
      tooltip: TranslationKeys.account.tr,
      enabled: !isSigningOut,
      onSelected: (value) async {
        switch (value) {
          case AccountAction.appLock:
            await showDialog<void>(
              context: context,
              builder: (_) => const AppLockSettingsDialog(),
            );
            break;
          case AccountAction.deleteAccount:
            await _openDeleteAccountFlow(context);
            break;
          case AccountAction.signOut:
            await _confirmAndSignOut(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<AccountAction>(
          value: AccountAction.appLock,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline_rounded),
            title: Text(TranslationKeys.appLock.tr),
          ),
        ),
        PopupMenuItem<AccountAction>(
          value: AccountAction.deleteAccount,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline_rounded),
            title: Text(TranslationKeys.deleteAccount.tr),
          ),
        ),
        PopupMenuItem<AccountAction>(
          value: AccountAction.signOut,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_rounded),
            title: Text(TranslationKeys.logout.tr),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSigningOut)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const SizedBox.shrink(),
            if (isSigningOut) const SizedBox(width: 8),
            Text(
              isSigningOut
                  ? TranslationKeys.signingOut.tr
                  : TranslationKeys.account.tr,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TranslationKeys.logout.tr),
          content: Text(
            TranslationKeys.signOutDialogMessage.tr,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(TranslationKeys.cancel.tr),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(TranslationKeys.logout.tr),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await onSignOut();
    }
  }

  Future<void> _openDeleteAccountFlow(BuildContext context) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TranslationKeys.deleteAccount.tr),
          content: Text(
            TranslationKeys.deleteAccountBrowserDialogMessage.tr,
          ),
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
          content: Text(
            TranslationKeys.unableToOpenDeleteAccountPage.tr,
          ),
        ),
      );
    }
  }
}
