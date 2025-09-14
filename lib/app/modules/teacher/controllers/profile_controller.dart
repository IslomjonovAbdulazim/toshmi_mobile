import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/language_service.dart';
import '../../../services/theme_service.dart';
import '../../../data/repositories/teacher_repository.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ThemeService _themeService = ThemeService();
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final LanguageService _languageService = LanguageService();
  final currentLocale = const Locale('uz', 'UZ').obs;

  void changeLanguage(Locale locale) {
    currentLocale.value = locale;
    _languageService.changeLanguage(locale);
  }

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
    currentLocale.value = _languageService.locale;
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

  String get currentUserName => _authService.currentUser?.fullName ?? 'user'.tr;
  String get currentUserRole => _authService.userRole ?? '';
  
  // Expose auth service for accessing current user
  AuthService get authService => _authService;
  
  // Avatar update callback
  void onAvatarUpdated() {
    // Trigger UI rebuild to show updated avatar
    update();
  }

  Future<void> changePassword() async {
    if (currentPasswordController.text.isEmpty) {
      Get.snackbar('error'.tr, 'error_current_password_required'.tr);
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar('error'.tr, 'error_password_min_length'.tr);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('error'.tr, 'error_passwords_mismatch'.tr);
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
        'success'.tr,
        'success_password_changed'.tr,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_password_change'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_logout'.tr}: $e');
    }
  }
}