import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Authentication-specific binding
/// This binding is used for login, registration, and other auth-related pages
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    print('🔐 AuthBinding: Setting up authentication dependencies...');

    // ✅ OPTIMIZED: Only register AuthController if not already registered
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
            () => AuthController(),
        fenix: true, // Allow recreation if disposed
      );
      print('✅ AuthBinding: AuthController registered');
    } else {
      print('✅ AuthBinding: AuthController already available');
    }

    print('🎉 AuthBinding: All authentication dependencies loaded');
  }
}

/// ✅ SIMPLIFIED: Single login binding without conflicts
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    print('📱 LoginBinding: Setting up login page dependencies...');

    // Use the same registration strategy as AuthBinding
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
            () => AuthController(),
        fenix: true,
      );
      print('✅ LoginBinding: AuthController registered');
    } else {
      print('✅ LoginBinding: AuthController already available');
    }

    print('✅ LoginBinding: Login dependencies registered');
  }
}

/// ✅ SIMPLIFIED: Profile binding
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    print('👤 ProfileBinding: Setting up profile management dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      print('✅ ProfileBinding: AuthController registered');
    } else {
      print('✅ ProfileBinding: AuthController already available');
    }

    // Add profile-specific controllers here when needed
    // Get.lazyPut<ProfileController>(() => ProfileController());

    print('✅ ProfileBinding: Profile dependencies registered');
  }
}

/// ✅ SIMPLIFIED: Role-based bindings
class StudentBinding extends Bindings {
  @override
  void dependencies() {
    print('🎓 StudentBinding: Setting up student dependencies...');

    _ensureAuthController();

    // Student-specific controllers
    // Get.lazyPut<StudentDashboardController>(() => StudentDashboardController());

    print('✅ StudentBinding: Student dependencies registered');
  }
}

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    print('👨‍🏫 TeacherBinding: Setting up teacher dependencies...');

    _ensureAuthController();

    // Teacher-specific controllers
    // Get.lazyPut<TeacherDashboardController>(() => TeacherDashboardController());

    print('✅ TeacherBinding: Teacher dependencies registered');
  }
}

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    print('👨‍👩‍👧‍👦 ParentBinding: Setting up parent dependencies...');

    _ensureAuthController();

    // Parent-specific controllers
    // Get.lazyPut<ParentDashboardController>(() => ParentDashboardController());

    print('✅ ParentBinding: Parent dependencies registered');
  }
}

/// ✅ HELPER: Common method to ensure AuthController is available
void _ensureAuthController() {
  if (!Get.isRegistered<AuthController>()) {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    print('✅ AuthController registered');
  } else {
    print('✅ AuthController already available');
  }
}

/// ✅ OPTIMIZED: Common binding for shared controllers
class CommonBinding extends Bindings {
  @override
  void dependencies() {
    print('🔄 CommonBinding: Setting up common dependencies...');

    _ensureAuthController();

    // Add other commonly used controllers
    // Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
    // Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);

    print('✅ CommonBinding: Common dependencies registered');
  }
}