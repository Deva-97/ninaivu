import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/app_colors.dart';
import 'package:ninaivu/core/services/auth_service.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/local_data_change_service.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/data/repositories/user_repository_impl.dart';
import 'package:ninaivu/domain/entities/app_user.dart';

/// Shared dashboard behavior for admin and agent home screens.
///
/// Concrete controllers only provide feature-specific data loading, while this
/// base class owns session actions, sync feedback, and auto-refresh behavior.
abstract class DashboardController<T> extends GetxController {
  DashboardController({
    AuthService? authService,
    SyncQueueLocalDataSource? syncQueueLocalDataSource,
    SyncService? syncService,
    UserRepositoryImpl? userRepository,
  }) : _authService = authService ?? AuthService(),
       _syncQueueLocalDataSource =
           syncQueueLocalDataSource ?? SyncQueueLocalDataSource(),
       _syncService = syncService ?? SyncService(),
       _userRepository = userRepository ?? UserRepositoryImpl();

  final AuthService _authService;
  final SyncQueueLocalDataSource _syncQueueLocalDataSource;
  final SyncService _syncService;
  final UserRepositoryImpl _userRepository;

  final isLoading = false.obs;
  final isSigningOut = false.obs;
  final isSyncing = false.obs;
  final errorMessage = RxnString();
  final currentUser = Rxn<AppUser>();
  final lastSyncLabel = 'Never synced'.obs;
  final backupStatusLabel = 'Saved offline'.obs;
  StreamSubscription<int?>? _lastSyncTimeSubscription;
  StreamSubscription<void>? _localDataChangeSubscription;
  Timer? _dashboardReloadDebounce;

  Future<void> loadDashboard();

  Future<void> loadCurrentUser() async {
    currentUser.value = await _userRepository.getCurrentUser();
  }

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
    refreshLastSyncLabel();
    _lastSyncTimeSubscription = AppPreferences.lastSyncTimeStream.listen((_) {
      refreshLastSyncLabel();
    });
    _localDataChangeSubscription = LocalDataChangeService.changes.listen((_) {
      _scheduleDashboardReload();
    });
  }

  @override
  void onClose() {
    _lastSyncTimeSubscription?.cancel();
    _localDataChangeSubscription?.cancel();
    _dashboardReloadDebounce?.cancel();
    super.onClose();
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
    final pendingCount = await _syncQueueLocalDataSource.countPendingItems();
    // The dashboard shows both "when was the last backup" and "is anything
    // still waiting to sync", so we derive two labels from local sync state.
    if (pendingCount > 0) {
      backupStatusLabel.value = 'Backup pending';
    } else {
      backupStatusLabel.value = lastSyncTime == null
          ? 'Saved offline'
          : 'Backed up';
    }
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

  void _scheduleDashboardReload() {
    _dashboardReloadDebounce?.cancel();
    // Repository writes can trigger a burst of local change events, so debounce
    // keeps the dashboard from re-querying on every single record mutation.
    _dashboardReloadDebounce = Timer(const Duration(milliseconds: 250), () {
      loadCurrentUser();
      loadDashboard();
    });
  }
}
