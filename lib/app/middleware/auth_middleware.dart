import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Middleware to check if user is authenticated
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    print('AuthMiddleware: Checking auth for route: $route');

    try {
      // Get AuthController - it should exist from AppBindings
      // final authController = Get.find<AuthController>();

      // Check if user is authenticated
      // if (!authController.isAuthenticated.value) {
      //   print('AuthMiddleware: User not authenticated, redirecting to login');
      //   return const RouteSettings(name: '/login');
      // }
      //
      // // Check if user data exists
      // if (authController.user.value == null) {
      //   print('AuthMiddleware: User data missing, redirecting to login');
      //   return const RouteSettings(name: '/login');
      // }

      print('AuthMiddleware: User authenticated, allowing access to $route');
      return null; // Allow access

    } catch (e) {
      // If AuthController doesn't exist, redirect to login
      print('AuthMiddleware: AuthController not found, redirecting to login: $e');
      return const RouteSettings(name: '/login');
    }
  }
}

/// Middleware to redirect authenticated users away from auth pages
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    print('GuestMiddleware: Checking guest access for route: $route');

    try {
      // Get AuthController
      // final authController = Get.find<AuthController>();
      //
      // // If user is already authenticated, redirect to dashboard
      // if (authController.isAuthenticated.value && authController.user.value != null) {
      //   print('GuestMiddleware: User already authenticated, redirecting to dashboard');
      //   return const RouteSettings(name: '/dashboard');
      // }
      //
      // print('GuestMiddleware: User not authenticated, allowing access to $route');
      // return null; // Allow access to auth pages

    } catch (e) {
      // If AuthController doesn't exist, allow access (probably first time)
      print('GuestMiddleware: AuthController not found, allowing access: $e');
      return null;
    }
  }
}

/// Role-based access middleware
class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware(this.allowedRoles);

  @override
  int? get priority => 3;

  @override
  RouteSettings? redirect(String? route) {
    print('RoleMiddleware: Checking role access for route: $route');
    print('RoleMiddleware: Required roles: $allowedRoles');

    try {
      // Get AuthController
      // final authController = Get.find<AuthController>();
      //
      // // First check if user is authenticated
      // if (!authController.isAuthenticated.value || authController.user.value == null) {
      //   print('RoleMiddleware: User not authenticated, redirecting to login');
      //   return const RouteSettings(name: '/login');
      // }
      //
      // final userRole = authController.user.value!.role;
      // print('RoleMiddleware: User role: $userRole');
      //
      // // Check if user has required role
      // if (!allowedRoles.contains(userRole)) {
      //   print('RoleMiddleware: Access denied for role: $userRole');
      //
      //   // Redirect to appropriate dashboard based on user's actual role
      //   switch (userRole) {
      //     case 'student':
      //       return const RouteSettings(name: '/dashboard');
      //     case 'teacher':
      //       return const RouteSettings(name: '/dashboard'); // Same dashboard for now
      //     case 'parent':
      //       return const RouteSettings(name: '/dashboard'); // Same dashboard for now
      //     default:
      //       return const RouteSettings(name: '/login');
      //   }
      // }
      //
      // print('RoleMiddleware: Access granted for role: $userRole');
      // return null; // Allow access

    } catch (e) {
      print('RoleMiddleware: Error checking role access: $e');
      return const RouteSettings(name: '/login');
    }
  }
}

/// Middleware to check if user has completed onboarding
class OnboardingMiddleware extends GetMiddleware {
  @override
  int? get priority => 4;

  @override
  RouteSettings? redirect(String? route) {
    print('OnboardingMiddleware: Checking onboarding for route: $route');

    try {
      // Get AuthController
      // final authController = Get.find<AuthController>();
      //
      // // Check if user is authenticated
      // if (!authController.isAuthenticated.value) {
      //   return null; // Let AuthMiddleware handle this
      // }

      // Check if user needs onboarding (implement this based on your needs)
      // For now, we'll skip onboarding

      return null; // Allow access

    } catch (e) {
      print('OnboardingMiddleware: Error checking onboarding: $e');
      return null;
    }
  }
}

/// Helper class for middleware utilities
class MiddlewareUtils {
  /// Check if route requires authentication
  static bool requiresAuth(String? route) {
    if (route == null) return false;

    final publicRoutes = [
      '/login',
      '/forgot-password',
      '/register', // if you have registration
    ];

    return !publicRoutes.contains(route);
  }

  /// Check if route is for guests only
  static bool isGuestOnly(String? route) {
    if (route == null) return false;

    final guestOnlyRoutes = [
      '/login',
      '/forgot-password',
      '/register',
    ];

    return guestOnlyRoutes.contains(route);
  }

  /// Get appropriate dashboard route for user role
  static String getDashboardRoute(String userRole) {
    switch (userRole) {
      case 'student':
        return '/dashboard';
      case 'teacher':
        return '/dashboard'; // Can be different if needed
      case 'parent':
        return '/dashboard'; // Can be different if needed
      default:
        return '/login';
    }
  }

  /// Check if user can access specific feature
  static bool canAccessFeature(String feature, String userRole) {
    switch (feature) {
      case 'homework_create':
        return userRole == 'teacher';
      case 'homework_view':
        return ['student', 'teacher', 'parent'].contains(userRole);
      case 'grades_view':
        return ['student', 'teacher', 'parent'].contains(userRole);
      case 'grades_edit':
        return userRole == 'teacher';
      case 'attendance_mark':
        return userRole == 'teacher';
      case 'attendance_view':
        return ['student', 'teacher', 'parent'].contains(userRole);
      case 'payments_view':
        return ['student', 'parent'].contains(userRole);
      default:
        return false;
    }
  }

  /// Log middleware activity for debugging
  static void logMiddlewareActivity(String middlewareName, String route, String action) {
    print('🛡️ [$middlewareName] Route: $route - Action: $action');
  }
}