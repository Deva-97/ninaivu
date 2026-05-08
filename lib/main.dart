import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:insurance_reminders/app.dart';
import 'package:insurance_reminders/core/theme/theme_controller.dart';
import 'package:insurance_reminders/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(ThemeController(), permanent: true);
  runApp(const InsuranceRemindersApp());
}
