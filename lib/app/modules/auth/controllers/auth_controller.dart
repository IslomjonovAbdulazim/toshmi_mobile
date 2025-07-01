import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/auth_service.dart';
import '../../../utils/helpers/validation_helper.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final loginFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final RxString selectedRole = 'student'.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoginLoading = false.obs;

  final RxString loginError = ''.obs;
  final RxBool hasLoginError = false.obs;

  final List<Map<String, String>> roles = [
    {'value': 'student', 'label': 'student'},
    {'value': 'teacher', 'label': 'teacher'},
    {'value': 'parent', 'label': 'parent'},
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
      return 'invalid_credentials'.tr;
    } else if (errorLower.contains('not found')) {
      return 'user_not_found'.tr;
    } else if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'network_error'.tr;
    } else if (errorLower.contains('timeout')) {
      return 'timeout_error'.tr;
    } else if (errorLower.contains('server error')) {
      return 'server_error'.tr;
    }
    return 'login_error'.tr;
  }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoginLoading.value = true;
      hasLoginError.value = false;
      loginError.value = '';

      final cleanPhone = _cleanPhoneNumber(phoneController.text.trim());

      if (cleanPhone.length != 13 || !cleanPhone.startsWith('+998')) {
        _showLoginError('phone_format_error'.tr);
        return;
      }

      final result = await _authRepository.login(
        phone: cleanPhone,
        password: passwordController.text,
        role: selectedRole.value,
      );

      if (result != null) {
        showSuccess('login_success'.tr);
        _clearLoginForm();
      } else {
        _showLoginError('login_error'.tr);
      }

    } catch (e) {
      _showLoginError(_getUserFriendlyError(e.toString()));
    } finally {
      isLoginLoading.value = false;
    }
  }

  void _showLoginError(String message) {
    hasLoginError.value = true;
    loginError.value = message;

    Get.snackbar(
      'error'.tr,
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
  }

  String? validatePhone(String? value) {
    if (ValidationHelper.required(value, fieldName: 'phone_number'.tr) != null) {
      return 'phone_required'.tr;
    }

    final cleanPhone = _cleanPhoneNumber(value ?? '');

    if (cleanPhone.length != 13) {
      return 'phone_incomplete'.tr;
    }

    if (!cleanPhone.startsWith('+998')) {
      return 'phone_format'.tr;
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (ValidationHelper.required(value, fieldName: 'password'.tr) != null) {
      return 'password_required'.tr;
    }
    if (value!.length < 3) {
      return 'password_min_length'.tr;
    }
    return null;
  }

  @override
  Future<void> refreshData() async {}
}