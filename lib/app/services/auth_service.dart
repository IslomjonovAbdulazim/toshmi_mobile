import 'package:get/get.dart';
import '../data/models/user_model.dart';
import 'storage_service.dart';

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

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final token = await _storage.getToken();
    final userData = await _storage.getUserData();

    if (token != null && userData != null) {
      _token.value = token;
      _currentUser.value = User.fromJson(userData);
      _isLoggedIn.value = true;
    }
  }

  Future<void> login({
    required String token,
    required User user,
  }) async {
    _token.value = token;
    _currentUser.value = user;
    _isLoggedIn.value = true;

    await _storage.saveToken(token);
    await _storage.saveUserData(user.toJson());

    _navigateToRoleBasedHome();
  }

  Future<void> logout() async {
    _token.value = '';
    _currentUser.value = null;
    _isLoggedIn.value = false;

    await _storage.clearAuthData();

    Get.offAllNamed('/login');
  }

  Future<void> updateUser(User updatedUser) async {
    _currentUser.value = updatedUser;
    await _storage.saveUserData(updatedUser.toJson());
  }

  Future<void> updateToken(String newToken) async {
    _token.value = newToken;
    await _storage.saveToken(newToken);
  }

  void _navigateToRoleBasedHome() {
    switch (userRole?.toLowerCase()) {
      case 'teacher':
        Get.offAllNamed('/teacher');
        break;
      case 'student':
        Get.offAllNamed('/student');
        break;
      case 'parent':
        Get.offAllNamed('/parent');
        break;
      case 'admin':
        Get.offAllNamed('/admin');
        break;
      default:
        Get.offAllNamed('/login');
    }
  }

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

  String? get userFullName => _currentUser.value?.fullName;
  String? get userPhone => _currentUser.value?.phone;
  int? get profileImageId => _currentUser.value?.profileImageId;

  // Check if token is expired (implement based on your token structure)
  bool get isTokenExpired {
    // Add token expiration logic here if needed
    return false;
  }

  Future<bool> refreshToken() async {
    // Implement token refresh logic if your API supports it
    return true;
  }
}