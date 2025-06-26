class AppConfig {
  // Private constructor
  AppConfig._();

  // ===================== API CONFIGURATION =====================

  // Base URL - Change this to your backend URL
  static const String baseUrl = 'https://islomjonovabdulazim-toshmi-backend-0914.twc1.net';
  static const String apiVersion = 'v1';
  static const String fullApiUrl = '$baseUrl/api/$apiVersion';

  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(minutes: 5); // For file uploads

  // ===================== APP INFORMATION =====================

  static const String appName = 'Toshmi Mobile';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Support Information
  static const String supportEmail = 'support@toshmi.uz';
  static const String supportPhone = '+998 71 123 45 67';
  static const String websiteUrl = 'https://toshmi.uz';

  // ===================== STORAGE KEYS =====================

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String firstTimeKey = 'first_time_user';
  static const String notificationKey = 'notifications_enabled';

  // ===================== CACHE CONFIGURATION =====================

  static const Duration cacheValidDuration = Duration(minutes: 30);
  static const Duration backgroundRefreshInterval = Duration(minutes: 15);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheCleanupInterval = Duration(days: 7);

  // ===================== FILE CONFIGURATION =====================

  // File size limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  static const int maxProfileImageSize = 2 * 1024 * 1024; // 2MB

  // Supported file types
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> supportedDocumentTypes = [
    'pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'
  ];

  // File limits per entity
  static const int maxFilesPerHomework = 3;
  static const int maxFilesPerExam = 3;

  // ===================== SECURITY CONFIGURATION =====================

  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration autoLockDelay = Duration(minutes: 15);
  static const int maxLoginAttempts = 5;
  static const Duration loginCooldownDuration = Duration(minutes: 15);

  // ===================== UI CONFIGURATION =====================

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int loadMoreThreshold = 5;

  // Search
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const int minSearchLength = 2;
  static const int maxRecentSearches = 10;

  // Animations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Notifications
  static const Duration notificationDisplayDuration = Duration(seconds: 4);
  static const int maxNotificationsInQueue = 5;

  // ===================== ACADEMIC CONFIGURATION =====================

  // Grade thresholds
  static const int gradeExcellentMin = 90;
  static const int gradeGoodMin = 70;
  static const int gradeSatisfactoryMin = 50;

  // Attendance thresholds
  static const double attendanceExcellentMin = 95.0;
  static const double attendanceGoodMin = 85.0;
  static const double attendanceSatisfactoryMin = 70.0;

  // Homework & Exam settings
  static const int homeworkOverdueDays = 0;
  static const int homeworkDueSoonDays = 3;
  static const int examReminderDays = 7;
  static const int maxHomeworkDescriptionLength = 500;
  static const int maxExamDescriptionLength = 500;
  static const int maxCommentLength = 200;

  // ===================== DEVELOPMENT CONFIGURATION =====================

  // Debug flags
  static const bool enableDebugMode = true; // Set to false for production
  static const bool enableApiLogging = true;
  static const bool enableCacheLogging = false;
  static const bool enablePerformanceLogging = false;

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableBiometrics = false; // Not implemented yet
  static const bool enableNotifications = true;
  static const bool enableFileUpload = true;
  static const bool enableFileDownload = true;

  // ===================== ENVIRONMENT HELPERS =====================

  /// Check if app is in debug mode
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  /// Check if features are enabled
  static bool get isOfflineModeEnabled => enableOfflineMode;
  static bool get isNotificationsEnabled => enableNotifications;
  static bool get isBiometricsEnabled => enableBiometrics;

  /// Get full API endpoint URL
  static String getApiEndpoint(String endpoint) {
    return '$fullApiUrl$endpoint';
  }

  /// Get file upload URL
  static String get fileUploadUrl => '$fullApiUrl/files';

  /// Get file download URL
  static String getFileDownloadUrl(int fileId) {
    return '$fullApiUrl/files/$fileId';
  }

  // ===================== VALIDATION RULES =====================

  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;
  static const int maxEmailLength = 100;

  // ===================== REGEX PATTERNS =====================

  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,30}$';

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  /// Validate phone format
  static bool isValidPhone(String phone) {
    return RegExp(phonePattern).hasMatch(phone);
  }

  /// Validate username format
  static bool isValidUsername(String username) {
    return RegExp(usernamePattern).hasMatch(username);
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get app information as map
  static Map<String, dynamic> get appInfo => {
    'name': appName,
    'version': appVersion,
    'buildNumber': appBuildNumber,
    'isDebug': isDebugMode,
    'baseUrl': baseUrl,
    'supportEmail': supportEmail,
    'supportPhone': supportPhone,
  };

  /// Print configuration for debugging
  static void printConfig() {
    if (enableDebugMode) {
      print('📱 App Configuration:');
      print('   Name: $appName');
      print('   Version: $appVersion');
      print('   Build: $appBuildNumber');
      print('   Base URL: $baseUrl');
      print('   Debug Mode: $isDebugMode');
      print('   API Logging: $enableApiLogging');
      print('   Offline Mode: $enableOfflineMode');
      print('   Notifications: $enableNotifications');
    }
  }
}