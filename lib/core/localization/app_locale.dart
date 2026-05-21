import 'package:flutter/material.dart';

enum AppLanguage {
  english('en', 'US'),
  tamil('ta', 'IN'),
  telugu('te', 'IN');

  const AppLanguage(this.languageCode, this.countryCode);

  final String languageCode;
  final String countryCode;

  Locale get locale => Locale(languageCode, countryCode);

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (value) => value.languageCode == code,
      orElse: () => AppLanguage.english,
    );
  }
}

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
