import 'package:flutter/material.dart';

const Locale appEnglishLocale = Locale('en', 'US');

enum AppThemeMode {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static AppThemeMode fromName(String? value) {
    return AppThemeMode.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
