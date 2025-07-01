// lib/app/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  static const String _key = 'theme_mode';
  final GetStorage _box = GetStorage();

  ThemeMode get theme => _loadThemeFromBox();

  ThemeMode _loadThemeFromBox() {
    final themeIndex = _box.read(_key) ?? 0;
    switch (themeIndex) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void saveThemeToBox(ThemeMode themeMode) {
    int themeIndex = 0;
    switch (themeMode) {
      case ThemeMode.system:
        themeIndex = 0;
        break;
      case ThemeMode.light:
        themeIndex = 1;
        break;
      case ThemeMode.dark:
        themeIndex = 2;
        break;
    }
    _box.write(_key, themeIndex);
  }

  void changeThemeMode(ThemeMode themeMode) {
    Get.changeThemeMode(themeMode);
    saveThemeToBox(themeMode);
  }

  String getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'system'.tr;
      case ThemeMode.light:
        return 'light'.tr;
      case ThemeMode.dark:
        return 'dark'.tr;
    }
  }

  IconData getThemeModeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_high;
      case ThemeMode.dark:
        return Icons.brightness_2;
    }
  }
}