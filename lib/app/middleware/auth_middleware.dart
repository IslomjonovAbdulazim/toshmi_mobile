import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Allow public routes
    if (_isPublicRoute(route)) {
      return null;
    }

    // Check if user is authenticated
    if (!_isAuthenticated()) {
      print('❌ AuthMiddleware: Not authenticated, redirecting to login');
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    return null;
  }

  bool _isPublicRoute(String? route) {
    const publicRoutes = [
      AppRoutes.LOGIN,
      AppRoutes.SPLASH,
    ];
    return route != null && publicRoutes.contains(route);
  }

  bool _isAuthenticated() {
    try {
      // Try to get from controller first
      final authController = Get.find<AuthController>();
      return authController.isAuthenticated;
    } catch (e) {
      // Fallback: check storage directly
      final storage = GetStorage();
      final token = storage.read<String>('user_token');
      return token != null && token.isNotEmpty;
    }
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (_isAuthenticated()) {
      print('✅ GuestMiddleware: User authenticated, redirecting to profile');
      return const RouteSettings(name: AppRoutes.PROFILE);
    }
    return null;
  }

  bool _isAuthenticated() {
    try {
      final authController = Get.find<AuthController>();
      return authController.isAuthenticated;
    } catch (e) {
      final storage = GetStorage();
      final token = storage.read<String>('user_token');
      return token != null && token.isNotEmpty;
    }
  }
}

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware({required this.allowedRoles});

  @override
  int? get priority => 2; // After auth middleware

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();
      final userRole = authController.selectedRole;

      if (!allowedRoles.contains(userRole)) {
        print('❌ RoleMiddleware: User role $userRole not allowed for $route');
        return const RouteSettings(name: AppRoutes.PROFILE);
      }

      return null;
    } catch (e) {
      print('❌ RoleMiddleware: Error checking role - $e');
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
  }
}