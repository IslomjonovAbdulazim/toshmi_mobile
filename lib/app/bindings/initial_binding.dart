import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';

/// Initial binding that sets up core services and dependencies
/// This binding is loaded when the app starts and provides essential services
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

  /// Register repository layer
  void _registerRepositories() {
    print('🔧 InitialBinding: Registering repositories...');

    // Auth Repository - depends on AuthService
    Get.put<IAuthRepository>(
      AuthRepository(),
      permanent: true, // Keep alive throughout app lifecycle
    );
    print('✅ InitialBinding: AuthRepository registered');

    // Add other repositories here as needed
    // Example:
    // Get.put<IStudentRepository>(StudentRepository(), permanent: true);
    // Get.put<ITeacherRepository>(TeacherRepository(), permanent: true);
  }
}

/// Network-related bindings for API and connectivity services
class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    print('🌐 NetworkBinding: Setting up network dependencies...');

    // Network status checker (if you have one)
    // Get.put<NetworkService>(NetworkService(), permanent: true);

    // HTTP cache service (if you have one)
    // Get.put<CacheService>(CacheService(), permanent: true);

    print('✅ NetworkBinding: Network dependencies registered');
  }
}

/// Storage-related bindings for local data persistence
class StorageBinding extends Bindings {
  @override
  void dependencies() {
    print('💾 StorageBinding: Setting up storage dependencies...');

    // Local database service (if you have one)
    // Get.put<DatabaseService>(DatabaseService(), permanent: true);

    // File storage service (if you have one)
    // Get.put<FileStorageService>(FileStorageService(), permanent: true);

    print('✅ StorageBinding: Storage dependencies registered');
  }
}

/// Utility bindings for helper services
class UtilityBinding extends Bindings {
  @override
  void dependencies() {
    print('🛠️ UtilityBinding: Setting up utility dependencies...');

    // Permission service (if you have one)
    // Get.put<PermissionService>(PermissionService(), permanent: true);

    // Notification service (if you have one)
    // Get.put<NotificationService>(NotificationService(), permanent: true);

    // Theme service (if you have one)
    // Get.put<ThemeService>(ThemeService(), permanent: true);

    print('✅ UtilityBinding: Utility dependencies registered');
  }
}

/// Combined binding that includes all essential bindings
/// Use this if you want to load everything at once
class AppBinding extends Bindings {
  @override
  void dependencies() {
    print('🚀 AppBinding: Setting up all app dependencies...');

    // Load all bindings in order
    InitialBinding().dependencies();
    NetworkBinding().dependencies();
    StorageBinding().dependencies();
    UtilityBinding().dependencies();

    print('🎉 AppBinding: All app dependencies loaded successfully');
  }
}

/// Minimal binding for essential services only
/// Use this for better app startup performance
class MinimalBinding extends Bindings {
  @override
  void dependencies() {
    print('⚡ MinimalBinding: Setting up minimal dependencies...');

    // Only essential services
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<IAuthRepository>(AuthRepository(), permanent: true);

    print('✅ MinimalBinding: Minimal dependencies registered');
  }
}

/// Development binding with additional debugging services
class DebugBinding extends Bindings {
  @override
  void dependencies() {
    print('🐛 DebugBinding: Setting up debug dependencies...');

    // Load initial binding first
    InitialBinding().dependencies();

    // Debug-specific services
    // Get.put<LoggingService>(LoggingService(), permanent: true);
    // Get.put<DebugService>(DebugService(), permanent: true);

    print('✅ DebugBinding: Debug dependencies registered');
  }
}
