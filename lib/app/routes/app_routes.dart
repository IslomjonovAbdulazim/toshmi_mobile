import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';

class AppRoutes {
  // ===================== ROUTE NAMES =====================
  // Add new route names here as you build more screens

  static const String login = '/login';
  static const String dashboard = '/dashboard';

  // Future routes to add:
  // static const String homework = '/homework';
  // static const String exams = '/exams';
  // static const String grades = '/grades';
  // static const String notifications = '/notifications';
  // static const String profile = '/profile';

  // ===================== ROUTE PAGES =====================
  // Add new GetPage entries here for each screen

  static final List<GetPage> pages = [
    // Login Page - No auth required, redirect if already authenticated
    // GetPage(
    //   name: login,
    //   page: () => const LoginScreen(),
    //   binding: AuthBindings(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   middlewares: [GuestMiddleware()],
    // ),
    //
    // // Dashboard Page - Requires authentication
    // GetPage(
    //   name: dashboard,
    //   page: () => const DashboardScreen(),
    //   binding: DashboardBindings(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: const Duration(milliseconds: 300),
    //   middlewares: [AuthMiddleware()],
    // ),

    // Future pages to add:
    /*
    GetPage(
      name: homework,
      page: () => const HomeworkScreen(),
      binding: HomeworkBindings(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: exams,
      page: () => const ExamsScreen(),
      binding: ExamBindings(),
      middlewares: [AuthMiddleware()],
    ),
    */
  ];

  // ===================== NAVIGATION HELPERS =====================

  /// Go to login screen and clear navigation stack
  static void toLogin() {
    print('AppRoutes: Navigating to login');
    Get.offAllNamed(login);
  }

  /// Go to dashboard and clear navigation stack
  static void toDashboard() {
    print('AppRoutes: Navigating to dashboard');
    Get.offAllNamed(dashboard);
  }

  /// Go back
  static void back() {
    print('AppRoutes: Going back');
    Get.back();
  }

  /// Go back with result
  static void backWithResult(dynamic result) {
    print('AppRoutes: Going back with result: $result');
    Get.back(result: result);
  }

  /// Check current route
  static String? get currentRoute => Get.currentRoute;

  /// Check if current route is login
  static bool get isLoginRoute => Get.currentRoute == login;

  /// Check if current route is dashboard
  static bool get isDashboardRoute => Get.currentRoute == dashboard;

  /// Navigate based on authentication status
  static void navigateBasedOnAuth() {
    try {
      // This will be called from AuthController or main app
      // Let the middleware handle the routing logic
      Get.offAllNamed(dashboard);
    } catch (e) {
      print('AppRoutes: Error in navigateBasedOnAuth: $e');
      Get.offAllNamed(login);
    }
  }

  /// Handle deep links or external navigation
  static void handleExternalRoute(String route) {
    print('AppRoutes: Handling external route: $route');

    switch (route) {
      case login:
        toLogin();
        break;
      case dashboard:
        toDashboard();
        break;
      default:
        print('AppRoutes: Unknown route: $route, redirecting to dashboard');
        toDashboard();
    }
  }

  /// Get initial route based on auth status
  static String getInitialRoute() {
    // This will be determined by middleware
    // Start with login and let middleware redirect if needed
    return login;
  }

  /// Route observer for debugging
  static void onRouteChanged(String? route) {
    print('📍 Route changed to: $route');
  }
}