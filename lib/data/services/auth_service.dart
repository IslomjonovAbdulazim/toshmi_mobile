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

  // ===================== AUTHENTICATION =====================

  /// Login user with phone, password and role
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

    // Store auth data if login successful
    if (result.isSuccess && result.data != null) {
      await _storeAuthData(result.data!);
    }

    return result;
  }

  /// Store authentication data locally
  Future<void> _storeAuthData(LoginResponse loginResponse) async {
    await _storage.write(CacheKeys.userToken, loginResponse.accessToken);
    await _storage.write(CacheKeys.userRole, loginResponse.role);

    // Store user info
    final userInfo = {
      'id': loginResponse.user.id,
      'name': loginResponse.user.name,
      'phone': loginResponse.user.phone,
    };
    await _storage.write(CacheKeys.userProfile, userInfo);

    // Set token in API service
    _apiService.setAuthToken(loginResponse.accessToken);
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    try {
      // Clear API service token
      _apiService.clearAuthToken();

      // Clear all stored data
      await _storage.remove(CacheKeys.userToken);
      await _storage.remove(CacheKeys.userProfile);
      await _storage.remove(CacheKeys.userRole);
      await _storage.remove(CacheKeys.notifications);

      // Clear any cached data
      await _clearCache();

      print('🚪 User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  /// Clear cached data
  Future<void> _clearCache() async {
    final keysToRemove = [
      CacheKeys.studentHomework,
      CacheKeys.studentExams,
      CacheKeys.studentGrades,
      CacheKeys.teacherHomework,
      CacheKeys.teacherExams,
      CacheKeys.parentChildren,
    ];

    for (final key in keysToRemove) {
      await _storage.remove(key);
    }
  }

  // ===================== PROFILE MANAGEMENT =====================

  /// Get user profile
  Future<ApiResult<ProfileResponse>> getProfile() async {
    return await _apiService.get<ProfileResponse>(
      AuthEndpoints.profile,
      fromJson: (data) => ProfileResponse.fromJson(data),
    );
  }

  /// Update user profile
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

    // Update stored profile if successful
    if (result.isSuccess) {
      await _updateStoredProfile(firstName, lastName);
    }

    return result;
  }

  /// Update stored profile data
  Future<void> _updateStoredProfile(String firstName, String lastName) async {
    final currentProfile = _storage.read<Map<String, dynamic>>(CacheKeys.userProfile);
    if (currentProfile != null) {
      currentProfile['name'] = '$firstName $lastName';
      await _storage.write(CacheKeys.userProfile, currentProfile);
    }
  }

  /// Change user password
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

  // ===================== NOTIFICATIONS =====================

  /// Get user notifications with pagination
  Future<ApiResult<List<NotificationModel>>> getNotifications({
    int skip = 0,
    int limit = 20,
  }) async {
    final queryParams = ApiConstants.buildPaginationParams(
      skip: skip,
      limit: limit,
    );

    final result = await _apiService.get<List<NotificationModel>>(
      AuthEndpoints.notifications,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => NotificationModel.fromJson(item)).toList();
        }
        return <NotificationModel>[];
      },
    );

    // Cache notifications if successful
    if (result.isSuccess && result.data != null && skip == 0) {
      await _cacheNotifications(result.data!);
    }

    return result;
  }

  /// Cache notifications locally
  Future<void> _cacheNotifications(List<NotificationModel> notifications) async {
    final notificationsJson = notifications.map((n) => n.toJson()).toList();
    await _storage.write(CacheKeys.notifications, notificationsJson);
  }

  /// Get cached notifications
  List<NotificationModel> getCachedNotifications() {
    final cachedData = _storage.read<List>(CacheKeys.notifications);
    if (cachedData != null) {
      return cachedData
          .map((item) => NotificationModel.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Mark notification as read
  Future<ApiResult<ApiResponse>> markNotificationRead(int notificationId) async {
    final result = await _apiService.put<ApiResponse>(
      AuthEndpoints.notificationRead(notificationId),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Update cached notifications if successful
    if (result.isSuccess) {
      await _updateCachedNotificationStatus(notificationId, true);
    }

    return result;
  }

  /// Mark all notifications as read
  Future<ApiResult<ApiResponse>> markAllNotificationsRead() async {
    final result = await _apiService.put<ApiResponse>(
      AuthEndpoints.markAllNotificationsRead,
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Update all cached notifications if successful
    if (result.isSuccess) {
      await _markAllCachedNotificationsAsRead();
    }

    return result;
  }

  /// Update cached notification read status
  Future<void> _updateCachedNotificationStatus(int notificationId, bool isRead) async {
    final cachedNotifications = getCachedNotifications();
    final updatedNotifications = cachedNotifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: isRead);
      }
      return notification;
    }).toList();

    await _cacheNotifications(updatedNotifications);
  }

  /// Mark all cached notifications as read
  Future<void> _markAllCachedNotificationsAsRead() async {
    final cachedNotifications = getCachedNotifications();
    final updatedNotifications = cachedNotifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();

    await _cacheNotifications(updatedNotifications);
  }

  /// Get unread notifications count
  Future<ApiResult<UnreadCountModel>> getUnreadNotificationCount() async {
    return await _apiService.get<UnreadCountModel>(
      AuthEndpoints.unreadNotificationCount,
      fromJson: (data) => UnreadCountModel.fromJson(data),
    );
  }

  /// Get cached unread count
  int getCachedUnreadCount() {
    final cachedNotifications = getCachedNotifications();
    return cachedNotifications.where((n) => !n.isRead).length;
  }

  // ===================== AUTH STATE MANAGEMENT =====================

  /// Check if user is authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;

  /// Get current auth token
  String? get authToken => _apiService.authToken;

  /// Get stored user role
  String? get userRole => _storage.read<String>(CacheKeys.userRole);

  /// Get stored user profile
  Map<String, dynamic>? get userProfile =>
      _storage.read<Map<String, dynamic>>(CacheKeys.userProfile);

  /// Get user ID from stored profile
  int? get userId {
    final profile = userProfile;
    return profile?['id'] as int?;
  }

  /// Get user name from stored profile
  String? get userName {
    final profile = userProfile;
    return profile?['name'] as String?;
  }

  /// Get user phone from stored profile
  String? get userPhone {
    final profile = userProfile;
    return profile?['phone'] as String?;
  }

  /// Check if user has specific role
  bool hasRole(String role) => userRole == role;

  /// Check if user is admin
  bool get isAdmin => hasRole(UserRoles.admin);

  /// Check if user is teacher
  bool get isTeacher => hasRole(UserRoles.teacher);

  /// Check if user is student
  bool get isStudent => hasRole(UserRoles.student);

  /// Check if user is parent
  bool get isParent => hasRole(UserRoles.parent);

  // ===================== VALIDATION HELPERS =====================

  /// Validate phone number format
  bool isValidPhone(String phone) {
    // Uzbekistan phone number format: +998XXXXXXXXX
    final phoneRegex = RegExp(r'^\+998\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Validate password strength
  Map<String, bool> validatePassword(String password) {
    return {
      'minLength': password.length >= 6,
      'hasLetters': password.contains(RegExp(r'[a-zA-Z]')),
      'hasNumbers': password.contains(RegExp(r'[0-9]')),
      'isStrong': password.length >= 8 &&
          password.contains(RegExp(r'[a-zA-Z]')) &&
          password.contains(RegExp(r'[0-9]')),
    };
  }

  /// Get password strength text
  String getPasswordStrengthText(String password) {
    final validation = validatePassword(password);

    if (validation['isStrong'] == true) {
      return 'Kuchli parol';
    } else if (validation['minLength'] == true) {
      return 'O\'rta parol';
    } else {
      return 'Zaif parol';
    }
  }

  /// Format phone number for display
  String formatPhoneForDisplay(String phone) {
    if (phone.startsWith('+998')) {
      // +998 XX XXX XX XX format
      final digits = phone.substring(4);
      if (digits.length == 9) {
        return '+998 ${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 7)} ${digits.substring(7)}';
      }
    }
    return phone;
  }

  /// Auto-check authentication on app start
  Future<bool> checkAuthenticationStatus() async {
    if (!isAuthenticated) return false;

    try {
      // Verify token is still valid by making a profile request
      final result = await getProfile();
      return result.isSuccess;
    } catch (e) {
      // Token is invalid, clear auth data
      await logout();
      return false;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;

    try {
      // Refresh profile
      final profileResult = await getProfile();
      if (profileResult.isSuccess && profileResult.data != null) {
        final profile = profileResult.data!;
        await _storage.write(CacheKeys.userProfile, {
          'id': profile.id,
          'name': profile.fullName,
          'phone': profile.phone,
        });
      }

      // Refresh notifications
      await getNotifications();
    } catch (e) {
      print('❌ Error refreshing user data: $e');
    }
  }
}