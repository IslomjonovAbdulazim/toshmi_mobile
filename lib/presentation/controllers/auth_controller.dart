import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _authRepository = Get.find<IAuthRepository>();

  // Form controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable state
  final _isLoginLoading = false.obs;
  final _isProfileLoading = false.obs;
  final _isPasswordLoading = false.obs;
  final _selectedRole = 'student'.obs;
  final _isPasswordVisible = false.obs;
  final _currentUser = Rxn<User>();
  final _profile = Rxn<ProfileResponse>();

  // Getters
  bool get isLoginLoading => _isLoginLoading.value;
  bool get isProfileLoading => _isProfileLoading.value;
  bool get isPasswordLoading => _isPasswordLoading.value;
  String get selectedRole => _selectedRole.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  User? get currentUser => _currentUser.value;
  ProfileResponse? get profile => _profile.value;

  bool get isAuthenticated => _authRepository.isAuthenticated;
  bool get formValid => phoneController.text.isNotEmpty && passwordController.text.isNotEmpty;

  // Role getters
  bool get isAdmin => _authRepository.isAdmin;
  bool get isTeacher => _authRepository.isTeacher;
  bool get isStudent => _authRepository.isStudent;
  bool get isParent => _authRepository.isParent;

  @override
  void onInit() {
    super.onInit();
    _initializePhoneField();
    _loadUserData();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Initialize phone field with +998 prefix
  void _initializePhoneField() {
    if (phoneController.text.isEmpty) {
      phoneController.text = '+998 ';
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: phoneController.text.length),
      );
    }
  }

  // Load user data if authenticated
  void _loadUserData() {
    if (isAuthenticated) {
      _currentUser.value = _authRepository.currentUser;
      loadProfile();
    }
  }

  // Authentication methods
  Future<void> login() async {
    if (!formValid) return;

    _isLoginLoading.value = true;

    try {
      final result = await _authRepository.login(
        phone: phoneController.text.trim(),
        password: passwordController.text,
        role: selectedRole,
      );

      if (result.isSuccess && result.data != null) {
        _currentUser.value = result.data;
        _showSuccessSnackbar('Muvaffaqiyatli kirildi');
        _navigateToHomePage();
      } else {
        _showErrorSnackbar(result.failure?.message ?? 'Kirish jarayonida xatolik yuz berdi');
      }
    } catch (e) {
      _showErrorSnackbar('Kutilmagan xatolik yuz berdi');
    } finally {
      _isLoginLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _currentUser.value = null;
      _profile.value = null;
      _clearForm();
      Get.offAllNamed('/login');
      _showSuccessSnackbar('Muvaffaqiyatli chiqildi');
    } catch (e) {
      _showErrorSnackbar('Chiqish jarayonida xatolik yuz berdi');
    }
  }

  // Profile management
  Future<void> loadProfile() async {
    _isProfileLoading.value = true;

    try {
      final result = await _authRepository.getProfile();

      if (result.isSuccess && result.data != null) {
        _profile.value = result.data;
        _loadProfileToForm();
      } else {
        _showErrorSnackbar('Profil ma\'lumotlarini olishda xatolik');
      }
    } catch (e) {
      _showErrorSnackbar('Kutilmagan xatolik yuz berdi');
    } finally {
      _isProfileLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      _showErrorSnackbar('Ism va familiyani to\'ldiring');
      return;
    }

    _isProfileLoading.value = true;

    try {
      final result = await _authRepository.updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );

      if (result.isSuccess) {
        await loadProfile(); // Refresh profile data
        _showSuccessSnackbar('Profil muvaffaqiyatli yangilandi');
        Get.back(); // Return to profile page
      } else {
        _showErrorSnackbar(result.failure?.message ?? 'Profil yangilashda xatolik');
      }
    } catch (e) {
      _showErrorSnackbar('Kutilmagan xatolik yuz berdi');
    } finally {
      _isProfileLoading.value = false;
    }
  }

  // Password management
  Future<void> changePassword() async {
    if (!_validatePasswordForm()) return;

    _isPasswordLoading.value = true;

    try {
      final result = await _authRepository.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (result.isSuccess) {
        _clearPasswordForm();
        _showSuccessSnackbar('Parol muvaffaqiyatli o\'zgartirildi');
        Get.back();
      } else {
        _showErrorSnackbar(result.failure?.message ?? 'Parol o\'zgartirishda xatolik');
      }
    } catch (e) {
      _showErrorSnackbar('Kutilmagan xatolik yuz berdi');
    } finally {
      _isPasswordLoading.value = false;
    }
  }

  // UI state methods
  void setSelectedRole(String role) {
    _selectedRole.value = role;
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  // Form validation
  bool _validatePasswordForm() {
    if (oldPasswordController.text.isEmpty) {
      _showErrorSnackbar('Eski parolni kiriting');
      return false;
    }

    if (newPasswordController.text.isEmpty) {
      _showErrorSnackbar('Yangi parolni kiriting');
      return false;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('Parollar mos kelmaydi');
      return false;
    }

    final validation = _authRepository.validatePassword(newPasswordController.text);
    if (!validation.isValid) {
      _showErrorSnackbar(validation.errorMessage);
      return false;
    }

    return true;
  }

  // Helper methods
  void _loadProfileToForm() {
    final profile = _profile.value;
    if (profile != null) {
      firstNameController.text = profile.firstName;
      lastNameController.text = profile.lastName;
    }
  }

  void _clearForm() {
    phoneController.text = '+998 ';
    passwordController.clear();
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length),
    );
  }

  void _clearPasswordForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

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
        Get.offAllNamed('/profile');
    }
  }

  // Navigation methods
  void goToLogin() => Get.toNamed('/login');
  void goToProfile() => Get.toNamed('/profile');
  void goToEditProfile() => Get.toNamed('/edit-profile');
  void goToChangePassword() => Get.toNamed('/change-password');

  // Utility methods
  String formatPhoneForDisplay(String phone) {
    return _authRepository.formatPhoneForDisplay(phone);
  }

  String getPasswordStrength(String password) {
    final validation = _authRepository.validatePassword(password);
    if (validation.isValid) return 'Kuchli';
    if (validation.hasMinLength) return 'O\'rtacha';
    return 'Zaif';
  }

  String getRoleDisplayName(String role) {
    return UserRoles.getDisplayName(role);
  }

  // Snackbar helpers
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

  // Public methods for UI feedback
  void showSuccess(String message) => _showSuccessSnackbar(message);
  void showError(String message) => _showErrorSnackbar(message);
  void showInfo(String message) => _showInfoSnackbar(message);
}