import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:insurance_reminders/app.dart';
import 'package:insurance_reminders/core/services/notification_service.dart';
import 'package:insurance_reminders/core/theme/theme_controller.dart';
import 'package:insurance_reminders/firebase_options.dart';

const String _googleServerClientId =
    '302492772767-kjt4v9mmk9dh3n447alcadrumhi2qlq2.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await NotificationService.instance.init();
  await GoogleSignIn.instance.initialize(serverClientId: _googleServerClientId);
  Get.put(ThemeController(), permanent: true);
  runApp(const InsuranceRemindersApp());
}
