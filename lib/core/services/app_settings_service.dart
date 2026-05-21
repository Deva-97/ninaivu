import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/localization/app_locale.dart';
import 'package:ninaivu/core/services/app_preferences.dart';

class AppSettingsService extends GetxService {
  final language = AppLanguage.english.obs;
  final themeMode = AppThemeMode.system.obs;

  Future<AppSettingsService> init() async {
    final preferences = await AppPreferences.getInstance();
    language.value = AppLanguage.fromCode(preferences.languageCode);
    themeMode.value = AppThemeMode.fromName(preferences.themeMode);
    return this;
  }

  Locale get locale => language.value.locale;
  ThemeMode get materialThemeMode => themeMode.value.themeMode;

  Future<void> updateLanguage(AppLanguage value) async {
    language.value = value;
    final preferences = await AppPreferences.getInstance();
    await preferences.setLanguageCode(value.languageCode);
    await Get.updateLocale(value.locale);
  }

  Future<void> updateThemeMode(AppThemeMode value) async {
    themeMode.value = value;
    final preferences = await AppPreferences.getInstance();
    await preferences.setThemeMode(value.name);
    Get.changeThemeMode(value.themeMode);
  }
}
