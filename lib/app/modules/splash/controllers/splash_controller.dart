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
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    animationController.repeat();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Minimum splash time for UX
      _authService.navigateBasedOnAuthState();
    } catch (e) {
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  @override
  Future<void> refreshData() async {}
}