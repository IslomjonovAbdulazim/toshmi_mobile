import 'package:flutter/material.dart';

class AppConstants {
  // ===================== APP INFO =====================
  static const String appName = 'Toshmi Mobile';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String supportEmail = 'support@toshmi.uz';
  static const String supportPhone = '+998 71 123 45 67';

  // ===================== API CONFIGURATION =====================
  static const String baseUrl = 'https://islomjonovabdulazim-toshmi-backend-0914.twc1.net';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration downloadTimeout = Duration(minutes: 10);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // ===================== CACHE CONFIGURATION =====================
  static const Duration cacheValidDuration = Duration(minutes: 30);
  static const Duration backgroundRefreshInterval = Duration(minutes: 15);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheCleanupInterval = Duration(days: 7);

  // ===================== FILE CONFIGURATION =====================
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  static const int maxProfileImageSize = 2 * 1024 * 1024; // 2MB
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> supportedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'];
  static const int maxFilesPerHomework = 3;
  static const int maxFilesPerExam = 3;

  // ===================== UI DIMENSIONS =====================
  static const double borderRadius = 8.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const double avatarRadius = 20.0;

  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  static const double marginXS = 4.0;
  static const double marginSM = 8.0;
  static const double marginMD = 16.0;
  static const double marginLG = 24.0;
  static const double marginXL = 32.0;

  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 48.0;

  static const double elevationLow = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationHigh = 8.0;

  static const double strokeWidth = 1.0;
  static const double strokeWidthThick = 2.0;

  // ===================== TYPOGRAPHY =====================
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeHeading = 28.0;

  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // ===================== COLORS =====================
  // Primary Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryColorLight = Color(0xFF64B5F6);
  static const Color primaryColorDark = Color(0xFF1976D2);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color secondaryColorLight = Color(0xFF81C784);
  static const Color secondaryColorDark = Color(0xFF388E3C);

  // Accent Colors
  static const Color accentColor = Color(0xFFFF9800);
  static const Color accentColorLight = Color(0xFFFFB74D);
  static const Color accentColorDark = Color(0xFFF57C00);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textDisabledColor = Color(0xFFBDBDBD);
  static const Color textHintColor = Color(0xFF9E9E9E);
  static const Color textLinkColor = Color(0xFF2196F3);

  // Special Colors
  static const Color shadowColor = Color(0x1F000000);
  static const Color overlayColor = Color(0x80000000);
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);

  // Grade Colors
  static const Color gradeExcellent = Color(0xFF4CAF50); // Green
  static const Color gradeGood = Color(0xFF2196F3); // Blue
  static const Color gradeSatisfactory = Color(0xFFFF9800); // Orange
  static const Color gradeUnsatisfactory = Color(0xFFF44336); // Red

  // Attendance Colors
  static const Color attendancePresent = Color(0xFF4CAF50); // Green
  static const Color attendanceAbsent = Color(0xFFF44336); // Red
  static const Color attendanceLate = Color(0xFFFF9800); // Orange
  static const Color attendanceExcused = Color(0xFF2196F3); // Blue

  // ===================== ANIMATIONS =====================
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration loadingDuration = Duration(milliseconds: 1500);
  static const Duration refreshDuration = Duration(seconds: 1);

  static const Curve animationCurve = Curves.easeInOut;
  static const Curve animationCurveFast = Curves.easeOut;
  static const Curve animationCurveBounce = Curves.bounceOut;

  // ===================== PAGINATION =====================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 10;
  static const int loadMoreThreshold = 5; // Items from bottom to trigger load more

  // ===================== SEARCH & FILTERS =====================
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const int minSearchLength = 2;
  static const int maxSearchLength = 100;
  static const int maxRecentSearches = 10;

  // ===================== NOTIFICATION SETTINGS =====================
  static const Duration notificationDisplayDuration = Duration(seconds: 4);
  static const Duration notificationFadeInDuration = Duration(milliseconds: 300);
  static const Duration notificationFadeOutDuration = Duration(milliseconds: 300);
  static const int maxNotificationsInQueue = 5;

  // ===================== SECURITY =====================
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration autoLockDelay = Duration(minutes: 15);
  static const int maxLoginAttempts = 5;
  static const Duration loginCooldownDuration = Duration(minutes: 15);

  // ===================== GRADE THRESHOLDS =====================
  static const int gradeExcellentMin = 90;
  static const int gradeGoodMin = 70;
  static const int gradeSatisfactoryMin = 50;
  static const int gradeUnsatisfactoryMax = 49;

  // ===================== ATTENDANCE THRESHOLDS =====================
  static const double attendanceExcellentMin = 95.0;
  static const double attendanceGoodMin = 85.0;
  static const double attendanceSatisfactoryMin = 70.0;
  static const double attendanceWarningMax = 69.0;

  // ===================== HOMEWORK & EXAM SETTINGS =====================
  static const int homeworkOverdueDays = 0; // Days after due date to mark as overdue
  static const int homeworkDueSoonDays = 3; // Days before due date to mark as due soon
  static const int examReminderDays = 7; // Days before exam to show reminders
  static const int maxHomeworkDescriptionLength = 500;
  static const int maxExamDescriptionLength = 500;
  static const int maxCommentLength = 200;

  // ===================== UI BEHAVIOR =====================
  static const double listRefreshTriggerDistance = 80.0;
  static const double scrollToTopThreshold = 200.0;
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration longPressDelay = Duration(milliseconds: 500);
  static const int maxUndoHistorySize = 10;

  // ===================== BREAKPOINTS =====================
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // ===================== VALIDATION RULES =====================
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;
  static const int maxEmailLength = 100;

  // ===================== DATE & TIME FORMATS =====================
  static const String dateFormat = 'dd.MM.yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String shortDateFormat = 'dd.MM';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String dayMonthFormat = 'dd MMMM';

  // ===================== REGEX PATTERNS =====================
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,30}$';
  static const String namePattern = r'^[a-zA-ZА-Яа-яЁё\s]{2,50}$';

  // ===================== STORAGE KEYS =====================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String cacheKey = 'app_cache';
  static const String firstTimeKey = 'first_time';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  // ===================== FEATURE FLAGS =====================
  static const bool enableOfflineMode = true;
  static const bool enableDebugMode = false;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableBiometrics = true;
  static const bool enableNotifications = true;

  // ===================== DEVELOPMENT =====================
  static const bool showDebugInfo = false;
  static const bool logApiCalls = true;
  static const bool logCacheOperations = false;
  static const bool showPerformanceOverlay = false;

  // Helper methods
  static bool isSmallScreen(double width) => width < mobileBreakpoint;
  static bool isMediumScreen(double width) => width >= mobileBreakpoint && width < tabletBreakpoint;
  static bool isLargeScreen(double width) => width >= tabletBreakpoint;

  static Color getGradeColor(int points, int maxPoints) {
    final percentage = (points / maxPoints) * 100;
    if (percentage >= gradeExcellentMin) return gradeExcellent;
    if (percentage >= gradeGoodMin) return gradeGood;
    if (percentage >= gradeSatisfactoryMin) return gradeSatisfactory;
    return gradeUnsatisfactory;
  }

  static Color getAttendanceColor(double percentage) {
    if (percentage >= attendanceExcellentMin) return attendancePresent;
    if (percentage >= attendanceGoodMin) return gradeGood;
    if (percentage >= attendanceSatisfactoryMin) return warningColor;
    return errorColor;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static bool isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(phonePattern).hasMatch(phone);
  }

  static bool isValidUsername(String username) {
    return RegExp(usernamePattern).hasMatch(username);
  }
}