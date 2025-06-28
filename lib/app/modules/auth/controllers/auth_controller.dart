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
    _setupErrorClearListeners();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // Setup listeners to clear errors when user types
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

  // Clean phone number (remove formatting)
  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\+\d]'), '');
  }

  // Get user-friendly error message
  String _getUserFriendlyError(String error) {
    if (error.toLowerCase().contains('invalid credentials')) {
      return 'Telefon raqam yoki parol noto\'g\'ri';
    } else if (error.toLowerCase().contains('not found')) {
      return 'Foydalanuvchi topilmadi';
    } else if (error.toLowerCase().contains('network') ||
        error.toLowerCase().contains('connection')) {
      return 'Internet aloqasi yo\'q. Qayta urinib ko\'ring';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'Ulanish vaqti tugadi. Qayta urinib ko\'ring';
    } else if (error.toLowerCase().contains('server error')) {
      return 'Server xatoligi. Keyinroq urinib ko\'ring';
    }
    return 'Kirish jarayonida xatolik yuz berdi';
  }

  // Login - FIXED: No navigation on error
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoginLoading.value = true;
      hasLoginError.value = false;
      loginError.value = '';

      // Clean phone number before sending
      final cleanPhone = _cleanPhoneNumber(phoneController.text.trim());

      // Validate cleaned phone
      if (cleanPhone.length != 13 || !cleanPhone.startsWith('+998')) {
        _showLoginError('Telefon raqam noto\'g\'ri formatda');
        return;
      }

      // Attempt login
      final result = await _authRepository.login(
        phone: cleanPhone,
        password: passwordController.text,
        role: selectedRole.value,
      );

      // Only on SUCCESS - clear form and navigate
      if (result != null) {
        showSuccess('Muvaffaqiyatli kirildi');
        _clearLoginForm();
        // AuthService will handle navigation based on role
      }

    } catch (e) {
      // Stay on login page and show error
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

  // Clear login form
  void _clearLoginForm() {
    phoneController.clear();
    passwordController.clear();
    hasLoginError.value = false;
    loginError.value = '';
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Set role
  void setRole(String role) {
    selectedRole.value = role;
    _clearLoginError();
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