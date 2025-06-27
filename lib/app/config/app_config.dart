class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // ===================== APP INFORMATION =====================
  static const String appName = 'Toshmi Mobile';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Support Information
  static const String supportEmail = 'support@toshmi.uz';
  static const String supportPhone = '+998 71 123 45 67';
  static const String websiteUrl = 'https://toshmi.uz';

  // ===================== API CONFIGURATION =====================
  static const String baseUrl = 'https://islomjonovabdulazim-toshmi-backend-0914.twc1.net';
  static const String apiVersion = 'v1';
  static const String fullApiUrl = '$baseUrl/api/$apiVersion';

  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(minutes: 5); // For file uploads

  // Default Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ===================== STORAGE KEYS =====================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String firstTimeKey = 'first_time_user';
  static const String notificationKey = 'notifications_enabled';

  // ===================== CACHE CONFIGURATION =====================
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 50; // MB
  static const bool enableCache = true;

  // ===================== FEATURE FLAGS =====================
  static const bool isDebugMode = bool.fromEnvironment('DEBUG', defaultValue: false);
  static const bool enableDebugMode = bool.fromEnvironment('ENABLE_DEBUG', defaultValue: false);
  static const bool enableApiLogging = bool.fromEnvironment('API_LOGGING', defaultValue: true);
  static const bool enableOfflineMode = bool.fromEnvironment('OFFLINE_MODE', defaultValue: true);
  static const bool enableNotifications = bool.fromEnvironment('NOTIFICATIONS', defaultValue: true);
  static const bool enableAnalytics = bool.fromEnvironment('ANALYTICS', defaultValue: false);

  // ===================== VALIDATION PATTERNS =====================
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,30}$';

  // ===================== FILE UPLOAD LIMITS =====================
  static const int maxImageSize = 3 * 1024 * 1024; // 3MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'];

  // ===================== PAGINATION DEFAULTS =====================
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
  static const int defaultSkip = 0;

  // ===================== HELPER METHODS =====================

  /// Build complete API URL
  static String buildApiUrl(String endpoint) => '$fullApiUrl$endpoint';

  /// Build headers with optional token
  static Map<String, String> buildHeaders({String? token}) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Build pagination parameters
  static Map<String, dynamic> buildPaginationParams({int? skip, int? limit}) {
    return {
      if (skip != null) 'skip': skip.toString(),
      if (limit != null) 'limit': limit.toString(),
    };
  }

  /// Build date range parameters
  static Map<String, dynamic> buildDateRangeParams({DateTime? startDate, DateTime? endDate}) {
    return {
      if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
    };
  }

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