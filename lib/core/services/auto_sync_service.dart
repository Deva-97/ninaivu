import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:ninaivu/core/services/sync_service.dart';

/// Watches connectivity changes and triggers best-effort queue syncs.
///
/// This service is intentionally lightweight because the actual sync rules,
/// retries, and queue processing all live inside `SyncService`.
class AutoSyncService {
  AutoSyncService({
    SyncService? syncService,
    Connectivity? connectivity,
    Duration? debounceDuration,
  }) : _syncService = syncService ?? SyncService(),
       _connectivity = connectivity ?? Connectivity(),
       _debounceDuration = debounceDuration ?? const Duration(seconds: 2);

  final SyncService _syncService;
  final Connectivity _connectivity;
  final Duration _debounceDuration;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _debounceTimer;
  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }

    // A startup sync helps flush pending offline work even before the first
    // connectivity change event arrives from the platform stream.
    _started = true;
    _scheduleSync();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (Object error, StackTrace stackTrace) {
        FirebaseCrashlytics.instance.log(
          'Auto-sync connectivity listener failed: $error',
        );
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Auto-sync connectivity listener failure',
          fatal: false,
        );
      },
    );
  }

  Future<void> triggerSyncNow() async {
    _debounceTimer?.cancel();
    await _runSync();
  }

  Future<void> stop() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _started = false;
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOnline = !results.contains(ConnectivityResult.none);
    if (!isOnline) {
      _debounceTimer?.cancel();
      return;
    }

    _scheduleSync();
  }

  void _scheduleSync() {
    _debounceTimer?.cancel();
    // Connectivity can bounce rapidly during network transitions, so debounce
    // prevents duplicate sync attempts while the device is stabilizing.
    _debounceTimer = Timer(_debounceDuration, () {
      unawaited(_runSync());
    });
  }

  Future<void> _runSync() async {
    try {
      await _syncService.syncPendingData();
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.log('Auto-sync failed: $error');
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Auto-sync failed after connectivity change',
        fatal: false,
      );
      debugPrint('Auto-sync failed: $error');
    }
  }
}
