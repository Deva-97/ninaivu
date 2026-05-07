import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:insurance_reminders/app.dart';
import 'package:insurance_reminders/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const InsuranceRemindersApp());
}
