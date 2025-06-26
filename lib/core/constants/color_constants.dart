import 'package:flutter/material.dart';

/// Educational Color Palette for School Management System
/// This file contains all color constants used throughout the app
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ===================== LIGHT THEME COLORS =====================

  // Primary Educational Colors (Light Mode)
  static const Color lightPrimaryBlue = Color(0xFF2E7EE5); // Knowledge Blue
  static const Color lightSecondaryTeal = Color(0xFF00BCD4); // Fresh Learning Teal
  static const Color lightAccentOrange = Color(0xFFFF6F00); // Creative Orange
  static const Color lightSuccessGreen = Color(0xFF4CAF50); // Achievement Green
  static const Color lightWarningAmber = Color(0xFFFFC107); // Attention Amber
  static const Color lightErrorRed = Color(0xFFE53935); // Alert Red
  static const Color lightPurpleWisdom = Color(0xFF7B1FA2); // Wisdom Purple

  // Background Colors (Light Mode)
  static const Color lightBackgroundWhite = Color(0xFFFAFAFA);
  static const Color lightSurfaceWhite = Color(0xFFFFFFFF);
  static const Color lightCardWhite = Color(0xFFF8F9FA);

  // Text Colors (Light Mode)
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // Border & Divider Colors (Light Mode)
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFEEEEEE);

  // ===================== DARK THEME COLORS =====================

  // Primary Educational Colors (Dark Mode)
  static const Color darkPrimaryBlue = Color(0xFF64B5F6); // Lighter Blue for dark mode
  static const Color darkSecondaryTeal = Color(0xFF4DD0E1); // Bright Teal
  static const Color darkAccentOrange = Color(0xFFFFB74D); // Warm Orange
  static const Color darkSuccessGreen = Color(0xFF81C784); // Soft Green
  static const Color darkWarningAmber = Color(0xFFFFD54F); // Bright Amber
  static const Color darkErrorRed = Color(0xFFEF5350); // Soft Red
  static const Color darkPurpleWisdom = Color(0xFFBA68C8); // Light Purple

  // Background Colors (Dark Mode)
  static const Color darkBackgroundDark = Color(0xFF121212);
  static const Color darkSurfaceDark = Color(0xFF1E1E1E);
  static const Color darkCardDark = Color(0xFF252525);

  // Text Colors (Dark Mode)
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF808080);

  // Border & Divider Colors (Dark Mode)
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkDivider = Color(0xFF333333);

  // ===================== FEATURE-SPECIFIC COLORS =====================

  // Academic Features
  static const Color homeworkBlue = Color(0xFF2196F3);
  static const Color examPurple = Color(0xFF9C27B0);
  static const Color gradeGreen = Color(0xFF4CAF50);
  static const Color attendanceTeal = Color(0xFF00BCD4);
  static const Color paymentOrange = Color(0xFFFF9800);
  static const Color notificationAmber = Color(0xFFFFC107);
  static const Color scheduleIndigo = Color(0xFF3F51B5);
  static const Color newsBlue = Color(0xFF2196F3);

  // ===================== GRADE COLORS =====================

  // Light Mode Grade Colors
  static const Color lightExcellentGrade = Color(0xFF4CAF50); // Green (90-100%)
  static const Color lightGoodGrade = Color(0xFF2196F3); // Blue (70-89%)
  static const Color lightAverageGrade = Color(0xFFFF9800); // Orange (50-69%)
  static const Color lightPoorGrade = Color(0xFFF44336); // Red (0-49%)

  // Dark Mode Grade Colors
  static const Color darkExcellentGrade = Color(0xFF81C784); // Soft Green
  static const Color darkGoodGrade = Color(0xFF64B5F6); // Light Blue
  static const Color darkAverageGrade = Color(0xFFFFB74D); // Light Orange
  static const Color darkPoorGrade = Color(0xFFEF5350); // Soft Red

  // ===================== ATTENDANCE COLORS =====================

  // Light Mode Attendance Colors
  static const Color lightPresentColor = Color(0xFF4CAF50); // Green
  static const Color lightAbsentColor = Color(0xFFF44336); // Red
  static const Color lightLateColor = Color(0xFFFF9800); // Orange
  static const Color lightExcusedColor = Color(0xFF9C27B0); // Purple

  // Dark Mode Attendance Colors
  static const Color darkPresentColor = Color(0xFF81C784); // Soft Green
  static const Color darkAbsentColor = Color(0xFFEF5350); // Soft Red
  static const Color darkLateColor = Color(0xFFFFB74D); // Light Orange
  static const Color darkExcusedColor = Color(0xFFBA68C8); // Light Purple

  // ===================== STATUS COLORS =====================

  // Success variations
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color successMain = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);

  // Warning variations
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color warningMain = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFE65100);

  // Error variations
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorMain = Color(0xFFF44336);
  static const Color errorDark = Color(0xFFB71C1C);

  // Info variations
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color infoMain = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF0D47A1);

  // ===================== ROLE-BASED COLORS =====================

  // User role colors
  static const Color adminColor = Color(0xFF673AB7); // Deep Purple
  static const Color teacherColor = Color(0xFF2196F3); // Blue
  static const Color studentColor = Color(0xFF4CAF50); // Green
  static const Color parentColor = Color(0xFFFF9800); // Orange

  // ===================== UTILITY COLORS =====================

  // Transparent colors
  static const Color transparent = Colors.transparent;
  static const Color semiTransparentBlack = Color(0x80000000);
  static const Color semiTransparentWhite = Color(0x80FFFFFF);

  // Overlay colors
  static const Color modalOverlay = Color(0x4D000000);
  static const Color dialogOverlay = Color(0x66000000);

  // Shimmer colors (for loading states)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF424242);
  static const Color shimmerHighlightDark = Color(0xFF616161);

  // ===================== HELPER METHODS =====================

  /// Get grade color based on percentage and theme
  static Color getGradeColor(double percentage, {bool isDark = false}) {
    if (percentage >= 90) {
      return isDark ? darkExcellentGrade : lightExcellentGrade;
    } else if (percentage >= 70) {
      return isDark ? darkGoodGrade : lightGoodGrade;
    } else if (percentage >= 50) {
      return isDark ? darkAverageGrade : lightAverageGrade;
    } else {
      return isDark ? darkPoorGrade : lightPoorGrade;
    }
  }

  /// Get attendance color based on status and theme
  static Color getAttendanceColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'present':
        return isDark ? darkPresentColor : lightPresentColor;
      case 'absent':
        return isDark ? darkAbsentColor : lightAbsentColor;
      case 'late':
        return isDark ? darkLateColor : lightLateColor;
      case 'excused':
        return isDark ? darkExcusedColor : lightExcusedColor;
      default:
        return isDark ? darkTextSecondary : lightTextSecondary;
    }
  }

  /// Get user role color
  static Color getUserRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return adminColor;
      case 'teacher':
        return teacherColor;
      case 'student':
        return studentColor;
      case 'parent':
        return parentColor;
      default:
        return lightTextSecondary;
    }
  }

  /// Get feature color by type
  static Color getFeatureColor(String featureType) {
    switch (featureType.toLowerCase()) {
      case 'homework':
        return homeworkBlue;
      case 'exam':
        return examPurple;
      case 'grade':
        return gradeGreen;
      case 'attendance':
        return attendanceTeal;
      case 'payment':
        return paymentOrange;
      case 'notification':
        return notificationAmber;
      case 'schedule':
        return scheduleIndigo;
      case 'news':
        return newsBlue;
      default:
        return lightPrimaryBlue;
    }
  }

  /// Create a lighter version of a color
  static Color lighten(Color color, [double factor = 0.1]) {
    return Color.lerp(color, Colors.white, factor) ?? color;
  }

  /// Create a darker version of a color
  static Color darken(Color color, [double factor = 0.1]) {
    return Color.lerp(color, Colors.black, factor) ?? color;
  }

  /// Get contrast color (black or white) for a given background color
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Check if a color is considered dark
  static bool isColorDark(Color color) {
    return color.computeLuminance() < 0.5;
  }
}