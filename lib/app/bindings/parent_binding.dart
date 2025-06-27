import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/parent_controller.dart';
import '../../data/repositories/parent_repository.dart';
import '../../data/services/parent_service.dart';
import '../../data/services/api_service.dart';

/// Binding for Parent-related dependencies
///
/// This binding ensures all parent-related services, repositories, and controllers
/// are properly initialized and injected when needed. It follows the established
/// pattern in the codebase for dependency management.
class ParentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ApiService is available (should already be initialized in app startup)
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Initialize ParentService - handles business logic and API calls
    Get.lazyPut<ParentService>(
          () => ParentService(),
      fenix: true, // Allows recreation if disposed
    );

    // Initialize ParentRepository - handles data management and caching
    Get.lazyPut<ParentRepository>(
          () => ParentRepository(),
      fenix: true,
    );

    // Initialize ParentController - manages UI state and user interactions
    Get.lazyPut<ParentController>(
          () => ParentController(),
      fenix: true,
    );

    print('ParentBinding: Dependencies initialized');
  }
}

/// Permanent binding for parent-related services that should persist across navigation
///
/// Use this when parent data should remain in memory throughout the app session.
/// This is useful for parent users who might navigate between different sections
/// but want to maintain their children's data and dashboard information.
class ParentPermanentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ApiService is available
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Initialize services with permanent: true to persist across navigation
    Get.put<ParentService>(
      ParentService(),
      permanent: true,
    );

    Get.put<ParentRepository>(
      ParentRepository(),
      permanent: true,
    );

    Get.put<ParentController>(
      ParentController(),
      permanent: true,
    );

    print('ParentPermanentBinding: Permanent dependencies initialized');
  }
}

/// Lazy binding for parent dependencies - initializes only when accessed
///
/// This is the most memory-efficient option as dependencies are only created
/// when actually needed. Good for cases where parent functionality might not
/// be used in every session.
class ParentLazyBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - only created when Get.find() is called
    Get.lazyPut<ParentService>(() => ParentService());
    Get.lazyPut<ParentRepository>(() => ParentRepository());
    Get.lazyPut<ParentController>(() => ParentController());

    print('ParentLazyBinding: Lazy dependencies registered');
  }
}

/// Smart binding that initializes based on user role
///
/// This binding checks the current user's role and only initializes parent
/// dependencies if the user is actually a parent. This optimizes memory usage
/// and prevents unnecessary initialization for other user types.
class ParentSmartBinding extends Bindings {
  @override
  void dependencies() {
    // Only initialize parent dependencies if user is a parent
    // This requires AuthController to be available
    try {
      final authController = Get.find<AuthController>();

      if (authController.isParent) {
        // User is a parent, initialize all dependencies
        Get.lazyPut<ParentService>(() => ParentService(), fenix: true);
        Get.lazyPut<ParentRepository>(() => ParentRepository(), fenix: true);
        Get.lazyPut<ParentController>(() => ParentController(), fenix: true);

        print('ParentSmartBinding: Parent dependencies initialized for parent user');
      } else {
        print('ParentSmartBinding: Skipped initialization - user is not a parent');
      }
    } catch (e) {
      // AuthController not available, fallback to lazy initialization
      print('ParentSmartBinding: AuthController not found, using fallback lazy initialization');
      Get.lazyPut<ParentService>(() => ParentService());
      Get.lazyPut<ParentRepository>(() => ParentRepository());
      Get.lazyPut<ParentController>(() => ParentController());
    }
  }
}

/// Utility class for managing parent dependencies
class ParentDependencyManager {
  /// Initialize parent dependencies manually
  static void initializeParentDependencies({bool permanent = false}) {
    if (permanent) {
      ParentPermanentBinding().dependencies();
    } else {
      ParentBinding().dependencies();
    }
  }

  /// Check if parent dependencies are initialized
  static bool areParentDependenciesInitialized() {
    return Get.isRegistered<ParentController>() &&
        Get.isRegistered<ParentRepository>() &&
        Get.isRegistered<ParentService>();
  }

  /// Clean up parent dependencies
  static void cleanupParentDependencies() {
    if (Get.isRegistered<ParentController>()) {
      Get.delete<ParentController>();
    }
    if (Get.isRegistered<ParentRepository>()) {
      Get.delete<ParentRepository>();
    }
    if (Get.isRegistered<ParentService>()) {
      Get.delete<ParentService>();
    }
    print('ParentDependencyManager: Dependencies cleaned up');
  }

  /// Reset parent dependencies (cleanup and reinitialize)
  static void resetParentDependencies({bool permanent = false}) {
    cleanupParentDependencies();
    initializeParentDependencies(permanent: permanent);
    print('ParentDependencyManager: Dependencies reset');
  }
}