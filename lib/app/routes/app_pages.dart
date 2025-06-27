import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/profile_page.dart';
import '../../presentation/pages/auth/splash_page.dart';
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

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Core services are already initialized in InitialBinding
  }
}

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // AuthController should already be available
  }
}