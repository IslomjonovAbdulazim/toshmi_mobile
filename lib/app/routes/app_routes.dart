/// Application route constants
class AppRoutes {
  AppRoutes._();

  // ===================== MAIN ROUTES =====================
  static const String SPLASH = '/splash';
  static const String LOGIN = '/login';
  static const String PROFILE = '/profile';

  // ===================== HELPER METHODS =====================

  /// Check if route requires authentication
  static bool isProtectedRoute(String route) {
    return route == PROFILE;
  }

  /// Check if route is public (no auth required)
  static bool isPublicRoute(String route) {
    return route == LOGIN || route == SPLASH;
  }
}