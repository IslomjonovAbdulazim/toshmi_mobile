import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';

/// ✅ FIXED: Initial binding that properly sets up core services and dependencies
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 InitialBinding: Setting up core dependencies...');

    // Initialize GetStorage first
    _initializeStorage();

    // Core services (order matters)
    _registerCoreServices();

    // Repositories
    _registerRepositories();

    print('✅ InitialBinding: All dependencies registered successfully');
  }

  /// Initialize GetStorage
  void _initializeStorage() {
    print('💾 InitialBinding: Initializing storage...');

    // GetStorage should be initialized in main.dart before runApp()
    // This is just a safety check
    if (!GetStorage().hasData('_initialized')) {
      GetStorage().write('_initialized', true);
    }

    print('✅ InitialBinding: Storage initialized');
  }

  /// Register core services that other services depend on
  void _registerCoreServices() {
    print('🔧 InitialBinding: Registering core services...');

    // API Service - foundation for all network operations
    Get.put<ApiService>(
      ApiService(),
      permanent: true, // Keep alive throughout app lifecycle
    );
    print('✅ InitialBinding: ApiService registered');

    // Auth Service - depends on ApiService
    Get.put<AuthService>(
      AuthService(),
      permanent: true, // Keep alive throughout app lifecycle
    );
    print('✅ InitialBinding: AuthService registered');
  }

  /// ✅ FIXED: Register repository layer with proper dependency injection
  void _registerRepositories() {
    print('🔧 InitialBinding: Registering repositories...');

    // Create single instance of AuthRepository
    final authRepository = AuthRepository();

    // ✅ SOLUTION: Register as both interface and concrete class
    // This allows controllers to use either:
    // - IAuthRepository (recommended for dependency injection)
    // - AuthRepository (for existing code compatibility)
    Get.put<IAuthRepository>(
      authRepository,
      permanent: true, // Keep alive throughout app lifecycle
    );

    Get.put<AuthRepository>(
      authRepository,
      permanent: true, // Keep alive throughout app lifecycle
    );

    print('✅ InitialBinding: AuthRepository registered (both interface and concrete)');

    // Add other repositories here as needed
    // Example:
    // final studentRepo = StudentRepository();
    // Get.put<IStudentRepository>(studentRepo, permanent: true);
    // Get.put<StudentRepository>(studentRepo, permanent: true);
  }
}

/// ✅ OPTIMIZED: Minimal binding for better performance
class MinimalBinding extends Bindings {
  @override
  void dependencies() {
    print('⚡ MinimalBinding: Setting up minimal dependencies...');

    // Only essential services for app startup
    final apiService = ApiService();
    final authService = AuthService();
    final authRepository = AuthRepository();

    // Register services
    Get.put<ApiService>(apiService, permanent: true);
    Get.put<AuthService>(authService, permanent: true);

    // Register repository as both types
    Get.put<IAuthRepository>(authRepository, permanent: true);
    Get.put<AuthRepository>(authRepository, permanent: true);

    print('✅ MinimalBinding: Minimal dependencies registered');
  }
}

/// ✅ PERFORMANCE: Lazy loading binding for non-critical services
class LazyServicesBinding extends Bindings {
  @override
  void dependencies() {
    print('🔄 LazyServicesBinding: Setting up lazy dependencies...');

    // Non-critical services that can be loaded on demand
    // Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    // Get.lazyPut<CacheService>(() => CacheService(), fenix: true);
    // Get.lazyPut<ThemeService>(() => ThemeService(), fenix: true);

    print('✅ LazyServicesBinding: Lazy dependencies registered');
  }
}

/// ✅ DEVELOPMENT: Debug binding for development environment
class DebugBinding extends Bindings {
  @override
  void dependencies() {
    print('🐛 DebugBinding: Setting up debug dependencies...');

    // Load initial binding first
    InitialBinding().dependencies();

    // Debug-specific services for development
    // Get.put<LoggingService>(LoggingService(), permanent: true);
    // Get.put<AnalyticsService>(AnalyticsService(), permanent: true);

    print('✅ DebugBinding: Debug dependencies registered');
  }
}