import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Authentication-specific binding
/// This binding is used for login, registration, and other auth-related pages
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    print('🔐 AuthBinding: Setting up authentication dependencies...');

    // Auth Controller - main controller for authentication UI
    Get.lazyPut<AuthController>(
          () => AuthController(),
      fenix: true, // Allow recreation if disposed
    );
    print('✅ AuthBinding: AuthController registered');

    // Add other auth-related controllers here
    // Example:
    // Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
    // Get.lazyPut<RegistrationController>(() => RegistrationController());

    print('🎉 AuthBinding: All authentication dependencies loaded');
  }
}

/// Login page specific binding
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    print('📱 LoginBinding: Setting up login page dependencies...');

    // Auth Controller for login functionality
    Get.put<AuthController>(
      AuthController(),
      permanent: false, // Will be disposed when page is removed
    );

    print('✅ LoginBinding: Login dependencies registered');
  }
}

/// Profile management binding
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    print('👤 ProfileBinding: Setting up profile management dependencies...');

    // Ensure AuthController is available (it should be from login)
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Profile-specific controllers (if you have them)
    // Get.lazyPut<ProfileController>(() => ProfileController());
    // Get.lazyPut<SettingsController>(() => SettingsController());

    print('✅ ProfileBinding: Profile dependencies registered');
  }
}

/// Password management binding
class PasswordBinding extends Bindings {
  @override
  void dependencies() {
    print('🔑 PasswordBinding: Setting up password management dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Password-specific controllers (if you have them)
    // Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
    // Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());

    print('✅ PasswordBinding: Password dependencies registered');
  }
}

/// Splash screen binding
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    print('💫 SplashBinding: Setting up splash screen dependencies...');

    // Splash controller for app initialization
    // Get.put<SplashController>(SplashController());

    // Pre-load AuthController for faster login
    Get.put<AuthController>(
      AuthController(),
      permanent: true, // Keep alive for smooth transition to login
    );

    print('✅ SplashBinding: Splash dependencies registered');
  }
}

/// Role-specific bindings for different user types

/// Student dashboard binding
class StudentBinding extends Bindings {
  @override
  void dependencies() {
    print('🎓 StudentBinding: Setting up student dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Student-specific controllers
    // Get.lazyPut<StudentDashboardController>(() => StudentDashboardController());
    // Get.lazyPut<StudentHomeworkController>(() => StudentHomeworkController());
    // Get.lazyPut<StudentGradesController>(() => StudentGradesController());
    // Get.lazyPut<StudentAttendanceController>(() => StudentAttendanceController());

    print('✅ StudentBinding: Student dependencies registered');
  }
}

/// Teacher dashboard binding
class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    print('👨‍🏫 TeacherBinding: Setting up teacher dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Teacher-specific controllers
    // Get.lazyPut<TeacherDashboardController>(() => TeacherDashboardController());
    // Get.lazyPut<TeacherHomeworkController>(() => TeacherHomeworkController());
    // Get.lazyPut<TeacherGradingController>(() => TeacherGradingController());
    // Get.lazyPut<TeacherAttendanceController>(() => TeacherAttendanceController());

    print('✅ TeacherBinding: Teacher dependencies registered');
  }
}

/// Parent dashboard binding
class ParentBinding extends Bindings {
  @override
  void dependencies() {
    print('👨‍👩‍👧‍👦 ParentBinding: Setting up parent dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Parent-specific controllers
    // Get.lazyPut<ParentDashboardController>(() => ParentDashboardController());
    // Get.lazyPut<ParentChildrenController>(() => ParentChildrenController());
    // Get.lazyPut<ParentReportsController>(() => ParentReportsController());

    print('✅ ParentBinding: Parent dependencies registered');
  }
}

/// Admin dashboard binding (even though no admin login, they might access via other means)
class AdminBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 AdminBinding: Setting up admin dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Admin-specific controllers
    // Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    // Get.lazyPut<UserManagementController>(() => UserManagementController());
    // Get.lazyPut<SystemSettingsController>(() => SystemSettingsController());

    print('✅ AdminBinding: Admin dependencies registered');
  }
}

/// Notification-related binding
class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    print('🔔 NotificationBinding: Setting up notification dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Notification-specific controllers
    // Get.lazyPut<NotificationController>(() => NotificationController());
    // Get.lazyPut<NotificationSettingsController>(() => NotificationSettingsController());

    print('✅ NotificationBinding: Notification dependencies registered');
  }
}

/// Settings and preferences binding
class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    print('⚙️ SettingsBinding: Setting up settings dependencies...');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Settings-specific controllers
    // Get.lazyPut<SettingsController>(() => SettingsController());
    // Get.lazyPut<ThemeController>(() => ThemeController());
    // Get.lazyPut<LanguageController>(() => LanguageController());

    print('✅ SettingsBinding: Settings dependencies registered');
  }
}

/// Utility binding for common page combinations
class CommonPageBinding extends Bindings {
  @override
  void dependencies() {
    print('🔄 CommonPageBinding: Setting up common page dependencies...');

    // Controllers that are commonly used across multiple pages
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController());
    }

    // Add other commonly used controllers
    // Get.lazyPut<NavigationController>(() => NavigationController());
    // Get.lazyPut<ThemeController>(() => ThemeController());

    print('✅ CommonPageBinding: Common dependencies registered');
  }
}

/// Lazy binding helper for performance optimization
class LazyBinding extends Bindings {
  @override
  void dependencies() {
    print('⚡ LazyBinding: Setting up lazy dependencies...');

    // Use lazyPut for better memory management
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Add other lazy-loaded controllers
    // Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    // Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);

    print('✅ LazyBinding: Lazy dependencies registered');
  }
}