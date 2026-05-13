import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/constants/app_constants.dart';
import 'package:insurance_reminders/core/theme/app_theme.dart';
import 'package:insurance_reminders/presentation/routes/app_pages.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class InsuranceRemindersApp extends StatelessWidget {
  const InsuranceRemindersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      // initialBinding: Binding(),`
      initialRoute: AppRoutes.splashScreen,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
