import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/app_constants.dart';
import 'package:ninaivu/core/localization/app_locale.dart';
import 'package:ninaivu/core/localization/app_translations.dart';
import 'package:ninaivu/core/services/app_settings_service.dart';
import 'package:ninaivu/presentation/modules/common/widgets/app_lock_overlay.dart';
import 'package:ninaivu/core/theme/app_theme.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';
import 'package:ninaivu/presentation/routes/app_pages.dart';
import 'package:ninaivu/presentation/routes/app_routes.dart';

/// Root application widget that wires theme, localization, routing, and the
/// global app-lock overlay in one place.
class InsuranceRemindersApp extends StatelessWidget {
  const InsuranceRemindersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<AppSettingsService>();
    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appName,
        initialRoute: AppRoutes.splashScreen,
        getPages: AppPages.pages,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsService.materialThemeMode,
        translations: AppTranslations(),
        locale: settingsService.locale,
        fallbackLocale: AppLanguage.english.locale,
        supportedLocales: AppLanguage.values.map((item) => item.locale).toList(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          // The responsive helper scales the active theme so the same design
          // system feels consistent across phone and larger form factors.
          final responsive = context.responsive;
          final baseTheme = Theme.of(context);
          final scaledTheme = AppTheme.scaleTheme(baseTheme, responsive.scale);

          return Theme(
            data: scaledTheme,
            child: AppLockOverlay(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}
