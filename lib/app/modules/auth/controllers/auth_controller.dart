import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/auth_service.dart';
import '../../../utils/helpers/validation_helper.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final AuthService _authService = Get.find<AuthService>();

  // Login form
  final loginFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final RxString selectedRole = 'student'.obs;
  final RxBool isPasswordVisible = false.obs;

  // Change password form
  final changePasswordFormKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isOldPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Profile form
  final profileFormKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Available roles
  final List<Map<String, String>> roles = [
    {'value': 'student', 'label': 'O\'quvchi'},
    {'value': 'teacher', 'label': 'O\'qituvchi'},
    {'value': 'parent', 'label': 'Ota-ona'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  // Login
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      setLoading(true);
      clearError();

      await _authRepository.login(
        phone: phoneController.text.trim(),
        password: passwordController.text,
        role: selectedRole.value,
      );

      showSuccess('Muvaffaqiyatli kirildi');
      _clearLoginForm();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Change password
  Future<void> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;

    try {
      setLoading(true);
      clearError();

      await _authRepository.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );

      showSuccess('Parol muvaffaqiyatli o\'zgartirildi');
      _clearPasswordForm();
      Get.back();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Update profile
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    try {
      setLoading(true);
      clearError();

      await _authRepository.updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );

      showSuccess('Profil muvaffaqiyatli yangilandi');
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    final confirm = await showConfirmDialog(
      title: 'Chiqish',
      message: 'Haqiqatan ham chiqmoqchimisiz?',
      confirmText: 'Ha, chiqish',
      cancelText: 'Bekor qilish',
    );

    if (confirm == true) {
      await _authService.logout();
      showInfo('Muvaffaqiyatli chiqildi');
    }
  }

  // Load profile data
  void _loadProfileData() {
    final user = _authService.currentUser;
    if (user != null) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
    }
  }

  // Clear forms
  void _clearLoginForm() {
    phoneController.clear();
    passwordController.clear();
  }

  void _clearPasswordForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleOldPasswordVisibility() {
    isOldPasswordVisible.value = !isOldPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Set role
  void setRole(String role) {
    selectedRole.value = role;
  }

  // Validation methods
  String? validatePhone(String? value) {
    if (ValidationHelper.required(value, fieldName: 'Telefon raqami') != null) {
      return ValidationHelper.required(value, fieldName: 'Telefon raqami');
    }
    // Clean the formatted phone number before validation
    final cleanPhone = value?.replaceAll(RegExp(r'[^\+\d]'), '') ?? '';
    return ValidationHelper.phone(cleanPhone);
  }

  String? validatePassword(String? value) {
    if (ValidationHelper.required(value, fieldName: 'Parol') != null) {
      return ValidationHelper.required(value, fieldName: 'Parol');
    }
    return ValidationHelper.password(value);
  }

  String? validateConfirmPassword(String? value) {
    if (ValidationHelper.required(value, fieldName: 'Parolni tasdiqlash') !=
        null) {
      return ValidationHelper.required(value, fieldName: 'Parolni tasdiqlash');
    }
    return ValidationHelper.confirmPassword(value, newPasswordController.text);
  }

  String? validateName(String? value, String fieldName) {
    if (ValidationHelper.required(value, fieldName: fieldName) != null) {
      return ValidationHelper.required(value, fieldName: fieldName);
    }
    return ValidationHelper.minLength(value, 2, fieldName: fieldName);
  }

  @override
  Future<void> refreshData() async {
    await _authRepository.getProfile();
    _loadProfileData();
  }
}
