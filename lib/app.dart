import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/constants/app_constants.dart';
import 'package:insurance_reminders/core/theme/app_theme.dart';
import 'package:insurance_reminders/core/widgets/responsive_layout.dart';
import 'package:insurance_reminders/presentation/routes/app_pages.dart';
import 'package:insurance_reminders/presentation/routes/app_routes.dart';

class InsuranceRemindersApp extends StatelessWidget {
  const InsuranceRemindersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      initialRoute: AppRoutes.splashScreen,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final responsive = context.responsive;
        final baseTheme = Theme.of(context);
        final scaledTheme = AppTheme.scaleTheme(baseTheme, responsive.scale);

        return Theme(
          data: scaledTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
