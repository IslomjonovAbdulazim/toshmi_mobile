import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class AppThemes {
  // Theme instances
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;

  // Theme mode getter
  static ThemeMode getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Theme mode names for UI display
  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Yorug\' mavzu';
      case AppThemeMode.dark:
        return 'Qorong\' mavzu';
      case AppThemeMode.system:
        return 'Tizim mavzusi';
    }
  }

  // Theme mode from string (for storage)
  static AppThemeMode themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }

  // Theme mode to string (for storage)
  static String themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  // Get current theme colors based on brightness
  static AppThemeColors getCurrentColors(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light
        ? LightThemeColors()
        : DarkThemeColors();
  }

  // Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Get appropriate text color for background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Get status bar brightness for theme
  static Brightness getStatusBarBrightness(BuildContext context) {
    return isDarkMode(context) ? Brightness.light : Brightness.dark;
  }
}

// Abstract class for theme colors
abstract class AppThemeColors {
  // Feature-specific colors
  Color get homework;
  Color get exam;
  Color get grade;
  Color get attendance;
  Color get payment;
  Color get notification;

  // Grade-specific colors
  Color get excellentGrade;
  Color get goodGrade;
  Color get averageGrade;
  Color get poorGrade;

  // Attendance-specific colors
  Color get presentColor;
  Color get absentColor;
  Color get lateColor;
  Color get excusedColor;

  // Status colors
  Color get success;
  Color get warning;
  Color get error;
  Color get info;

  // Background variations
  Color get primaryBackground;
  Color get secondaryBackground;
  Color get cardBackground;

  // Text variations
  Color get primaryText;
  Color get secondaryText;
  Color get tertiaryText;

  // Border and divider
  Color get border;
  Color get divider;
}

// Light theme colors implementation
class LightThemeColors extends AppThemeColors {
  @override
  Color get homework => LightTheme.homeworkColor;

  @override
  Color get exam => LightTheme.examColor;

  @override
  Color get grade => LightTheme.gradeColor;

  @override
  Color get attendance => LightTheme.attendanceColor;

  @override
  Color get payment => LightTheme.paymentColor;

  @override
  Color get notification => LightTheme.notificationColor;

  @override
  Color get excellentGrade => LightTheme.excellentGrade;

  @override
  Color get goodGrade => LightTheme.goodGrade;

  @override
  Color get averageGrade => LightTheme.averageGrade;

  @override
  Color get poorGrade => LightTheme.poorGrade;

  @override
  Color get presentColor => LightTheme.presentColor;

  @override
  Color get absentColor => LightTheme.absentColor;

  @override
  Color get lateColor => LightTheme.lateColor;

  @override
  Color get excusedColor => LightTheme.excusedColor;

  @override
  Color get success => LightTheme.successGreen;

  @override
  Color get warning => LightTheme.warningAmber;

  @override
  Color get error => LightTheme.errorRed;

  @override
  Color get info => LightTheme.primaryBlue;

  @override
  Color get primaryBackground => LightTheme.backgroundWhite;

  @override
  Color get secondaryBackground => LightTheme.surfaceWhite;

  @override
  Color get cardBackground => LightTheme.cardWhite;

  @override
  Color get primaryText => LightTheme.textPrimary;

  @override
  Color get secondaryText => LightTheme.textSecondary;

  @override
  Color get tertiaryText => LightTheme.textTertiary;

  @override
  Color get border => LightTheme.borderLight;

  @override
  Color get divider => LightTheme.dividerColor;
}

// Dark theme colors implementation
class DarkThemeColors extends AppThemeColors {
  @override
  Color get homework => DarkTheme.homeworkColor;

  @override
  Color get exam => DarkTheme.examColor;

  @override
  Color get grade => DarkTheme.gradeColor;

  @override
  Color get attendance => DarkTheme.attendanceColor;

  @override
  Color get payment => DarkTheme.paymentColor;

  @override
  Color get notification => DarkTheme.notificationColor;

  @override
  Color get excellentGrade => DarkTheme.excellentGrade;

  @override
  Color get goodGrade => DarkTheme.goodGrade;

  @override
  Color get averageGrade => DarkTheme.averageGrade;

  @override
  Color get poorGrade => DarkTheme.poorGrade;

  @override
  Color get presentColor => DarkTheme.presentColor;

  @override
  Color get absentColor => DarkTheme.absentColor;

  @override
  Color get lateColor => DarkTheme.lateColor;

  @override
  Color get excusedColor => DarkTheme.excusedColor;

  @override
  Color get success => DarkTheme.successGreen;

  @override
  Color get warning => DarkTheme.warningAmber;

  @override
  Color get error => DarkTheme.errorRed;

  @override
  Color get info => DarkTheme.primaryBlue;

  @override
  Color get primaryBackground => DarkTheme.backgroundDark;

  @override
  Color get secondaryBackground => DarkTheme.surfaceDark;

  @override
  Color get cardBackground => DarkTheme.cardDark;

  @override
  Color get primaryText => DarkTheme.textPrimary;

  @override
  Color get secondaryText => DarkTheme.textSecondary;

  @override
  Color get tertiaryText => DarkTheme.textTertiary;

  @override
  Color get border => DarkTheme.borderDark;

  @override
  Color get divider => DarkTheme.dividerDark;
}

// Helper extension for quick access to theme colors
extension ThemeColorsExtension on BuildContext {
  AppThemeColors get colors => AppThemes.getCurrentColors(this);

  bool get isDarkMode => AppThemes.isDarkMode(this);

  Brightness get statusBarBrightness => AppThemes.getStatusBarBrightness(this);
}