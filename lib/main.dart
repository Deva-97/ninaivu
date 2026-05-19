import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ninaivu/app.dart';
import 'package:ninaivu/core/services/app_lifecycle_service.dart';
import 'package:ninaivu/core/services/app_lock_service.dart';
import 'package:ninaivu/core/services/app_preferences.dart';
import 'package:ninaivu/core/services/auto_sync_service.dart';
import 'package:ninaivu/core/services/background_sync_service.dart';
import 'package:ninaivu/core/services/notification_service.dart';
import 'package:ninaivu/firebase_options.dart';

const String _googleServerClientId =
    '302492772767-kjt4v9mmk9dh3n447alcadrumhi2qlq2.apps.googleusercontent.com';
final AutoSyncService _autoSyncService = AutoSyncService();
final BackgroundSyncService _backgroundSyncService =
    BackgroundSyncService.instance;
final AppLockService _appLockService = Get.put(
  AppLockService(),
  permanent: true,
);
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await _backgroundSyncService.initialize();
  await NotificationService.instance.init();
  await GoogleSignIn.instance.initialize(serverClientId: _googleServerClientId);
  await AppPreferences.getInstance();
  await _appLockService.init();
  await _autoSyncService.start();
  await _backgroundSyncService.ensureRegistered();
  _appLifecycleService.start();
  runApp(const InsuranceRemindersApp());
}
