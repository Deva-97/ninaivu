import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/localization/app_locale.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/core/services/import_export_service.dart';
import 'package:ninaivu/presentation/controllers/settings_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/account_deletion_card.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_lock_settings_dialog.dart';
import 'package:ninaivu/presentation/modules/common/widgets/profile_image_actions.dart';

/// Settings hub for profile preferences, backup visibility, and import/export tools.
class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Scaffold(
      appBar: AppBar(title: Text(TranslationKeys.settings.tr)),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentUser.value == null) {
          return AppLoadingView(message: TranslationKeys.loadingSettings.tr);
        }

        final user = controller.currentUser.value;
        if (user == null) {
          return AppEmptyState(
            icon: Icons.person_off_outlined,
            title: TranslationKeys.profileUnavailable.tr,
            subtitle: TranslationKeys.pleaseSignInAgain.tr,
          );
        }

        return ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.all(responsive.pagePadding),
            children: [
              // Profile summary doubles as the entry point for profile image updates.
              Card(
                child: Padding(
                  padding: EdgeInsets.all(responsive.pagePadding),
                  child: Row(
                    children: [
                      ProfileAvatar(
                        name: user.name,
                        imagePath: user.profileImagePath,
                        imageData: user.profileImageData,
                        radius: 34,
                        onTap: () => showSettingsProfileImageOptions(
                          context: context,
                          name: user.name,
                          imagePath: user.profileImagePath,
                          imageData: user.profileImageData,
                          onPickImage: controller.pickProfileImage,
                          onRemoveImage: controller.removeProfileImage,
                        ),
                      ),
                      SizedBox(width: responsive.itemGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                            if ((user.mobile ?? '').isNotEmpty) Text(user.mobile!),
                            if ((user.email ?? '').isNotEmpty) Text(user.email!),
                            const SizedBox(height: 8),
                            StatusBadge(
                              label: user.role == 'admin'
                                  ? TranslationKeys.roleAdmin.tr
                                  : TranslationKeys.roleAgent.tr,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Card(
                child: Column(
                  children: [
                    // These preferences write through the settings service and
                    // immediately update the app via reactive observers.
                    ListTile(
                      title: Text(TranslationKeys.language.tr),
                      trailing: Obx(
                        () => DropdownButton<AppLanguage>(
                          value: controller.settings.language.value,
                          underline: const SizedBox.shrink(),
                          items: AppLanguage.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(_languageLabel(value)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.settings.updateLanguage(value);
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(TranslationKeys.theme.tr),
                      trailing: Obx(
                        () => DropdownButton<AppThemeMode>(
                          value: controller.settings.themeMode.value,
                          underline: const SizedBox.shrink(),
                          items: AppThemeMode.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(_themeLabel(value)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.settings.updateThemeMode(value);
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(TranslationKeys.appLock.tr),
                      subtitle: Text(TranslationKeys.appLockPlaceholder.tr),
                      trailing: Obx(
                        () => Switch(
                          value: controller.appLockService.isEnabled.value,
                          onChanged: (_) async {
                            await showDialog<void>(
                              context: context,
                              builder: (_) => const AppLockSettingsDialog(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Card(
                child: Column(
                  children: [
                    // Operational values help support/debugging without opening
                    // a separate diagnostics screen.
                    ListTile(
                      title: Text(TranslationKeys.lastSync.tr),
                      subtitle: Text(controller.lastSyncText.value),
                    ),
                    ListTile(
                      title: Text(TranslationKeys.pendingSync.tr),
                      subtitle: Text('${controller.pendingSyncCount.value}'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Card(
                child: Column(
                  children: [
                    // Import/export stays in settings because it is an admin-style
                    // maintenance workflow rather than part of daily data entry.
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(TranslationKeys.exportClientsCsv.tr),
                      onTap: controller.exportClientsCsv,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(TranslationKeys.exportPoliciesCsv.tr),
                      onTap: controller.exportPoliciesCsv,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(TranslationKeys.exportFollowUpsCsv.tr),
                      onTap: controller.exportFollowUpsCsv,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(TranslationKeys.exportRemindersCsv.tr),
                      onTap: controller.exportRemindersCsv,
                    ),
                    ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: Text(TranslationKeys.importClientsCsv.tr),
                      onTap: () async => _showImportSummary(await controller.importClientsCsv()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: Text(TranslationKeys.importPoliciesCsv.tr),
                      onTap: () async => _showImportSummary(await controller.importPoliciesCsv()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(TranslationKeys.importDocuments.tr),
                      subtitle: Text(TranslationKeys.documentParserPlaceholder.tr),
                      onTap: () async {
                        final message = await controller.importDocumentPlaceholder();
                        if (message != null) {
                          Get.snackbar(TranslationKeys.importDocuments.tr, message);
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cleaning_services_outlined),
                      title: Text(TranslationKeys.clearLocalData.tr),
                      subtitle: Text(TranslationKeys.clearLocalDataSubtitle.tr),
                      onTap: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: Text(TranslationKeys.clearLocalData.tr),
                            content: Text(
                              TranslationKeys.clearLocalDataConfirmation.tr,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text(TranslationKeys.cancel.tr),
                              ),
                              FilledButton(
                                onPressed: () => Get.back(result: true),
                                child: Text(TranslationKeys.delete.tr),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await controller.clearLocalData();
                          Get.snackbar(
                            TranslationKeys.clearLocalData.tr,
                            TranslationKeys.localBusinessDataCleared.tr,
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded),
                      title: Text(TranslationKeys.logout.tr),
                      onTap: () async {
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: Text(TranslationKeys.logout.tr),
                            content: Text(
                              TranslationKeys.logoutKeepLocalData.tr,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: Text(TranslationKeys.cancel.tr),
                              ),
                              FilledButton(
                                onPressed: () => Get.back(result: true),
                                child: Text(TranslationKeys.logout.tr),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await controller.logout();
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.itemGap),
              const AccountDeletionCard(),
              SizedBox(height: responsive.sectionGap),
              Center(
                child: Text(
                  controller.versionText.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _languageLabel(AppLanguage value) {
    switch (value) {
      case AppLanguage.english:
        return TranslationKeys.english.tr;
      case AppLanguage.tamil:
        return TranslationKeys.tamil.tr;
      case AppLanguage.telugu:
        return TranslationKeys.telugu.tr;
    }
  }

  String _themeLabel(AppThemeMode value) {
    switch (value) {
      case AppThemeMode.system:
        return TranslationKeys.systemDefault.tr;
      case AppThemeMode.light:
        return TranslationKeys.light.tr;
      case AppThemeMode.dark:
        return TranslationKeys.dark.tr;
    }
  }

  void _showImportSummary(ImportSummary? summary) {
    if (summary == null) {
      return;
    }
    // A lightweight snackbar is enough here because the import service already
    // returns aggregated counts instead of row-by-row details.
    Get.snackbar(
      TranslationKeys.importLabel.tr,
      'Added: ${summary.addedCount}, Skipped: ${summary.skippedCount}, Duplicates: ${summary.duplicateCount}, Failed: ${summary.failedCount}',
    );
  }
}
