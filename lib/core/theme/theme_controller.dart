import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:insurance_reminders/core/services/app_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeController extends GetxController {
  final Rx<AppThemeMode> selectedThemeMode = AppThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
  }

  Future<void> loadThemeMode() async {
    final preferences = await AppPreferences.getInstance();
    final savedTheme = preferences.themeMode;

    switch (savedTheme) {
      case 'light':
        selectedThemeMode.value = AppThemeMode.light;
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        selectedThemeMode.value = AppThemeMode.dark;
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'system':
      default:
        selectedThemeMode.value = AppThemeMode.system;
        Get.changeThemeMode(ThemeMode.system);
        break;
    }
  }

  Future<void> changeThemeMode(AppThemeMode mode) async {
    final preferences = await AppPreferences.getInstance();
    selectedThemeMode.value = mode;

    switch (mode) {
      case AppThemeMode.light:
        await preferences.setThemeMode('light');
        Get.changeThemeMode(ThemeMode.light);
        break;
      case AppThemeMode.dark:
        await preferences.setThemeMode('dark');
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case AppThemeMode.system:
        await preferences.setThemeMode('system');
        Get.changeThemeMode(ThemeMode.system);
        break;
    }
  }

  bool get isDarkMode {
    if (selectedThemeMode.value == AppThemeMode.dark) {
      return true;
    }

    if (selectedThemeMode.value == AppThemeMode.light) {
      return false;
    }

    return Get.isDarkMode;
  }
}
