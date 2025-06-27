import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_models.dart';
import '../models/notification_model.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Login user
  Future<ApiResult<LoginResponse>> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    final request = LoginRequest(
      phone: phone,
      password: password,
      role: role,
    );

    final result = await _apiService.post<LoginResponse>(
      AuthEndpoints.login,
      data: request.toJson(),
      fromJson: (data) => LoginResponse.fromJson(data),
    );

    if (result.isSuccess && result.data != null) {
      await _storeAuthData(result.data!);
    }

    return result;
  }

  // Store authentication data
  Future<void> _storeAuthData(LoginResponse loginResponse) async {
    await _storage.write(CacheKeys.userToken, loginResponse.accessToken);
    await _storage.write(CacheKeys.userRole, loginResponse.role);

    final userInfo = {
      'id': loginResponse.user.id,
      'name': loginResponse.user.name,
      'phone': loginResponse.user.phone,
    };
    await _storage.write(CacheKeys.userProfile, userInfo);

    _apiService.setAuthToken(loginResponse.accessToken);
  }

  // Logout user
  Future<void> logout() async {
    try {
      _apiService.clearAuthToken();

      await _storage.remove(CacheKeys.userToken);
      await _storage.remove(CacheKeys.userProfile);
      await _storage.remove(CacheKeys.userRole);
      await _storage.remove(CacheKeys.notifications);

      await _clearCache();

      print('🚪 User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // Clear cached data
  Future<void> _clearCache() async {
    final keysToRemove = [
      CacheKeys.studentHomework,
      CacheKeys.studentExams,
      CacheKeys.studentGrades,
    ];

    for (final key in keysToRemove) {
      await _storage.remove(key);
    }
  }

  // Check authentication status
  Future<bool> checkAuthenticationStatus() async {
    final token = _storage.read<String>(CacheKeys.userToken);
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final result = await getProfile();
      return result.isSuccess;
    } catch (e) {
      print('Auth check failed: $e');
      return false;
    }
  }

  // Get user profile
  Future<ApiResult<ProfileResponse>> getProfile() async {
    return await _apiService.get<ProfileResponse>(
      AuthEndpoints.profile,
      fromJson: (data) => ProfileResponse.fromJson(data),
    );
  }

  // Update user profile
  Future<ApiResult<ApiResponse>> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final request = UpdateProfileRequest(
      firstName: firstName,
      lastName: lastName,
    );

    final result = await _apiService.put<ApiResponse>(
      AuthEndpoints.profile,
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    if (result.isSuccess) {
      await refreshUserData();
    }

    return result;
  }

  // Change password
  Future<ApiResult<ApiResponse>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final request = ChangePasswordRequest(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    return await _apiService.put<ApiResponse>(
      AuthEndpoints.changePassword,
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  // Get notifications
  Future<ApiResult<List<NotificationModel>>> getNotifications({
    int skip = 0,
    int limit = 20,
  }) async {
    return await _apiService.get<List<NotificationModel>>(
      PublicEndpoints.notifications,
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => NotificationModel.fromJson(item)).toList();
        }
        return <NotificationModel>[];
      },
    );
  }

  // Mark notification as read
  Future<ApiResult<ApiResponse>> markNotificationRead(int notificationId) async {
    return await _apiService.put<ApiResponse>(
      '${PublicEndpoints.notifications}/$notificationId/read',
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  // Mark all notifications as read
  Future<ApiResult<ApiResponse>> markAllNotificationsRead() async {
    return await _apiService.put<ApiResponse>(
      '${PublicEndpoints.notifications}/read-all',
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  // Get unread notification count
  Future<ApiResult<UnreadCountModel>> getUnreadNotificationCount() async {
    return await _apiService.get<UnreadCountModel>(
      '${PublicEndpoints.notifications}/unread-count',
      fromJson: (data) => UnreadCountModel.fromJson(data),
    );
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    final result = await getProfile();
    if (result.isSuccess && result.data != null) {
      final profile = result.data!;
      final userInfo = {
        'id': profile.id,
        'name': profile.fullName,
        'phone': profile.phone,
      };
      await _storage.write(CacheKeys.userProfile, userInfo);
    }
  }

  // Getters for cached data
  bool get isAuthenticated {
    final token = _storage.read<String>(CacheKeys.userToken);
    return token != null && token.isNotEmpty;
  }

  String? get userRole => _storage.read<String>(CacheKeys.userRole);

  Map<String, dynamic>? get currentUser => _storage.read<Map<String, dynamic>>(CacheKeys.userProfile);

  String? get userName => currentUser?['name'] as String?;

  String? get userPhone => currentUser?['phone'] as String?;

  int? get userId => currentUser?['id'] as int?;
}