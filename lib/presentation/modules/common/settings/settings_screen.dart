import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/core/localization/app_locale.dart';
import 'package:ninaivu/core/widgets.dart';
import 'package:ninaivu/presentation/controllers/settings_controller.dart';
import 'package:ninaivu/presentation/modules/common/widgets/account_deletion_card.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_lock_settings_dialog.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_shell.dart';
import 'package:ninaivu/presentation/modules/common/widgets/profile_image_actions.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return AppShellScaffold(
      currentTab: AppShellTab.settings,
      dashboardRoute: AppRoutes.agentDashboard,
      title: TranslationKeys.settings.tr,
      subtitle: 'Preferences, sync tools, and account controls',
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentUser.value == null) {
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
            padding: EdgeInsets.fromLTRB(
              responsive.pagePadding,
              0,
              responsive.pagePadding,
              responsive.scaled(110, min: 96),
            ),
            children: [
              ProfileAvatarBlock(
                name: user.name,
                subtitle: [
                  user.mobile,
                  user.email,
                ].whereType<String>().where((e) => e.isNotEmpty).join(' • '),
                statusLabel: user.role == 'admin'
                    ? TranslationKeys.roleAdmin.tr
                    : TranslationKeys.roleAgent.tr,
                imagePath: user.profileImagePath,
                imageData: user.profileImageData,
                onTap: () => showSettingsProfileImageOptions(
                  context: context,
                  name: user.name,
                  imagePath: user.profileImagePath,
                  imageData: user.profileImageData,
                  onPickImage: controller.pickProfileImage,
                  onRemoveImage: controller.removeProfileImage,
                ),
              ),
              SizedBox(height: responsive.sectionGap),
              FormSectionCard(
                title: 'Preferences',
                children: [
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
              SizedBox(height: responsive.itemGap),
              FormSectionCard(
                title: 'System',
                children: [
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
              SizedBox(height: responsive.itemGap),
              FormSectionCard(
                title: 'Data',
                children: [
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
                ],
              ),
              SizedBox(height: responsive.itemGap),
              FormSectionCard(
                title: 'Account',
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
                          content: Text(TranslationKeys.logoutKeepLocalData.tr),
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
              SizedBox(height: responsive.itemGap),
              const AccountDeletionCard(),
              SizedBox(height: responsive.itemGap),
              Center(
                child: Text(
                  controller.versionText.value,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      }),
    );
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
}
