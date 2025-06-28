import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends BaseController with GetSingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();

  late AnimationController animationController;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  Future<void> _startSplashSequence() async {
    // Start loading animation
    animationController.repeat();

    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check authentication and navigate
    await _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      if (_authService.isLoggedIn && _authService.currentUser != null) {
        // User is logged in, navigate to role-based home
        _navigateToRoleBasedHome();
      } else {
        // User not logged in, go to login
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      // Error occurred, go to login
      Get.offAllNamed(Routes.login);
    }
  }

  void _navigateToRoleBasedHome() {
    switch (_authService.userRole?.toLowerCase()) {
      case 'teacher':
        Get.offAllNamed('/teacher');
        break;
      case 'student':
        Get.offAllNamed('/student');
        break;
      case 'parent':
        Get.offAllNamed('/parent');
        break;
      case 'admin':
        Get.offAllNamed('/admin');
        break;
      default:
        Get.offAllNamed(Routes.login);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  @override
  Future<void> refreshData() async {
    // No data to refresh on splash
  }
}