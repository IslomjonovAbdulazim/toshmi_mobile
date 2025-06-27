import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/theme_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';

/// Initial binding that sets up core dependencies for the entire app
///
/// This binding should be used at app startup to initialize essential
/// services that are needed throughout the application lifecycle.
/// These dependencies are created as permanent and persist across navigation.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('🚀 InitialBinding: Setting up core app dependencies...');

    // Initialize GetStorage first (required by other services)
    _initializeStorage();

    // Core API service (permanent - needed throughout app)
    _initializeApiService();

    // Theme management (permanent - needed throughout app)
    _initializeThemeController();

    // Authentication (permanent - needed to check auth status)
    _initializeAuthenticationCore();

    print('✅ InitialBinding: Core dependencies initialized successfully');
  }

  /// Initialize GetStorage for local data persistence
  void _initializeStorage() {
    try {
      // GetStorage should already be initialized in main.dart
      // This is just a safety check
      if (!GetStorage().hasData('app_initialized')) {
        GetStorage().write('app_initialized', true);
      }
      print('📦 Storage: GetStorage verified');
    } catch (e) {
      print('❌ Storage: Error verifying GetStorage - $e');
    }
  }

  /// Initialize core API service for all network communication
  void _initializeApiService() {
    Get.put<ApiService>(
      ApiService(),
      permanent: true,
    );
    print('🌐 API: Service initialized (permanent)');
  }

  /// Initialize theme controller for app-wide theming
  void _initializeThemeController() {
    Get.put<ThemeController>(
      ThemeController(),
      permanent: true,
    );
    print('🎨 Theme: Controller initialized (permanent)');
  }

  /// Initialize core authentication dependencies
  void _initializeAuthenticationCore() {
    // Auth repository (permanent)
    Get.put<AuthRepository>(
      AuthRepository(),
      permanent: true,
    );

    // Auth controller (permanent)
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );

    print('🔐 Auth: Core authentication initialized (permanent)');
  }
}

/// Development binding with additional debugging and development tools
///
/// Use this binding during development to include additional services
/// that help with debugging and development workflow.
class InitialDevBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 InitialDevBinding: Setting up development dependencies...');

    // Initialize core dependencies
    InitialBinding().dependencies();

    // Add development-specific dependencies
    _initializeDevelopmentTools();

    print('✅ InitialDevBinding: Development dependencies initialized');
  }

  void _initializeDevelopmentTools() {
    // Add development tools here
    // Examples: debugging tools, logging services, etc.

    // Example: Enhanced logging
    Get.put<DevLogger>(
      DevLogger(),
      permanent: true,
    );

    print('🛠️ Dev Tools: Development utilities initialized');
  }
}

/// Production binding optimized for release builds
///
/// This binding initializes only essential dependencies without
/// development tools, optimized for production performance.
class InitialProdBinding extends Bindings {
  @override
  void dependencies() {
    print('🚀 InitialProdBinding: Setting up production dependencies...');

    // Core dependencies only
    InitialBinding().dependencies();

    // Production-specific optimizations
    _initializeProductionOptimizations();

    print('✅ InitialProdBinding: Production dependencies initialized');
  }

  void _initializeProductionOptimizations() {
    // Production-specific configurations
    // Examples: performance monitoring, crash reporting, etc.

    print('⚡ Prod: Production optimizations applied');
  }
}

/// Minimal binding for testing environments
///
/// This binding provides only the bare minimum dependencies needed
/// for testing, avoiding heavy services that aren't needed in tests.
class InitialTestBinding extends Bindings {
  @override
  void dependencies() {
    print('🧪 InitialTestBinding: Setting up test dependencies...');

    // Minimal API service for testing
    Get.put<MockApiService>(
      MockApiService(),
      permanent: true,
    );

    // Mock auth repository for testing
    Get.put<MockAuthRepository>(
      MockAuthRepository(),
      permanent: true,
    );

    // Theme controller (needed for UI tests)
    Get.put<ThemeController>(
      ThemeController(),
      permanent: true,
    );

    print('✅ InitialTestBinding: Test dependencies initialized');
  }
}

/// Utility class for managing initial app dependencies
class InitialDependencyManager {
  /// Check if core dependencies are initialized
  static bool areCoreDependenciesInitialized() {
    return Get.isRegistered<ApiService>() &&
        Get.isRegistered<AuthRepository>() &&
        Get.isRegistered<AuthController>() &&
        Get.isRegistered<ThemeController>();
  }

  /// Initialize core dependencies manually (useful for testing)
  static void initializeCoreManually() {
    if (!areCoreDependenciesInitialized()) {
      InitialBinding().dependencies();
    }
  }

  /// Get app initialization status
  static Map<String, bool> getInitializationStatus() {
    return {
      'apiService': Get.isRegistered<ApiService>(),
      'authRepository': Get.isRegistered<AuthRepository>(),
      'authController': Get.isRegistered<AuthController>(),
      'themeController': Get.isRegistered<ThemeController>(),
      'coreComplete': areCoreDependenciesInitialized(),
    };
  }

  /// Reset all dependencies (useful for testing)
  static void resetAllDependencies() {
    Get.reset();
    print('🔄 Dependencies: All dependencies reset');
  }

  /// Verify dependencies are working correctly
  static bool verifyDependencies() {
    try {
      // Test core services
      final apiService = Get.find<ApiService>();
      final authRepo = Get.find<AuthRepository>();
      final authController = Get.find<AuthController>();
      final themeController = Get.find<ThemeController>();

      print('✅ Dependencies: Verification successful');
      return true;
    } catch (e) {
      print('❌ Dependencies: Verification failed - $e');
      return false;
    }
  }
}

/// Mock services for testing (implement as needed)
class MockApiService extends GetxService {
  // Mock implementation for testing
}

class MockAuthRepository extends GetxService {
  // Mock implementation for testing
}

/// Development logger service
class DevLogger extends GetxService {
  void log(String message, {String? tag}) {
    print('🔍 ${tag ?? 'DEV'}: $message');
  }

  void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    print('❌ ERROR: $message');
    if (error != null) print('   Error: $error');
    if (stackTrace != null) print('   Stack: $stackTrace');
  }

  void logPerformance(String operation, Duration duration) {
    print('⏱️ PERF: $operation took ${duration.inMilliseconds}ms');
  }
}

/// App initialization helper
class AppInitializer {
  /// Initialize app with appropriate binding based on environment
  static void initializeApp({bool isDevelopment = false, bool isTesting = false}) {
    if (isTesting) {
      InitialTestBinding().dependencies();
    } else if (isDevelopment) {
      InitialDevBinding().dependencies();
    } else {
      InitialProdBinding().dependencies();
    }
  }

  /// Check if app is properly initialized
  static bool isAppInitialized() {
    return InitialDependencyManager.areCoreDependenciesInitialized() &&
        InitialDependencyManager.verifyDependencies();
  }

  /// Get initialization report
  static Map<String, dynamic> getInitializationReport() {
    final status = InitialDependencyManager.getInitializationStatus();
    return {
      'isInitialized': isAppInitialized(),
      'timestamp': DateTime.now().toIso8601String(),
      'dependencies': status,
      'environment': _getEnvironmentInfo(),
    };
  }

  static Map<String, dynamic> _getEnvironmentInfo() {
    return {
      'isDebugMode': Get.isLogEnable,
      'platform': GetPlatform.isAndroid ? 'Android' :
      GetPlatform.isIOS ? 'iOS' :
      GetPlatform.isWeb ? 'Web' : 'Other',
    };
  }
}