import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/localization/app_locale.dart';
import 'package:ninaivu/core/services/app_preferences.dart';

class AppSettingsService extends GetxService {
  final themeMode = AppThemeMode.system.obs;

  Future<AppSettingsService> init() async {
    final preferences = await AppPreferences.getInstance();
    themeMode.value = AppThemeMode.fromName(preferences.themeMode);
    return this;
  }

  ThemeMode get materialThemeMode => themeMode.value.themeMode;

  Future<void> updateThemeMode(AppThemeMode value) async {
    themeMode.value = value;
    final preferences = await AppPreferences.getInstance();
    await preferences.setThemeMode(value.name);
    Get.changeThemeMode(value.themeMode);
  }
}
