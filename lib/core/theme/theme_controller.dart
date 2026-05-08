import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeController extends GetxController {
  static const String _themeKey = 'app_theme_mode';

  final Rx<AppThemeMode> selectedThemeMode = AppThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

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
    final prefs = await SharedPreferences.getInstance();

    selectedThemeMode.value = mode;

    switch (mode) {
      case AppThemeMode.light:
        await prefs.setString(_themeKey, 'light');
        Get.changeThemeMode(ThemeMode.light);
        break;

      case AppThemeMode.dark:
        await prefs.setString(_themeKey, 'dark');
        Get.changeThemeMode(ThemeMode.dark);
        break;

      case AppThemeMode.system:
        await prefs.setString(_themeKey, 'system');
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
