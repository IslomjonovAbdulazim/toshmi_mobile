// Replace the entire ProfileController with this:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/theme_service.dart';
import '../../../data/repositories/teacher_repository.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ThemeService _themeService = ThemeService();
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;
  final currentThemeMode = ThemeMode.system.obs;

  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    currentThemeMode.value = _themeService.theme;
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void changeTheme(ThemeMode themeMode) {
    currentThemeMode.value = themeMode;
    _themeService.changeThemeMode(themeMode);
  }

  String get currentUserName => _authService.currentUser?.fullName ?? 'Foydalanuvchi';
  String get currentUserRole => _authService.userRole ?? '';

  Future<void> changePassword() async {
    if (currentPasswordController.text.isEmpty) {
      Get.snackbar('Xato', 'Joriy parolni kiriting');
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar('Xato', 'Yangi parol kamida 6 ta belgidan iborat bo\'lishi kerak');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('Xato', 'Yangi parollar mos kelmaydi');
      return;
    }

    try {
      isLoading.value = true;
      await _teacherRepository.changePassword(
        oldPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.snackbar(
        'Muvaffaqiyat',
        'Parol muvaffaqiyatli o\'zgartirildi',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Xato', 'Parolni o\'zgartirishda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Xato', 'Chiqishda xatolik: $e');
    }
  }
}