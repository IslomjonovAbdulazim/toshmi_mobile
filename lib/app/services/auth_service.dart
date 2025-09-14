// lib/app/services/auth_service.dart
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AuthService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxString _token = ''.obs;
  final RxBool _isLoggedIn = false.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  String? get token => _token.value.isEmpty ? null : _token.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String? get userRole => _currentUser.value?.role;
  int? get userId => _currentUser.value?.id;
  String? get userFullName => _currentUser.value?.fullName;
  String? get userPhone => _currentUser.value?.phone;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    try {
      print('🔄 Loading auth data from storage...');

      final token = _storage.getToken();
      final userData = _storage.getUserData();

      if (token != null && userData != null) {
        print('📱 Found stored auth data');
        _token.value = token;
        _currentUser.value = User.fromJson(userData);
        _isLoggedIn.value = true;

        print('✅ Auth data loaded - User: ${_currentUser.value?.fullName}, Role: ${_currentUser.value?.role}');

        // DON'T auto-navigate here - let splash controller handle it
        print('📦 Auth state ready for splash controller');
      } else {
        print('❌ No stored auth data found');
      }
    } catch (e) {
      print('⚠️ Error loading auth data: $e');
      await _clearAuthData();
    }
  }

  // FIXED: Login with better error handling and logging
  Future<void> login({
    required String token,
    required User user,
  }) async {
    try {
      print('🔐 AuthService.login called');
      print('👤 User: ${user.fullName}, Role: ${user.role}, ID: ${user.id}');

      // Validate required data
      if (user.role.isEmpty) {
        throw Exception('User role is empty');
      }

      if (user.id <= 0) {
        throw Exception('Invalid user ID');
      }

      // Update reactive variables
      _token.value = token;
      _currentUser.value = user;
      _isLoggedIn.value = true;

      // Save to storage
      await _storage.saveToken(token);
      await _storage.saveUserData(user.toJson());

      print('💾 Auth data saved to storage');
      print('🎯 Current auth state - isLoggedIn: ${_isLoggedIn.value}, role: ${userRole}');

      // Navigate to role-based home
      _navigateToRoleBasedHome();
    } catch (e) {
      print('❌ AuthService.login error: $e');
      await _clearAuthData();
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      print('🚪 Logging out user');
      await _clearAuthData();
      Get.offAllNamed('/login');
      print('✅ Logout completed');
    } catch (e) {
      print('❌ Logout error: $e');
      // Force clear even if there's an error
      _token.value = '';
      _currentUser.value = null;
      _isLoggedIn.value = false;
      Get.offAllNamed('/login');
    }
  }

  Future<void> _clearAuthData() async {
    _token.value = '';
    _currentUser.value = null;
    _isLoggedIn.value = false;
    await _storage.clearAuthData();
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      _currentUser.value = updatedUser;
      await _storage.saveUserData(updatedUser.toJson());
      print('✅ User data updated');
    } catch (e) {
      print('❌ Failed to update user: $e');
    }
  }

  Future<void> updateToken(String newToken) async {
    try {
      _token.value = newToken;
      await _storage.saveToken(newToken);
      print('✅ Token updated');
    } catch (e) {
      print('❌ Failed to update token: $e');
    }
  }

  // FIXED: Better navigation with validation
  void _navigateToRoleBasedHome() {
    final role = userRole?.toLowerCase().trim();
    print('🧭 Navigating to role-based home. Role: "$role"');

    if (role == null || role.isEmpty) {
      print('❌ Invalid role for navigation, redirecting to login');
      Get.offAllNamed('/login');
      return;
    }

    switch (role) {
      case 'teacher':
        print('🧭 Navigation: /teacher');
        Get.offAllNamed('/teacher');
        break;
      case 'student':
        print('🧭 Navigation: /student');
        Get.offAllNamed('/student');
        break;
      case 'parent':
        print('🧭 Navigation: /parent');
        Get.offAllNamed('/parent');
        break;
      case 'admin':
        print('🧭 Navigation: /admin');
        Get.offAllNamed('/admin');
        break;
      default:
        print('❌ Unknown role: "$role", redirecting to login');
        Get.offAllNamed('/login');
    }
  }

  // Utility methods
  bool hasRole(String role) {
    return userRole?.toLowerCase() == role.toLowerCase();
  }

  bool hasAnyRole(List<String> roles) {
    return roles.any((role) => hasRole(role));
  }

  bool get isTeacher => hasRole('teacher');
  bool get isStudent => hasRole('student');
  bool get isParent => hasRole('parent');
  bool get isAdmin => hasRole('admin');

  int? get profileImageId => _currentUser.value?.profileImageId;

  bool get isTokenExpired => false; // Implement token expiry check if needed

  Future<bool> refreshToken() async {
    // Implement token refresh logic if your API supports it
    return true;
  }

  // Method for splash controller to check auth and navigate
  void navigateBasedOnAuthState() {
    print('🔍 Checking auth state for navigation');
    print('📊 isLoggedIn: ${_isLoggedIn.value}, user: ${_currentUser.value?.fullName}, role: ${userRole}');

    if (_isLoggedIn.value && _currentUser.value != null && userRole?.isNotEmpty == true) {
      print('✅ Valid auth state, navigating to role-based home');
      _navigateToRoleBasedHome();
    } else {
      print('❌ Invalid auth state, redirecting to login');
      Get.offAllNamed('/login');
    }
  }

  // Refresh user profile from backend
  Future<void> refreshUserProfile() async {
    try {
      print('🔄 Refreshing user profile from backend...');
      
      // Make API call to get updated profile
      final response = await Get.find<ApiService>().get('/auth/profile');
      
      if (response.data != null) {
        print('📥 Profile refresh response: ${response.data}');
        
        // Parse updated user data
        final updatedUser = User.fromJson(response.data);
        
        // Update reactive variable
        _currentUser.value = updatedUser;
        
        // Save to storage
        await _storage.saveUserData(updatedUser.toJson());
        
        print('✅ User profile refreshed and updated');
      }
    } catch (e) {
      print('❌ Error refreshing user profile: $e');
    }
  }

  // Update user's avatar URL after avatar upload
  Future<void> updateAvatarUrl(String storageUrl) async {
    try {
      if (_currentUser.value == null) {
        print('❌ Cannot update avatar - no current user');
        return;
      }

      print('📸 Updating user avatar URL to: $storageUrl');
      
      // First refresh profile from backend to get the actual updated data
      await refreshUserProfile();
      
      print('✅ Avatar URL updated via profile refresh');
    } catch (e) {
      print('❌ Error updating avatar URL: $e');
      
      // Fallback: update locally if API call fails
      final updatedUser = _currentUser.value!.copyWith(avatarUrl: storageUrl);
      _currentUser.value = updatedUser;
      await _storage.saveUserData(updatedUser.toJson());
    }
  }
}