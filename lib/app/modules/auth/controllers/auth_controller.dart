// lib/app/modules/auth/controllers/auth_controller.dart
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
  final RxBool isLoginLoading = false.obs;

  // Error handling
  final RxString loginError = ''.obs;
  final RxBool hasLoginError = false.obs;

  // Available roles
  final List<Map<String, String>> roles = [
    {'value': 'student', 'label': 'O\'quvchi'},
    {'value': 'teacher', 'label': 'O\'qituvchi'},
    {'value': 'parent', 'label': 'Ota-ona'},
  ];

  @override
  void onInit() {
    super.onInit();
    print('🎮 AuthController initialized');
    _setupErrorClearListeners();
  }

  @override
  void onClose() {
    print('🗑️ AuthController disposing...');
    _disposeControllers();
    super.onClose();
  }

  void _setupErrorClearListeners() {
    phoneController.addListener(_clearLoginError);
    passwordController.addListener(_clearLoginError);
  }

  void _clearLoginError() {
    if (hasLoginError.value) {
      hasLoginError.value = false;
      loginError.value = '';
    }
  }

  void _disposeControllers() {
    phoneController.removeListener(_clearLoginError);
    passwordController.removeListener(_clearLoginError);
    phoneController.dispose();
    passwordController.dispose();
  }

  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\+\d]'), '');
  }

  String _getUserFriendlyError(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('invalid credentials')) {
      return 'Telefon raqam yoki parol noto\'g\'ri';
    } else if (errorLower.contains('not found')) {
      return 'Foydalanuvchi topilmadi';
    } else if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Internet aloqasi yo\'q. Qayta urinib ko\'ring';
    } else if (errorLower.contains('timeout')) {
      return 'Ulanish vaqti tugadi. Qayta urinib ko\'ring';
    } else if (errorLower.contains('server error')) {
      return 'Server xatoligi. Keyinroq urinib ko\'ring';
    }
    return 'Kirish jarayonida xatolik yuz berdi';
  }

  // FIXED: Simplified login with better error handling
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    try {
      print('🔐 Starting login process...');
      isLoginLoading.value = true;
      hasLoginError.value = false;
      loginError.value = '';

      // Clean and validate phone number
      final cleanPhone = _cleanPhoneNumber(phoneController.text.trim());
      print('📱 Clean phone: $cleanPhone');

      if (cleanPhone.length != 13 || !cleanPhone.startsWith('+998')) {
        _showLoginError('Telefon raqam noto\'g\'ri formatda');
        return;
      }

      // Attempt login
      print('🚀 Calling repository login...');
      final result = await _authRepository.login(
        phone: cleanPhone,
        password: passwordController.text,
        role: selectedRole.value,
      );

      if (result != null) {
        print('✅ Login successful');
        showSuccess('Muvaffaqiyatli kirildi');
        _clearLoginForm();
        // Navigation is handled by AuthService automatically
      } else {
        _showLoginError('Login jarayonida xatolik yuz berdi');
      }

    } catch (e) {
      print('❌ Login error: $e');
      _showLoginError(_getUserFriendlyError(e.toString()));
    } finally {
      isLoginLoading.value = false;
    }
  }

  void _showLoginError(String message) {
    hasLoginError.value = true;
    loginError.value = message;

    // Also show snackbar for immediate feedback
    Get.snackbar(
      'Xatolik',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade700,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  void _clearLoginForm() {
    phoneController.clear();
    passwordController.clear();
    hasLoginError.value = false;
    loginError.value = '';
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void setRole(String role) {
    selectedRole.value = role;
    _clearLoginError();
    print('🎭 Role selected: $role');
  }

  // Enhanced validation methods
  String? validatePhone(String? value) {
    if (ValidationHelper.required(value, fieldName: 'Telefon raqami') != null) {
      return ValidationHelper.required(value, fieldName: 'Telefon raqami');
    }

    final cleanPhone = _cleanPhoneNumber(value ?? '');

    if (cleanPhone.length != 13) {
      return 'Telefon raqam to\'liq kiritilmagan';
    }

    if (!cleanPhone.startsWith('+998')) {
      return 'Telefon raqam +998 bilan boshlanishi kerak';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (ValidationHelper.required(value, fieldName: 'Parol') != null) {
      return ValidationHelper.required(value, fieldName: 'Parol');
    }
    if (value!.length < 3) {
      return 'Parol kamida 3 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  @override
  Future<void> refreshData() async {
    // Don't auto-refresh on login page
  }
}