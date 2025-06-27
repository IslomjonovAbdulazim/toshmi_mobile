class StorageKeys {
  // Auth keys
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
  static const String userRole = 'user_role';

  // App settings
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String biometricEnabled = 'biometric_enabled';
  static const String notificationsEnabled = 'notifications_enabled';

  // Cache keys
  static const String cachedHomework = 'cached_homework';
  static const String cachedExams = 'cached_exams';
  static const String cachedGrades = 'cached_grades';
  static const String cachedAttendance = 'cached_attendance';
  static const String cachedSchedule = 'cached_schedule';
  static const String cachedNews = 'cached_news';
  static const String cachedNotifications = 'cached_notifications';

  // Last sync timestamps
  static const String lastSyncHomework = 'last_sync_homework';
  static const String lastSyncExams = 'last_sync_exams';
  static const String lastSyncGrades = 'last_sync_grades';
  static const String lastSyncAttendance = 'last_sync_attendance';
  static const String lastSyncNotifications = 'last_sync_notifications';

  // First time setup
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasSeenIntro = 'has_seen_intro';

  // User preferences
  static const String autoRefresh = 'auto_refresh';
  static const String refreshInterval = 'refresh_interval';
  static const String offlineMode = 'offline_mode';
}