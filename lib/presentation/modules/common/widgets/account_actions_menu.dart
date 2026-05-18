import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum AccountAction { deleteAccount, signOut }

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
      tooltip: 'Account',
      enabled: !isSigningOut,
      onSelected: (value) async {
        switch (value) {
          case AccountAction.deleteAccount:
            await _openDeleteAccountFlow(context);
            break;
          case AccountAction.signOut:
            await _confirmAndSignOut(context);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<AccountAction>(
          value: AccountAction.deleteAccount,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline_rounded),
            title: Text('Delete account'),
          ),
        ),
        PopupMenuItem<AccountAction>(
          value: AccountAction.signOut,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded),
            title: Text('Sign out'),
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
              isSigningOut ? 'Signing out...' : 'Account',
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
          title: const Text('Sign out'),
          content: const Text(
            'You are about to sign out of your Ninaivu account on this device. '
            'Make sure you have finished your work and synced recent changes before continuing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sign out'),
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
          title: const Text('Delete account'),
          content: const Text(
            'This will open the Ninaivu delete account page in your browser. '
            'Continue only if you want to request permanent account deletion.',
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
