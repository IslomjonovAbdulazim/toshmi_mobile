import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/auth_service.dart';
import '../../../utils/helpers/validation_helper.dart';
import '../views/register_view.dart';
import '../views/waiting_view.dart';
import '../views/login_view.dart';

class AuthController extends BaseController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final AuthService _authService = Get.find<AuthService>();

  // Login Form
  final loginFormKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final RxString selectedRole = 'student'.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoginLoading = false.obs;

  final RxString loginError = ''.obs;
  final RxBool hasLoginError = false.obs;

  // Registration Form
  final registerFormKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Registration State
  final RxBool isRegisterLoading = false.obs;
  final RxBool isRegisterPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool hasRegisterError = false.obs;
  final RxString registerError = ''.obs;
  final RxString selectedRegisterRole = 'student'.obs;

  // Registered User Info (for waiting view)
  final RxString registeredFirstName = ''.obs;
  final RxString registeredLastName = ''.obs;
  final RxString registeredPhone = ''.obs;
  final RxString registeredRole = ''.obs;

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
    // Only dispose if really closing the auth flow
    if (!Get.isRegistered<AuthController>()) {
      _disposeControllers();
    }
    super.onClose();
  }

  void _setupErrorClearListeners() {
    phoneController.addListener(_clearLoginError);
    passwordController.addListener(_clearLoginError);
    registerPhoneController.addListener(_clearRegisterError);
    registerPasswordController.addListener(_clearRegisterError);
    firstNameController.addListener(_clearRegisterError);
    lastNameController.addListener(_clearRegisterError);
    confirmPasswordController.addListener(_clearRegisterError);
  }

  void _clearLoginError() {
    if (hasLoginError.value) {
      hasLoginError.value = false;
      loginError.value = '';
    }
  }

  void _clearRegisterError() {
    if (hasRegisterError.value) {
      hasRegisterError.value = false;
      registerError.value = '';
    }
  }

  void _disposeControllers() {
    phoneController.removeListener(_clearLoginError);
    passwordController.removeListener(_clearLoginError);
    registerPhoneController.removeListener(_clearRegisterError);
    registerPasswordController.removeListener(_clearRegisterError);
    firstNameController.removeListener(_clearRegisterError);
    lastNameController.removeListener(_clearRegisterError);
    confirmPasswordController.removeListener(_clearRegisterError);

    phoneController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
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

  // Registration Methods
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) return;

    try {
      isRegisterLoading.value = true;
      hasRegisterError.value = false;
      registerError.value = '';

      final cleanPhone = _cleanPhoneNumber(registerPhoneController.text.trim());

      if (cleanPhone.length != 13 || !cleanPhone.startsWith('+998')) {
        _showRegisterError('phone_format_error'.tr);
        return;
      }

      registeredFirstName.value = firstNameController.text.trim();
      registeredLastName.value = lastNameController.text.trim();
      registeredPhone.value = cleanPhone;
      registeredRole.value = selectedRegisterRole.value;

      Get.to(() => const WaitingView());
      showSuccess('registration_submitted'.tr);
      _clearRegisterForm();

    } catch (e) {
      _showRegisterError(_getUserFriendlyError(e.toString()));
    } finally {
      isRegisterLoading.value = false;
    }
  }

  void _showRegisterError(String message) {
    hasRegisterError.value = true;
    registerError.value = message;

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

  void _clearRegisterForm() {
    firstNameController.clear();
    lastNameController.clear();
    registerPhoneController.clear();
    registerPasswordController.clear();
    confirmPasswordController.clear();
    hasRegisterError.value = false;
    registerError.value = '';
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void setRegisterRole(String role) {
    selectedRegisterRole.value = role;
    _clearRegisterError();
  }

  // Navigation Methods
  void goToRegister() {
    Get.to(() => const RegisterView());
  }

  void backToLogin() {
    // Just go back to login without disposing controller
    Get.back();
    Get.back(); // Go back twice (waiting -> register -> login)
  }

  void showContactSupport() {
    Get.dialog(
      AlertDialog(
        title: Text('contact_support'.tr),
        content: Text('contact_support_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  // Additional Validation Methods
  String? validateFirstName(String? value) {
    if (ValidationHelper.required(value, fieldName: 'first_name'.tr) != null) {
      return 'first_name_required'.tr;
    }
    if (value!.trim().length < 2) {
      return 'first_name_min_length'.tr;
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (ValidationHelper.required(value, fieldName: 'last_name'.tr) != null) {
      return 'last_name_required'.tr;
    }
    if (value!.trim().length < 2) {
      return 'last_name_min_length'.tr;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (ValidationHelper.required(value, fieldName: 'confirm_password'.tr) != null) {
      return 'confirm_password_required'.tr;
    }
    if (value != registerPasswordController.text) {
      return 'passwords_do_not_match'.tr;
    }
    return null;
  }
}