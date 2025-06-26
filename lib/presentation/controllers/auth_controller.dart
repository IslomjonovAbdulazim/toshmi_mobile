import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';
import '../../data/models/api_response_models.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _authRepository = Get.find<AuthRepository>();

  // ===================== REACTIVE STATE =====================

  // Authentication state
  final _isAuthenticated = false.obs;
  final _userRole = Rxn<String>();
  final _userName = Rxn<String>();
  final _userPhone = Rxn<String>();
  final _userId = Rxn<int>();

  // Loading states
  final _isLoginLoading = false.obs;
  final _isProfileLoading = false.obs;
  final _isPasswordChangeLoading = false.obs;
  final _isProfileUpdateLoading = false.obs;

  // Profile data
  final _profile = Rxn<ProfileResponse>();
  final _profileLastUpdated = Rxn<DateTime>();

  // Error states
  final _loginError = Rxn<String>();
  final _profileError = Rxn<String>();

  // Form validation
  final _isLoginFormValid = false.obs;
  final _isPasswordFormValid = false.obs;

  // ===================== GETTERS =====================

  // Authentication getters
  bool get isAuthenticated => _isAuthenticated.value;
  String? get userRole => _userRole.value;
  String? get userName => _userName.value;
  String? get userPhone => _userPhone.value;
  int? get userId => _userId.value;

  // Loading getters
  bool get isLoginLoading => _isLoginLoading.value;
  bool get isProfileLoading => _isProfileLoading.value;
  bool get isPasswordChangeLoading => _isPasswordChangeLoading.value;
  bool get isProfileUpdateLoading => _isProfileUpdateLoading.value;
  bool get isAnyLoading => isLoginLoading || isProfileLoading || isPasswordChangeLoading || isProfileUpdateLoading;

  // Profile getters
  ProfileResponse? get profile => _profile.value;
  DateTime? get profileLastUpdated => _profileLastUpdated.value;

  // Error getters
  String? get loginError => _loginError.value;
  String? get profileError => _profileError.value;

  // Form validation getters
  bool get isLoginFormValid => _isLoginFormValid.value;
  bool get isPasswordFormValid => _isPasswordFormValid.value;

  // Role checking getters
  bool get isAdmin => userRole == UserRoles.admin;
  bool get isTeacher => userRole == UserRoles.teacher;
  bool get isStudent => userRole == UserRoles.student;
  bool get isParent => userRole == UserRoles.parent;

  // User display info
  String get userDisplayName => userName ?? 'Foydalanuvchi';
  String get userDisplayRole {
    switch (userRole) {
      case UserRoles.admin:
        return 'Administrator';
      case UserRoles.teacher:
        return 'Ustoz';
      case UserRoles.student:
        return 'Talaba';
      case UserRoles.parent:
        return 'Ota-ona';
      default:
        return '';
    }
  }

  // Profile completeness
  bool get isProfileComplete => profile?.firstName.isNotEmpty == true && profile?.lastName.isNotEmpty == true;

  // ===================== LIFECYCLE =====================

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
  }

  @override
  void onReady() {
    super.onReady();
    _checkAuthenticationStatus();
  }

  // ===================== INITIALIZATION =====================

  /// Initialize authentication state from stored data
  void _initializeAuthState() {
    _updateAuthStateFromRepository();
    print('AuthController: Initialized with auth state: ${isAuthenticated}');
  }

  /// Update auth state from repository
  void _updateAuthStateFromRepository() {
    _isAuthenticated.value = _authRepository.isAuthenticated;
    _userRole.value = _authRepository.userRole;
    _userName.value = _authRepository.userName;
    _userPhone.value = _authRepository.userPhone;
    _userId.value = _authRepository.userId;
  }

  /// Check authentication status on app start
  Future<void> _checkAuthenticationStatus() async {
    if (!isAuthenticated) return;

    try {
      final isValid = await _authRepository.checkAuthenticationStatus();
      if (!isValid) {
        await logout();
        Get.offAllNamed('/login');
      } else {
        // Load profile if authenticated
        await loadProfile();
      }
    } catch (e) {
      print('AuthController: Error checking auth status - $e');
    }
  }

  // ===================== AUTHENTICATION =====================

  /// Login user
  Future<bool> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    _isLoginLoading.value = true;
    _loginError.value = null;

    try {
      // Validate inputs
      final validationError = _validateLoginInputs(phone, password, role);
      if (validationError != null) {
        _loginError.value = validationError;
        return false;
      }

      // Format phone number
      final formattedPhone = _formatPhoneNumber(phone);

      // Attempt login
      final result = await _authRepository.login(
        phone: formattedPhone,
        password: password,
        role: role,
      );

      if (result.isSuccess && result.data != null) {
        _updateAuthStateFromRepository();
        await loadProfile();

        _showSuccessMessage('Muvaffaqiyatli kirildi');
        print('AuthController: Login successful for role: $role');
        return true;
      } else {
        _loginError.value = result.error?.messageUz ?? 'Kirish jarayonida xatolik yuz berdi';
        _showErrorMessage(_loginError.value!);
        return false;
      }
    } catch (e) {
      _loginError.value = 'Kutilmagan xatolik yuz berdi';
      _showErrorMessage(_loginError.value!);
      print('AuthController: Login error - $e');
      return false;
    } finally {
      _isLoginLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _clearAuthState();
      _showSuccessMessage('Muvaffaqiyatli chiqildi');
      print('AuthController: Logout successful');
    } catch (e) {
      print('AuthController: Logout error - $e');
    }
  }

  /// Clear authentication state
  void _clearAuthState() {
    _isAuthenticated.value = false;
    _userRole.value = null;
    _userName.value = null;
    _userPhone.value = null;
    _userId.value = null;
    _profile.value = null;
    _profileLastUpdated.value = null;
    _loginError.value = null;
    _profileError.value = null;
  }

  // ===================== PROFILE MANAGEMENT =====================

  /// Load user profile
  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (!isAuthenticated) return;

    _isProfileLoading.value = true;
    _profileError.value = null;

    try {
      final result = await _authRepository.getProfile(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _profile.value = result.data;
        _profileLastUpdated.value = DateTime.now();
        _updateUserNameFromProfile(result.data!);
        print('AuthController: Profile loaded successfully');
      } else {
        _profileError.value = result.error?.messageUz ?? 'Profil ma\'lumotlarini yuklab bo\'lmadi';
        print('AuthController: Profile load failed - ${result.error?.detail}');
      }
    } catch (e) {
      _profileError.value = 'Profil yuklanishida xatolik';
      print('AuthController: Profile load error - $e');
    } finally {
      _isProfileLoading.value = false;
    }
  }

  /// Update profile information
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    if (!isAuthenticated) return false;

    _isProfileUpdateLoading.value = true;

    try {
      // Validate inputs
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        _showErrorMessage('Ism va familiyani to\'ldiring');
        return false;
      }

      final result = await _authRepository.updateProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );

      if (result.isSuccess) {
        // Reload profile to get updated data
        await loadProfile(forceRefresh: true);
        _showSuccessMessage('Profil muvaffaqiyatli yangilandi');
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Profilni yangilashda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('AuthController: Profile update error - $e');
      return false;
    } finally {
      _isProfileUpdateLoading.value = false;
    }
  }

  /// Change user password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!isAuthenticated) return false;

    _isPasswordChangeLoading.value = true;

    try {
      // Validate inputs
      final validationError = _validatePasswordInputs(oldPassword, newPassword, confirmPassword);
      if (validationError != null) {
        _showErrorMessage(validationError);
        return false;
      }

      final result = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        _showSuccessMessage('Parol muvaffaqiyatli o\'zgartirildi');
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Parol o\'zgartirishda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('AuthController: Password change error - $e');
      return false;
    } finally {
      _isPasswordChangeLoading.value = false;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;

    try {
      await _authRepository.refreshUserData();
      await loadProfile(forceRefresh: true);
      _updateAuthStateFromRepository();
      print('AuthController: User data refreshed');
    } catch (e) {
      print('AuthController: Refresh user data error - $e');
    }
  }

  // ===================== FORM VALIDATION =====================

  /// Validate login form
  void validateLoginForm({
    required String phone,
    required String password,
    required String role,
  }) {
    final isValid = phone.isNotEmpty &&
        password.isNotEmpty &&
        role.isNotEmpty &&
        _isValidPhoneFormat(phone);

    _isLoginFormValid.value = isValid;
  }

  /// Validate password change form
  void validatePasswordForm({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final isValid = oldPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword &&
        newPassword.length >= 6;

    _isPasswordFormValid.value = isValid;
  }

  // ===================== VALIDATION HELPERS =====================

  /// Validate login inputs
  String? _validateLoginInputs(String phone, String password, String role) {
    if (phone.trim().isEmpty) return 'Telefon raqamini kiriting';
    if (password.trim().isEmpty) return 'Parolni kiriting';
    if (role.trim().isEmpty) return 'Rolni tanlang';

    if (!_isValidPhoneFormat(phone)) {
      return 'Telefon raqam formati: +998XXXXXXXXX';
    }

    return null;
  }

  /// Validate password inputs
  String? _validatePasswordInputs(String oldPassword, String newPassword, String confirmPassword) {
    if (oldPassword.trim().isEmpty) return 'Joriy parolni kiriting';
    if (newPassword.trim().isEmpty) return 'Yangi parolni kiriting';
    if (confirmPassword.trim().isEmpty) return 'Parolni tasdiqlang';

    if (newPassword.length < 6) return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
    if (newPassword != confirmPassword) return 'Parollar mos kelmadi';
    if (oldPassword == newPassword) return 'Yangi parol joriy paroldan farqli bo\'lishi kerak';

    return null;
  }

  /// Check if phone format is valid
  bool _isValidPhoneFormat(String phone) {
    final phoneRegex = RegExp(r'^\+998\d{9}$');
    return phoneRegex.hasMatch(phone.replaceAll(' ', ''));
  }

  /// Format phone number
  String _formatPhoneNumber(String phone) {
    return phone.replaceAll(' ', '');
  }

  /// Update user name from profile
  void _updateUserNameFromProfile(ProfileResponse profile) {
    _userName.value = profile.fullName;
  }

  // ===================== UTILITY METHODS =====================

  /// Clear form errors
  void clearErrors() {
    _loginError.value = null;
    _profileError.value = null;
  }

  /// Get password strength
  String getPasswordStrength(String password) {
    if (password.length < 6) return 'Zaif';
    if (password.length < 8) return 'O\'rta';

    bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasLetters && hasNumbers && hasSpecial) return 'Kuchli';
    if (hasLetters && hasNumbers) return 'Yaxshi';

    return 'O\'rta';
  }

  /// Format phone for display
  String formatPhoneForDisplay(String phone) {
    if (phone.startsWith('+998')) {
      final digits = phone.substring(4);
      if (digits.length == 9) {
        return '+998 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7)}';
      }
    }
    return phone;
  }

  /// Get greeting message based on time
  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Xayrli tong';
    if (hour < 17) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  /// Get full greeting with name
  String getFullGreeting() {
    return '${getGreetingMessage()}, $userDisplayName!';
  }

  /// Navigate to appropriate dashboard based on role
  void navigateToDashboard() {
    switch (userRole) {
      case UserRoles.admin:
        Get.offAllNamed('/admin/dashboard');
        break;
      case UserRoles.teacher:
        Get.offAllNamed('/teacher/dashboard');
        break;
      case UserRoles.student:
        Get.offAllNamed('/student/dashboard');
        break;
      case UserRoles.parent:
        Get.offAllNamed('/parent/dashboard');
        break;
      default:
        Get.offAllNamed('/login');
    }
  }

  /// Check if password meets requirements
  Map<String, bool> checkPasswordRequirements(String password) {
    return {
      'minLength': password.length >= 6,
      'hasLetters': password.contains(RegExp(r'[a-zA-Z]')),
      'hasNumbers': password.contains(RegExp(r'[0-9]')),
      'isStrong': password.length >= 8 &&
          password.contains(RegExp(r'[a-zA-Z]')) &&
          password.contains(RegExp(r'[0-9]')),
    };
  }

  // ===================== MESSAGING =====================

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Muvaffaqiyat',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showInfoMessage(String message) {
    Get.snackbar(
      'Ma\'lumot',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ===================== DEBUG =====================

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'isAuthenticated': isAuthenticated,
      'userRole': userRole,
      'userName': userName,
      'userId': userId,
      'profileLoaded': profile != null,
      'profileLastUpdated': profileLastUpdated?.toIso8601String(),
      'isLoading': isAnyLoading,
      'repository_cache_info': _authRepository.getCacheInfo(),
    };
  }
}