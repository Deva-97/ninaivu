import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/constants/app_colors.dart';
import 'package:insurance_reminders/core/services/auth_service.dart';
import 'package:insurance_reminders/core/services/app_preferences.dart';
import 'package:insurance_reminders/core/services/sync_service.dart';
import 'package:intl/intl.dart';

abstract class DashboardController<T> extends GetxController {
  DashboardController({AuthService? authService, SyncService? syncService})
    : _authService = authService ?? AuthService(),
      _syncService = syncService ?? SyncService();

  final AuthService _authService;
  final SyncService _syncService;

  final isLoading = false.obs;
  final isSigningOut = false.obs;
  final isSyncing = false.obs;
  final errorMessage = RxnString();
  final lastSyncLabel = 'Never synced'.obs;

  Future<void> loadDashboard();

  @override
  void onInit() {
    super.onInit();
    refreshLastSyncLabel();
  }

  Future<void> signOut() async {
    if (isSigningOut.value) {
      return;
    }

    isSigningOut.value = true;
    try {
      await _authService.logout();
    } catch (e) {
      _showNotification(
        title: 'Unable to sign out',
        message: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Get.isDarkMode
            ? AppColors.dangerDarkBg
            : AppColors.dangerLightBg,
        textColor: Get.isDarkMode
            ? AppColors.dangerDarkText
            : AppColors.dangerLightText,
      );
    } finally {
      isSigningOut.value = false;
    }
  }

  Future<void> syncNow() async {
    if (isSyncing.value) {
      return;
    }

    isSyncing.value = true;
    try {
      final syncedCount = await _syncService.syncPendingData();
      await refreshLastSyncLabel();
      _showNotification(
        title: 'Sync complete',
        message: syncedCount > 0
            ? 'Backed up $syncedCount pending change(s) to Firebase.'
            : 'No pending local changes needed syncing.',
        backgroundColor: syncedCount > 0
            ? (Get.isDarkMode
                  ? AppColors.successDarkBg
                  : AppColors.successLightBg)
            : (Get.isDarkMode ? AppColors.infoDarkBg : AppColors.infoLightBg),
        textColor: syncedCount > 0
            ? (Get.isDarkMode
                  ? AppColors.successDarkText
                  : AppColors.successLightText)
            : (Get.isDarkMode
                  ? AppColors.infoDarkText
                  : AppColors.infoLightText),
      );
    } catch (e) {
      _showNotification(
        title: 'Sync failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Get.isDarkMode
            ? AppColors.dangerDarkBg
            : AppColors.dangerLightBg,
        textColor: Get.isDarkMode
            ? AppColors.dangerDarkText
            : AppColors.dangerLightText,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> refreshLastSyncLabel() async {
    final preferences = await AppPreferences.getInstance();
    final lastSyncTime = preferences.lastSyncTime;
    if (lastSyncTime == null) {
      lastSyncLabel.value = 'Never synced';
      return;
    }

    lastSyncLabel.value = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.fromMillisecondsSinceEpoch(lastSyncTime));
  }

  void _showNotification({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }
}
