import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:ninaivu/app.dart';
import 'package:ninaivu/core/services/app_lifecycle_service.dart';
import 'package:ninaivu/core/services/app_lock_service.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/app_settings_service.dart';
import 'package:ninaivu/core/services/auto_sync_service.dart';
import 'package:ninaivu/core/services/background_sync_service.dart';
import 'package:ninaivu/core/services/notification_service.dart';
import 'package:ninaivu/firebase_options.dart';

final AutoSyncService _autoSyncService = AutoSyncService();
final BackgroundSyncService _backgroundSyncService =
    BackgroundSyncService.instance;
// App lock is registered once at startup because multiple widgets depend on the
// same lock state during foreground/background transitions.
final AppLockService _appLockService = Get.put(
  AppLockService(),
  permanent: true,
);
// Lifecycle hooks centralize "resume" side effects so the app refreshes
// notifications and sync state from one place instead of every screen.
final AppLifecycleService _appLifecycleService = AppLifecycleService(
  onBackground: _appLockService.markAppBackgrounded,
  onResume: () async {
    _appLockService.handleAppResumed();
    await NotificationService.instance.init();
    await _backgroundSyncService.scheduleQueuedSync();
    await _autoSyncService.triggerSyncNow();
  },
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase and preferences must be ready before any route or background task
  // attempts to read session, sync, or notification state.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await _backgroundSyncService.initialize();
  await NotificationService.instance.init();
  await AppPreferences.getInstance();
  await Get.putAsync(() => AppSettingsService().init(), permanent: true);
  await _appLockService.init();
  await _autoSyncService.start();
  await _backgroundSyncService.ensureRegistered();
  _appLifecycleService.start();
  runApp(const InsuranceRemindersApp());
}
