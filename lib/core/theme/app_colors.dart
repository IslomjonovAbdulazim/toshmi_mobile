import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);

  // Secondary Colors
  static const Color secondaryOrange = Color(0xFFFF9800);
  static const Color secondaryOrangeLight = Color(0xFFFFB74D);
  static const Color secondaryOrangeDark = Color(0xFFF57C00);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOnBackground = Color(0xFF1C1C1E);
  static const Color lightOnSurface = Color(0xFF1C1C1E);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnBackground = Color(0xFFE1E1E1);
  static const Color darkOnSurface = Color(0xFFE1E1E1);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);

  // Status Colors (Same for both themes)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Role Colors
  static const Color teacherColor = Color(0xFF9C27B0);
  static const Color studentColor = Color(0xFF4CAF50);
  static const Color parentColor = Color(0xFFFF5722);
  static const Color adminColor = Color(0xFF607D8B);

  // Grade Colors
  static const Color gradeExcellent = Color(0xFF4CAF50);
  static const Color gradeGood = Color(0xFF8BC34A);
  static const Color gradeAverage = Color(0xFFFF9800);
  static const Color gradePoor = Color(0xFFF44336);

  // Attendance Colors
  static const Color present = Color(0xFF4CAF50);
  static const Color absent = Color(0xFFF44336);
  static const Color late = Color(0xFFFF9800);
  static const Color excused = Color(0xFF2196F3);

  // Light Theme ColorScheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: lightOnPrimary,
    secondary: secondaryOrange,
    onSecondary: lightOnSecondary,
    error: error,
    onError: Colors.white,
    background: lightBackground,
    onBackground: lightOnBackground,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceVariant: lightSurfaceVariant,
    onSurfaceVariant: Color(0xFF666666),
    outline: Color(0xFFCCCCCC),
    shadow: Color(0x1A000000),
  );

  // Dark Theme ColorScheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryBlueLight,
    onPrimary: darkOnPrimary,
    secondary: secondaryOrangeLight,
    onSecondary: darkOnSecondary,
    error: error,
    onError: Colors.white,
    background: darkBackground,
    onBackground: darkOnBackground,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceVariant: darkSurfaceVariant,
    onSurfaceVariant: Color(0xFFB3B3B3),
    outline: Color(0xFF404040),
    shadow: Color(0x33000000),
  );

  // Utility Methods
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'teacher':
        return teacherColor;
      case 'student':
        return studentColor;
      case 'parent':
        return parentColor;
      case 'admin':
        return adminColor;
      default:
        return primaryBlue;
    }
  }

  static Color getGradeColor(double percentage) {
    if (percentage >= 90) return gradeExcellent;
    if (percentage >= 75) return gradeGood;
    if (percentage >= 60) return gradeAverage;
    return gradePoor;
  }

  static Color getAttendanceColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return present;
      case 'absent':
        return absent;
      case 'late':
        return late;
      case 'excused':
        return excused;
      default:
        return info;
    }
  }
}