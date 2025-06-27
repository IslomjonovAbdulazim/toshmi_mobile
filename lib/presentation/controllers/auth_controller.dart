import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final IAuthRepository _authRepository = Get.find<IAuthRepository>();

  // ===================== REACTIVE VARIABLES =====================

  // Loading states
  final _isLoading = false.obs;
  final _isLoginLoading = false.obs;
  final _isLogoutLoading = false.obs;

  // Form data
  final _selectedRole = UserRoles.student.obs;
  final _rememberMe = false.obs;

  // Form controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Form validation
  final _phoneError = Rxn<String>();
  final _passwordError = Rxn<String>();
  final _formValid = false.obs;

  // Password visibility
  final _isPasswordVisible = false.obs;
  final _isOldPasswordVisible = false.obs;
  final _isNewPasswordVisible = false.obs;

  // User state
  final _isAuthenticated = false.obs;
  final _currentUser = Rxn<User>();

  // ===================== GETTERS =====================

  bool get isLoading => _isLoading.value;
  bool get isLoginLoading => _isLoginLoading.value;
  bool get isLogoutLoading => _isLogoutLoading.value;

  String get selectedRole => _selectedRole.value;
  bool get rememberMe => _rememberMe.value;

  String? get phoneError => _phoneError.value;
  String? get passwordError => _passwordError.value;
  bool get formValid => _formValid.value;

  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get isOldPasswordVisible => _isOldPasswordVisible.value;
  bool get isNewPasswordVisible => _isNewPasswordVisible.value;

  bool get isAuthenticated => _isAuthenticated.value;
  User? get currentUser => _currentUser.value;

  // ✅ FIXED: Local implementation of role getters
  bool get isAdmin => _authRepository.userRole == UserRoles.admin;
  bool get isTeacher => _authRepository.userRole == UserRoles.teacher;
  bool get isStudent => _authRepository.userRole == UserRoles.student;
  bool get isParent => _authRepository.userRole == UserRoles.parent;

  // ✅ FIXED: Local implementation of display getters
  String get userDisplayName {
    final user = _authRepository.currentUser;
    return user?.name ?? 'Unknown User';
  }

  String get userDisplayPhone {
    final user = _authRepository.currentUser;
    return user != null ? _authRepository.formatPhoneForDisplay(user.phone) : '';
  }

  // Role options for UI (only roles that can login)
  List<Map<String, String>> get roleOptions => [
    {'value': UserRoles.student, 'label': 'Talaba'},
    {'value': UserRoles.teacher, 'label': 'Ustoz'},
    {'value': UserRoles.parent, 'label': 'Ota-ona'},
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
    _setupFormValidation();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  // ===================== INITIALIZATION =====================

  void _initializeAuth() async {
    _isLoading.value = true;

    try {
      // Check if user is already authenticated
      _isAuthenticated.value = _authRepository.isAuthenticated;
      _currentUser.value = _authRepository.currentUser;

      if (_isAuthenticated.value) {
        // Verify authentication status
        final isValid = await _authRepository.checkAuthenticationStatus();
        if (!isValid) {
          await logout();
        }
      }
    } catch (e) {
      print('❌ Auth initialization error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _setupFormValidation() {
    // Listen to text controller changes properly
    phoneController.addListener(() {
      _validatePhone(phoneController.text);
      _updateFormValidity();
    });

    passwordController.addListener(() {
      _validatePassword(passwordController.text);
      _updateFormValidity();
    });
  }

  void _disposeControllers() {
    phoneController.dispose();
    passwordController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  // ===================== AUTHENTICATION METHODS =====================

  /// Login with phone, password and role
  Future<void> login() async {
    if (!validateForm()) {
      _showErrorSnackbar('Iltimos, barcha maydonlarni to\'g\'ri to\'ldiring');
      return;
    }

    _isLoginLoading.value = true;

    try {
      // ✅ FIXED: Clean phone number (remove spaces) before sending to API
      final cleanPhone = phoneController.text.trim().replaceAll(' ', '');

      final result = await _authRepository.login(
        phone: cleanPhone,
        password: passwordController.text,
        role: selectedRole,
      );

      if (result.isSuccess) {
        _currentUser.value = result.data;
        _isAuthenticated.value = true;

        _showSuccessSnackbar('Muvaffaqiyatli kirildi');
        _clearForm();

        // Navigate to appropriate dashboard
        _navigateToHomePage();
      } else {
        _showErrorSnackbar(result.failure?.message ?? 'Kirish jarayonida xatolik');
      }
    } catch (e) {
      _showErrorSnackbar('Kirish jarayonida xatolik yuz berdi');
      print('❌ Login error: $e');
    } finally {
      _isLoginLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLogoutLoading.value = true;

    try {
      await _authRepository.logout();

      _isAuthenticated.value = false;
      _currentUser.value = null;
      _clearForm();

      _showSuccessSnackbar('Muvaffaqiyatli chiqildi');
      Get.offAllNamed('/login');
    } catch (e) {
      _showErrorSnackbar('Chiqish jarayonida xatolik yuz berdi');
      print('❌ Logout error: $e');
    } finally {
      _isLogoutLoading.value = false;
    }
  }

  // ===================== PROFILE MANAGEMENT =====================

  /// Update user profile
  Future<void> updateProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      _showErrorSnackbar('Ism va familiya kiritilishi shart');
      return;
    }

    _isLoading.value = true;

    try {
      final result = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
      );

      if (result.isSuccess) {
        await _refreshUserData();
        _showSuccessSnackbar('Profil muvaffaqiyatli yangilandi');
        Get.back();
      } else {
        _showErrorSnackbar(result.failure?.message ?? 'Profilni yangilashda xatolik');
      }
    } catch (e) {
      _showErrorSnackbar('Profilni yangilashda xatolik yuz berdi');
      print('❌ Update profile error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Change user password
  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validation
    if (oldPassword.isEmpty) {
      _showErrorSnackbar('Hozirgi parolni kiriting');
      return;
    }

    if (newPassword.isEmpty) {
      _showErrorSnackbar('Yangi parolni kiriting');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorSnackbar('Yangi parollar mos kelmaydi');
      return;
    }

    final passwordValidation = _authRepository.validatePassword(newPassword);
    if (!passwordValidation.isValid) {
      _showErrorSnackbar(passwordValidation.errorMessage);
      return;
    }

    _isLoading.value = true;

    try {
      final result = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        _clearPasswordFields();
        _showSuccessSnackbar('Parol muvaffaqiyatli o\'zgartirildi');
        Get.back();
      } else {
        _showErrorSnackbar(result.failure?.message ?? 'Parolni o\'zgartirishda xatolik');
      }
    } catch (e) {
      _showErrorSnackbar('Parolni o\'zgartirishda xatolik yuz berdi');
      print('❌ Change password error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // ===================== FORM MANAGEMENT =====================

  /// Set selected role
  void setSelectedRole(String role) {
    _selectedRole.value = role;
  }

  /// Toggle remember me
  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  /// Toggle old password visibility
  void toggleOldPasswordVisibility() {
    _isOldPasswordVisible.value = !_isOldPasswordVisible.value;
  }

  /// Toggle new password visibility
  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible.value = !_isNewPasswordVisible.value;
  }

  /// Clear all form fields
  void _clearForm() {
    phoneController.clear();
    passwordController.clear();
    _phoneError.value = null;
    _passwordError.value = null;
    _formValid.value = false;
  }

  /// Clear password fields only
  void _clearPasswordFields() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  /// Clear profile fields
  void clearProfileFields() {
    firstNameController.clear();
    lastNameController.clear();
  }

  // ===================== VALIDATION =====================

  void _validatePhone(String phone) {
    if (phone.isEmpty) {
      _phoneError.value = 'Telefon raqamini kiriting';
    } else {
      // ✅ FIXED: Remove spaces before validation
      final cleanPhone = phone.replaceAll(' ', '');
      if (!_authRepository.isValidPhone(cleanPhone)) {
        _phoneError.value = 'Telefon raqami noto\'g\'ri formatda (+998XXXXXXXXX)';
      } else {
        _phoneError.value = null;
      }
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      _passwordError.value = 'Parolni kiriting';
    } else if (password.length < 6) {
      _passwordError.value = 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
    } else {
      _passwordError.value = null;
    }
  }

  void _updateFormValidity() {
    // ✅ FIXED: Check cleaned phone for proper validation
    final cleanPhone = phoneController.text.replaceAll(' ', '');
    _formValid.value = phoneError == null &&
        passwordError == null &&
        cleanPhone.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  /// Manual form validation trigger
  bool validateForm() {
    _validatePhone(phoneController.text);
    _validatePassword(passwordController.text);
    _updateFormValidity();
    return formValid;
  }

  // ===================== USER DATA MANAGEMENT =====================

  /// ✅ FIXED: Local implementation of refresh user data
  Future<void> refreshUserData() => _refreshUserData();

  Future<void> _refreshUserData() async {
    try {
      // Since interface doesn't have refreshUserData, get profile directly
      final profileResult = await _authRepository.getProfile();
      if (profileResult.isSuccess) {
        // Update current user from repository
        _currentUser.value = _authRepository.currentUser;
      }
    } catch (e) {
      print('❌ Refresh user data error: $e');
    }
  }

  /// Load profile data for editing
  void loadProfileData() {
    final user = currentUser;
    if (user != null) {
      final nameParts = user.name.split(' ');
      if (nameParts.length >= 2) {
        firstNameController.text = nameParts.first;
        lastNameController.text = nameParts.sublist(1).join(' ');
      } else {
        firstNameController.text = user.name;
        lastNameController.text = '';
      }
    }
  }

  // ===================== NAVIGATION =====================

  void _navigateToHomePage() {
    switch (selectedRole) {
      case UserRoles.student:
        Get.offAllNamed('/student');
        break;
      case UserRoles.teacher:
        Get.offAllNamed('/teacher');
        break;
      case UserRoles.parent:
        Get.offAllNamed('/parent');
        break;
      default:
        Get.offAllNamed('/home');
    }
  }

  /// Navigate to specific pages
  void goToLogin() => Get.toNamed('/login');
  void goToProfile() => Get.toNamed('/profile');
  void goToChangePassword() => Get.toNamed('/change-password');

  // ===================== UTILITY METHODS =====================

  /// Format phone for display
  String formatPhoneForDisplay(String phone) {
    return _authRepository.formatPhoneForDisplay(phone);
  }

  /// Get password strength
  String getPasswordStrength(String password) {
    final validation = _authRepository.validatePassword(password);
    if (validation.isValid) return 'Kuchli';
    if (validation.hasMinLength) return 'O\'rtacha';
    return 'Zaif';
  }

  /// Get role display name
  String getRoleDisplayName(String role) {
    return UserRoles.getDisplayName(role);
  }

  // ===================== UI FEEDBACK =====================

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Muvaffaqiyat',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void _showInfoSnackbar(String message) {
    Get.snackbar(
      'Ma\'lumot',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  // ===================== HELPER METHODS FOR UI =====================

  /// Check if user can access admin features
  bool get canAccessAdminFeatures => isAdmin;

  /// Check if user can access teacher features
  bool get canAccessTeacherFeatures => isTeacher || isAdmin;

  /// Get appropriate home route for current user
  String get homeRoute {
    if (isStudent) return '/student';
    if (isTeacher) return '/teacher';
    if (isParent) return '/parent';
    if (isAdmin) return '/admin';
    return '/home';
  }

  /// Get user avatar text (first letters of name)
  String get userAvatarText {
    final user = currentUser;
    if (user == null) return 'U';

    final nameParts = user.name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
  }

  /// Get greeting message based on time
  String get greetingMessage {
    final hour = DateTime.now().hour;
    final name = currentUser?.name.split(' ').first ?? 'Foydalanuvchi';

    if (hour < 12) {
      return 'Xayrli tong, $name!';
    } else if (hour < 17) {
      return 'Xayrli kun, $name!';
    } else {
      return 'Xayrli kech, $name!';
    }
  }
}