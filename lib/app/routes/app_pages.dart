import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/profile_page.dart';
import '../../presentation/pages/auth/splash_page.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../bindings/auth_binding.dart';
import '../middleware/auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

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
      middlewares: [GuestMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Profile Page
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Edit Profile Page
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfilePage(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Change Password Page
    GetPage(
      name: AppRoutes.CHANGE_PASSWORD,
      page: () => const ChangePasswordPage(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
  ];

  static GetPage unknownRoute = GetPage(
    name: AppRoutes.NOT_FOUND,
    page: () => const NotFoundPage(),
  );
}

// Bindings
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    print('💫 SplashBinding: Setting up splash screen dependencies...');

    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(),
        permanent: true,
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

    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
      print('✅ ProfileBinding: AuthController registered');
    } else {
      print('✅ ProfileBinding: AuthController already available');
    }

    print('✅ ProfileBinding: Profile dependencies registered');
  }
}

// Placeholder pages for routes that are defined but not yet implemented
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilni tahrirlash')),
      body: const Center(
        child: Text('Edit Profile Page - Coming Soon'),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parolni o\'zgartirish')),
      body: const Center(
        child: Text('Change Password Page - Coming Soon'),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sahifa topilmadi')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '404 - Sahifa topilmadi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Siz qidirayotgan sahifa mavjud emas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
        child: const Icon(Icons.home),
      ),
    );
  }
}