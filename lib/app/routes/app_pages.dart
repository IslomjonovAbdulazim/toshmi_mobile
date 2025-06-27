import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/profile_page.dart';
import '../../presentation/pages/auth/splash_page.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../bindings/auth_binding.dart';
import '../middleware/auth_middleware.dart';
import 'app_routes.dart';

/// Application pages configuration
class AppPages {
  AppPages._();

  // ===================== ROUTE DEFINITIONS =====================
  static final routes = [
    // Splash Page
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fade,
    ),

    // Login Page
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      middlewares: [GuestMiddleware()], // Redirect if already logged in
      transition: Transition.rightToLeft,
    ),

    // Profile Page
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()], // Require authentication
      transition: Transition.rightToLeft,
    ),
  ];

  // ===================== UNKNOWN ROUTE HANDLER =====================
  static GetPage unknownRoute = GetPage(
    name: '/not-found',
    page: () => const Scaffold(
      body: Center(
        child: Text('Sahifa topilmadi'),
      ),
    ),
  );
}

// ===================== BINDINGS =====================

/// ✅ FIXED: Splash binding now properly registers AuthController
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    print('💫 SplashBinding: Setting up splash screen dependencies...');

    // ✅ Register AuthController for splash page auth checking
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(),
        permanent: true, // Keep alive for smooth transition
      );
      print('✅ SplashBinding: AuthController registered');
    } else {
      print('✅ SplashBinding: AuthController already available');
    }

    print('✅ SplashBinding: Splash dependencies registered');
  }
}

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

    print('✅ ProfileBinding: Profile dependencies registered');
  }
}