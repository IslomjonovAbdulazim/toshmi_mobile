class AppRoutes {
  AppRoutes._();

  // Main routes
  static const String SPLASH = '/splash';
  static const String LOGIN = '/login';
  static const String PROFILE = '/profile';
  static const String EDIT_PROFILE = '/edit-profile';
  static const String CHANGE_PASSWORD = '/change-password';

  // Role-specific routes
  static const String STUDENT = '/student';
  static const String TEACHER = '/teacher';
  static const String PARENT = '/parent';
  static const String ADMIN = '/admin';

  // Feature routes
  static const String HOMEWORK = '/homework';
  static const String EXAMS = '/exams';
  static const String GRADES = '/grades';
  static const String ATTENDANCE = '/attendance';
  static const String NOTIFICATIONS = '/notifications';
  static const String SETTINGS = '/settings';

  // Utility routes
  static const String NOT_FOUND = '/not-found';

  // Helper methods
  static bool isProtectedRoute(String route) {
    const protectedRoutes = [
      PROFILE,
      EDIT_PROFILE,
      CHANGE_PASSWORD,
      STUDENT,
      TEACHER,
      PARENT,
      ADMIN,
      HOMEWORK,
      EXAMS,
      GRADES,
      ATTENDANCE,
      NOTIFICATIONS,
      SETTINGS,
    ];
    return protectedRoutes.contains(route);
  }

  static bool isPublicRoute(String route) {
    const publicRoutes = [LOGIN, SPLASH];
    return publicRoutes.contains(route);
  }

  static bool isRoleSpecificRoute(String route) {
    const roleRoutes = [STUDENT, TEACHER, PARENT, ADMIN];
    return roleRoutes.contains(route);
  }
}