abstract class AppConfig {
  // App Information
  static const String appName = 'Toshmi Mobile';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API Configuration
  static const String baseUrl = 'https://api.toshmi.uz';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  // Contact Information
  static const String supportEmail = 'support@toshmi.uz';
  static const String supportPhone = '+998900000000';

  // Feature Flags
  static const bool enableDebugMode = true;
  static const bool enableApiLogging = true;
  static const bool enableOfflineMode = true;
  static const bool enableNotifications = true;

  // File Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  // Cache Settings
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Validation Patterns
  static const String phonePattern = r'^\+998[0-9]{9}$';
  static const String emailPattern = r'^[^@]+@[^@]+\.[^@]+$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,20}$';

  // Default Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Helper Methods
  static Map<String, String> buildHeaders({String? token}) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, String> buildPaginationParams({int? skip, int? limit}) {
    return {
      if (skip != null) 'skip': skip.toString(),
      if (limit != null) 'limit': limit.toString(),
    };
  }

  static bool isValidEmail(String email) => RegExp(emailPattern).hasMatch(email);
  static bool isValidPhone(String phone) => RegExp(phonePattern).hasMatch(phone);

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static void printConfig() {
    if (enableDebugMode) {
      print('📱 App: $appName v$appVersion');
      print('🌐 API: $baseUrl');
      print('🔧 Debug: $enableDebugMode');
    }
  }
}