import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/themes/app_themes.dart';
import '../../core/constants/api_constants.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _storage = GetStorage();

  // Observable theme mode
  final Rx<AppThemeMode> _themeMode = AppThemeMode.system.obs;

  // Getters
  AppThemeMode get themeMode => _themeMode.value;
  ThemeMode get currentThemeMode => AppThemes.getThemeMode(_themeMode.value);
  String get themeName => AppThemes.getThemeName(_themeMode.value);

  // Check if current theme is dark
  bool get isDarkMode {
    switch (_themeMode.value) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return Get.isPlatformDarkMode;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  // Load theme from storage
  void _loadThemeFromStorage() {
    final storedTheme = _storage.read<String>(CacheKeys.appTheme);
    _themeMode.value = AppThemes.themeModeFromString(storedTheme);
    _updateSystemUI();
  }

  // Save theme to storage
  void _saveThemeToStorage() {
    _storage.write(CacheKeys.appTheme, AppThemes.themeModeToString(_themeMode.value));
  }

  // Change theme mode
  void changeThemeMode(AppThemeMode mode) {
    _themeMode.value = mode;
    _saveThemeToStorage();
    _updateSystemUI();

    // Update GetX theme
    Get.changeThemeMode(AppThemes.getThemeMode(mode));

    // Show feedback to user
    _showThemeChangeSnackbar(mode);
  }

  // Toggle between light and dark (ignoring system)
  void toggleTheme() {
    if (_themeMode.value == AppThemeMode.light) {
      changeThemeMode(AppThemeMode.dark);
    } else {
      changeThemeMode(AppThemeMode.light);
    }
  }

  // Set light theme
  void setLightTheme() {
    changeThemeMode(AppThemeMode.light);
  }

  // Set dark theme
  void setDarkTheme() {
    changeThemeMode(AppThemeMode.dark);
  }

  // Set system theme
  void setSystemTheme() {
    changeThemeMode(AppThemeMode.system);
  }

  // Update system UI based on current theme
  void _updateSystemUI() {
    // This will be called when theme changes
    // You can add any additional system UI updates here
  }

  // Show snackbar when theme changes
  void _showThemeChangeSnackbar(AppThemeMode mode) {
    final themeName = AppThemes.getThemeName(mode);

    Get.snackbar(
      'Mavzu o\'zgartirildi',
      '$themeName tanlandi',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDarkMode
          ? const Color(0xFF252525)
          : const Color(0xFFF8F9FA),
      colorText: isDarkMode
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF1A1A1A),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(
        _getThemeIcon(mode),
        color: isDarkMode
            ? const Color(0xFF64B5F6)
            : const Color(0xFF2E7EE5),
      ),
    );
  }

  // Get appropriate icon for theme mode
  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  // Get available theme options for UI
  List<ThemeOption> get themeOptions => [
    ThemeOption(
      mode: AppThemeMode.light,
      name: 'Yorug\' mavzu',
      description: 'Yorug\' rang pallitasi',
      icon: Icons.light_mode,
    ),
    ThemeOption(
      mode: AppThemeMode.dark,
      name: 'Qorong\' mavzu',
      description: 'Qorong\' rang pallitasi',
      icon: Icons.dark_mode,
    ),
    ThemeOption(
      mode: AppThemeMode.system,
      name: 'Tizim mavzusi',
      description: 'Qurilma sozlamasi bo\'yicha',
      icon: Icons.brightness_auto,
    ),
  ];

  // Get current theme colors
  AppThemeColors getCurrentColors(BuildContext context) {
    return AppThemes.getCurrentColors(context);
  }

  // Reset to default theme
  void resetToDefault() {
    changeThemeMode(AppThemeMode.system);
  }

  // Check if theme mode is currently selected
  bool isSelected(AppThemeMode mode) {
    return _themeMode.value == mode;
  }
}

// Theme option model for UI
class ThemeOption {
  final AppThemeMode mode;
  final String name;
  final String description;
  final IconData icon;

  const ThemeOption({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
  });
}

// Binding for theme controller
class ThemeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
  }
}