import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/notification_controller.dart';
import '../../presentation/controllers/parent_controller.dart';
import '../../presentation/controllers/student_controller.dart';
import '../../presentation/controllers/teacher_controller.dart';
import 'student_binding.dart';
import 'teacher_binding.dart';
import 'parent_binding.dart';

/// Authentication binding for login/registration and auth-related screens
///
/// This binding handles all authentication-related dependencies including
/// login, logout, profile management, and notifications.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ApiService is available (should be initialized in InitialBinding)
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Initialize AuthRepository - handles all auth-related API calls and caching
    Get.lazyPut<AuthRepository>(
          () => AuthRepository(),
      fenix: true,
    );

    // Initialize AuthController - manages authentication state and UI
    Get.lazyPut<AuthController>(
          () => AuthController(),
      fenix: true,
    );

    print('AuthBinding: Authentication dependencies initialized');
  }
}

/// Permanent auth binding for maintaining auth state across the app
///
/// Use this binding when you want auth state to persist throughout
/// the entire app session, regardless of navigation.
class AuthPermanentBinding extends Bindings {
  @override
  void dependencies() {
    // Core API service (permanent)
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Permanent auth dependencies
    Get.put<AuthRepository>(
      AuthRepository(),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );

    print('AuthPermanentBinding: Permanent auth dependencies initialized');
  }
}

/// Smart auth binding that initializes based on current auth state
///
/// This binding checks if user is already authenticated and initializes
/// appropriate dependencies accordingly.
class AuthSmartBinding extends Bindings {
  @override
  void dependencies() {
    // Always need ApiService
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Initialize auth repository to check current state
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(
        AuthRepository(),
        permanent: true,
      );
    }

    // Initialize auth controller
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(),
        permanent: true,
      );
    }

    // Initialize notifications if user is authenticated
    final authRepo = Get.find<AuthRepository>();
    if (authRepo.isAuthenticated) {
      if (!Get.isRegistered<NotificationController>()) {
        Get.lazyPut<NotificationController>(
              () => NotificationController(),
          fenix: true,
        );
      }
      print('AuthSmartBinding: Notifications initialized for authenticated user');
    }

    print('AuthSmartBinding: Smart auth dependencies initialized');
  }
}

/// Notification binding for notification-related functionality
///
/// This binding specifically handles notification dependencies.
/// Can be used independently or as part of other bindings.
class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure auth dependencies are available
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }

    // Initialize notification controller
    Get.lazyPut<NotificationController>(
          () => NotificationController(),
      fenix: true,
    );

    print('NotificationBinding: Notification dependencies initialized');
  }
}

/// Minimal auth binding for screens that only need auth state checking
///
/// Use this for screens that need to check auth status but don't need
/// full authentication functionality.
class AuthCheckBinding extends Bindings {
  @override
  void dependencies() {
    // Only initialize what's needed for auth checking
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepository());
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController());
    }

    print('AuthCheckBinding: Minimal auth dependencies initialized');
  }
}

/// Combined auth and notification binding
///
/// This binding provides both authentication and notification functionality
/// in a single binding. Useful for dashboard screens that need both.
class AuthNotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Auth dependencies
    Get.lazyPut<AuthRepository>(
          () => AuthRepository(),
      fenix: true,
    );

    Get.lazyPut<AuthController>(
          () => AuthController(),
      fenix: true,
    );

    // Notification dependencies
    Get.lazyPut<NotificationController>(
          () => NotificationController(),
      fenix: true,
    );

    print('AuthNotificationBinding: Auth and notification dependencies initialized');
  }
}

/// Utility class for managing auth-related dependencies
class AuthDependencyManager {
  /// Check if auth dependencies are initialized
  static bool areAuthDependenciesInitialized() {
    return Get.isRegistered<AuthController>() &&
        Get.isRegistered<AuthRepository>();
  }

  /// Check if user is authenticated (requires auth dependencies)
  static bool isUserAuthenticated() {
    if (!areAuthDependenciesInitialized()) return false;
    try {
      final authController = Get.find<AuthController>();
      return authController.isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Get current user role (requires auth dependencies)
  static String? getCurrentUserRole() {
    if (!areAuthDependenciesInitialized()) return null;
    try {
      final authController = Get.find<AuthController>();
      return authController.userRole;
    } catch (e) {
      return null;
    }
  }

  /// Initialize auth dependencies manually
  static void initializeAuthDependencies({bool permanent = false}) {
    if (permanent) {
      AuthPermanentBinding().dependencies();
    } else {
      AuthBinding().dependencies();
    }
  }

  /// Clean up auth dependencies
  static void cleanupAuthDependencies({bool keepPermanent = true}) {
    if (!keepPermanent || !Get.isPermanent<AuthController>()) {
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>();
      }
    }

    if (!keepPermanent || !Get.isPermanent<AuthRepository>()) {
      if (Get.isRegistered<AuthRepository>()) {
        Get.delete<AuthRepository>();
      }
    }

    if (Get.isRegistered<NotificationController>()) {
      Get.delete<NotificationController>();
    }

    print('AuthDependencyManager: Auth dependencies cleaned up');
  }

  /// Reset auth dependencies (cleanup and reinitialize)
  static void resetAuthDependencies({bool permanent = false}) {
    cleanupAuthDependencies(keepPermanent: false);
    initializeAuthDependencies(permanent: permanent);
    print('AuthDependencyManager: Auth dependencies reset');
  }

  /// Initialize role-specific dependencies after authentication
  static void initializeRoleBasedDependencies(String userRole) {
    switch (userRole) {
      case UserRoles.student:
        if (!Get.isRegistered<StudentController>()) {
          StudentBinding().dependencies();
        }
        break;
      case UserRoles.teacher:
        if (!Get.isRegistered<TeacherController>()) {
          TeacherBinding().dependencies();
        }
        break;
      case UserRoles.parent:
        if (!Get.isRegistered<ParentController>()) {
          ParentBinding().dependencies();
        }
        break;
      case UserRoles.admin:
      // Admin dependencies would go here
        break;
    }

    // Always initialize notifications for authenticated users
    if (!Get.isRegistered<NotificationController>()) {
      NotificationBinding().dependencies();
    }

    print('AuthDependencyManager: Role-based dependencies initialized for $userRole');
  }
}