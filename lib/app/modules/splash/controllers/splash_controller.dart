// lib/app/modules/splash/controllers/splash_controller.dart
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
    print('🚀 SplashController initialized');
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
    try {
      print('⏱️ Starting splash sequence...');

      // Start loading animation
      animationController.repeat();

      // Wait for splash duration
      await Future.delayed(const Duration(seconds: 3));

      // Check authentication and navigate
      await _checkAuthAndNavigate();
    } catch (e) {
      print('❌ Splash sequence error: $e');
      // On any error, go to login
      Get.offAllNamed(Routes.login);
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      print('🔍 Checking authentication state...');

      // Use the new AuthService method for navigation
      _authService.navigateBasedOnAuthState();

    } catch (e) {
      print('❌ Auth check error: $e');
      // On error, go to login
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  void onClose() {
    print('🗑️ SplashController disposing...');
    animationController.dispose();
    super.onClose();
  }

  @override
  Future<void> refreshData() async {
    // No data to refresh on splash
  }
}