import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/file_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/teacher_service.dart';
import '../../data/services/student_service.dart';
import '../../data/services/parent_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 InitialBinding: Setting up core dependencies...');

    _initializeStorage();
    _registerCoreServices();
    _registerRepositories();
    _registerOptionalServices();

    print('✅ InitialBinding: All dependencies registered successfully');
  }

  void _initializeStorage() {
    print('💾 InitialBinding: Initializing storage...');

    if (!GetStorage().hasData('_initialized')) {
      GetStorage().write('_initialized', true);
    }

    print('✅ InitialBinding: Storage initialized');
  }

  void _registerCoreServices() {
    print('🔧 InitialBinding: Registering core services...');

    // API Service - foundation for all network operations
    Get.put<ApiService>(
      ApiService(),
      permanent: true,
    );
    print('✅ InitialBinding: ApiService registered');

    // Auth Service - depends on ApiService
    Get.put<AuthService>(
      AuthService(),
      permanent: true,
    );
    print('✅ InitialBinding: AuthService registered');
  }

  void _registerRepositories() {
    print('🔧 InitialBinding: Registering repositories...');

    final authRepository = AuthRepository();

    // Register as both interface and concrete class for compatibility
    Get.put<IAuthRepository>(
      authRepository,
      permanent: true,
    );

    Get.put<AuthRepository>(
      authRepository,
      permanent: true,
    );

    print('✅ InitialBinding: AuthRepository registered');
  }

  void _registerOptionalServices() {
    print('🔧 InitialBinding: Registering optional services...');

    // File Service
    Get.put<FileService>(
      FileService(),
      permanent: true,
    );
    print('✅ InitialBinding: FileService registered');

    // Notification Service
    Get.put<NotificationService>(
      NotificationService(),
      permanent: true,
    );
    print('✅ InitialBinding: NotificationService registered');

    // Role-specific services (lazy loading)
    Get.lazyPut<TeacherService>(() => TeacherService(), fenix: true);
    Get.lazyPut<StudentService>(() => StudentService(), fenix: true);
    Get.lazyPut<ParentService>(() => ParentService(), fenix: true);
    print('✅ InitialBinding: Role-specific services registered (lazy)');
  }
}

// Minimal binding for better performance during app startup
class MinimalBinding extends Bindings {
  @override
  void dependencies() {
    print('⚡ MinimalBinding: Setting up minimal dependencies...');

    final apiService = ApiService();
    final authService = AuthService();
    final authRepository = AuthRepository();

    // Register essential services only
    Get.put<ApiService>(apiService, permanent: true);
    Get.put<AuthService>(authService, permanent: true);
    Get.put<IAuthRepository>(authRepository, permanent: true);
    Get.put<AuthRepository>(authRepository, permanent: true);

    print('✅ MinimalBinding: Minimal dependencies registered');
  }
}

// Lazy loading binding for non-critical services
class LazyServicesBinding extends Bindings {
  @override
  void dependencies() {
    print('🔄 LazyServicesBinding: Setting up lazy dependencies...');

    // Services loaded on demand
    Get.lazyPut<FileService>(() => FileService(), fenix: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);

    print('✅ LazyServicesBinding: Lazy dependencies registered');
  }
}