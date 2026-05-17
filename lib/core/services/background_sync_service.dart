import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/sync_service.dart';
import 'package:ninaivu/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:ninaivu/firebase_options.dart';
import 'package:workmanager/workmanager.dart';

const String _backgroundSyncTaskName = 'background_data_sync';
const String _backgroundPeriodicTaskName = 'background-periodic-sync';
const String _backgroundQueuedTaskName = 'background-queued-sync';

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final preferences = await AppPreferences.getInstance();
      if (preferences.userId == null || preferences.businessId == null) {
        return true;
      }

      await SyncService().syncPendingData();
      return true;
    } catch (error, stackTrace) {
      debugPrint('Background sync task failed for $task: $error');
      FirebaseCrashlytics.instance.log('Background sync task failed for $task');
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Background sync task failure',
        fatal: false,
      );
      return false;
    }
  });
}

class BackgroundSyncService {
  BackgroundSyncService._();

  static final BackgroundSyncService instance = BackgroundSyncService._();

  final Workmanager _workmanager = Workmanager();

  bool _initialized = false;
  bool _isQueueSyncScheduled = false;

  bool get _supportsBackgroundSync =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (_initialized || !_supportsBackgroundSync) {
      return;
    }

    await _workmanager.initialize(backgroundSyncDispatcher);
    SyncQueueLocalDataSource.onItemEnqueued = scheduleQueuedSync;
    _initialized = true;
  }

  Future<void> ensureRegistered() async {
    if (!_supportsBackgroundSync) {
      return;
    }

    await initialize();

    final preferences = await AppPreferences.getInstance();
    if (preferences.userId == null || preferences.businessId == null) {
      return;
    }

    await _workmanager.cancelByUniqueName(_backgroundPeriodicTaskName);
    await _workmanager.registerPeriodicTask(
      _backgroundPeriodicTaskName,
      _backgroundSyncTaskName,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 5),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
    );
  }

  Future<void> scheduleQueuedSync() async {
    if (!_supportsBackgroundSync) {
      return;
    }

    await initialize();

    final preferences = await AppPreferences.getInstance();
    if (preferences.userId == null || preferences.businessId == null) {
      return;
    }

    if (_isQueueSyncScheduled) {
      return;
    }

    _isQueueSyncScheduled = true;

    try {
      await _workmanager.cancelByUniqueName(_backgroundQueuedTaskName);
      await _workmanager.registerOneOffTask(
        _backgroundQueuedTaskName,
        _backgroundSyncTaskName,
        initialDelay: const Duration(minutes: 1),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresStorageNotLow: true,
        ),
      );
    } finally {
      _isQueueSyncScheduled = false;
    }
  }

  Future<void> cancelAllTasks() async {
    if (!_supportsBackgroundSync) {
      return;
    }

    await initialize();
    await _workmanager.cancelAll();
  }
}
