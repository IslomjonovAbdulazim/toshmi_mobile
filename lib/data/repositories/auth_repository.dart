import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_models.dart';
import '../models/notification_model.dart';
import '../models/api_response_models.dart';
import '../services/api_service.dart';

class AuthRepository extends GetxService {
  static AuthRepository get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Cache duration constants
  static const Duration _profileCacheDuration = Duration(hours: 24);
  static const Duration _notificationsCacheDuration = Duration(minutes: 30);

  // ===================== AUTHENTICATION =====================

  /// Login user and store authentication data
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

    // Store user info with timestamp
    final userInfo = {
      'id': loginResponse.user.id,
      'name': loginResponse.user.name,
      'phone': loginResponse.user.phone,
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(CacheKeys.userProfile, userInfo);

    // Set token in API service
    _apiService.setAuthToken(loginResponse.accessToken);
  }

  /// Logout and clear all data
  Future<void> logout() async {
    try {
      // Clear API service token
      _apiService.clearAuthToken();

      // Clear authentication data
      await Future.wait([
        _storage.remove(CacheKeys.userToken),
        _storage.remove(CacheKeys.userProfile),
        _storage.remove(CacheKeys.userRole),
        _storage.remove(CacheKeys.notifications),
        _clearAllCache(),
      ]);

      print('🚪 AuthRepository: User logged out successfully');
    } catch (e) {
      print('❌ AuthRepository: Error during logout - $e');
    }
  }

  /// Clear all cached data
  Future<void> _clearAllCache() async {
    final keysToRemove = [
      CacheKeys.studentHomework,
      CacheKeys.studentExams,
      CacheKeys.studentGrades,
      CacheKeys.teacherHomework,
      CacheKeys.teacherExams,
      CacheKeys.parentChildren,
      '${CacheKeys.notifications}_last_fetch',
      '${CacheKeys.userProfile}_last_fetch',
    ];

    await Future.wait(keysToRemove.map((key) => _storage.remove(key)));
  }

  // ===================== PROFILE MANAGEMENT =====================

  /// Get user profile with caching
  Future<ApiResult<ProfileResponse>> getProfile({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedProfile = _getCachedProfile();
      if (cachedProfile != null && _isProfileCacheValid()) {
        print('AuthRepository: Using cached profile');
        return ApiResult.success(cachedProfile);
      }
    }

    // Fetch from API
    final result = await _apiService.get<ProfileResponse>(
      AuthEndpoints.profile,
      fromJson: (data) => ProfileResponse.fromJson(data),
    );

    // Cache successful result
    if (result.isSuccess && result.data != null) {
      await _cacheProfile(result.data!);
    }

    return result;
  }

  /// Cache profile data
  Future<void> _cacheProfile(ProfileResponse profile) async {
    final profileData = profile.toJson();
    profileData['cached_at'] = DateTime.now().toIso8601String();
    await _storage.write(CacheKeys.userProfile, profileData);
    print('AuthRepository: Profile cached');
  }

  /// Get cached profile
  ProfileResponse? _getCachedProfile() {
    final cachedData = _storage.read<Map<String, dynamic>>(CacheKeys.userProfile);
    if (cachedData != null) {
      try {
        // Remove cached_at before deserializing
        final profileData = Map<String, dynamic>.from(cachedData);
        profileData.remove('cached_at');
        return ProfileResponse.fromJson(profileData);
      } catch (e) {
        print('AuthRepository: Error reading cached profile - $e');
        _storage.remove(CacheKeys.userProfile);
      }
    }
    return null;
  }

  /// Check if profile cache is valid
  bool _isProfileCacheValid() {
    final cachedData = _storage.read<Map<String, dynamic>>(CacheKeys.userProfile);
    if (cachedData?['cached_at'] != null) {
      try {
        final cachedAt = DateTime.parse(cachedData!['cached_at']);
        final now = DateTime.now();
        return now.difference(cachedAt) < _profileCacheDuration;
      } catch (e) {
        print('AuthRepository: Error checking profile cache validity - $e');
      }
    }
    return false;
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

    // Invalidate profile cache if successful
    if (result.isSuccess) {
      await _invalidateProfileCache();
    }

    return result;
  }

  /// Invalidate profile cache
  Future<void> _invalidateProfileCache() async {
    await _storage.remove(CacheKeys.userProfile);
    print('AuthRepository: Profile cache invalidated');
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

  /// Get notifications with caching and pagination
  Future<ApiResult<List<NotificationModel>>> getNotifications({
    int skip = 0,
    int limit = 20,
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache for first page only
    if (skip == 0 && useCache && !forceRefresh) {
      final cachedNotifications = _getCachedNotifications();
      if (cachedNotifications.isNotEmpty && _isNotificationsCacheValid()) {
        print('AuthRepository: Using cached notifications (${cachedNotifications.length})');
        return ApiResult.success(cachedNotifications);
      }
    }

    // Fetch from API
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

    // Cache first page results
    if (result.isSuccess && result.data != null && skip == 0) {
      await _cacheNotifications(result.data!);
    }

    return result;
  }

  /// Cache notifications
  Future<void> _cacheNotifications(List<NotificationModel> notifications) async {
    final notificationsData = {
      'data': notifications.map((n) => n.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(CacheKeys.notifications, notificationsData);
    print('AuthRepository: Cached ${notifications.length} notifications');
  }

  /// Get cached notifications
  List<NotificationModel> _getCachedNotifications() {
    final cachedData = _storage.read<Map<String, dynamic>>(CacheKeys.notifications);
    if (cachedData?['data'] != null) {
      try {
        final notificationsJson = cachedData!['data'] as List;
        return notificationsJson
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      } catch (e) {
        print('AuthRepository: Error reading cached notifications - $e');
        _storage.remove(CacheKeys.notifications);
      }
    }
    return [];
  }

  /// Check if notifications cache is valid
  bool _isNotificationsCacheValid() {
    final cachedData = _storage.read<Map<String, dynamic>>(CacheKeys.notifications);
    if (cachedData?['cached_at'] != null) {
      try {
        final cachedAt = DateTime.parse(cachedData!['cached_at']);
        final now = DateTime.now();
        return now.difference(cachedAt) < _notificationsCacheDuration;
      } catch (e) {
        print('AuthRepository: Error checking notifications cache validity - $e');
      }
    }
    return false;
  }

  /// Mark notification as read
  Future<ApiResult<ApiResponse>> markNotificationRead(int notificationId) async {
    final result = await _apiService.put<ApiResponse>(
      AuthEndpoints.notificationRead(notificationId),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Update cached notification if successful
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
    final cachedNotifications = _getCachedNotifications();
    if (cachedNotifications.isNotEmpty) {
      final updatedNotifications = cachedNotifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: isRead);
        }
        return notification;
      }).toList();

      await _cacheNotifications(updatedNotifications);
      print('AuthRepository: Updated notification $notificationId read status to $isRead');
    }
  }

  /// Mark all cached notifications as read
  Future<void> _markAllCachedNotificationsAsRead() async {
    final cachedNotifications = _getCachedNotifications();
    if (cachedNotifications.isNotEmpty) {
      final updatedNotifications = cachedNotifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();

      await _cacheNotifications(updatedNotifications);
      print('AuthRepository: Marked all cached notifications as read');
    }
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
    final cachedNotifications = _getCachedNotifications();
    return cachedNotifications.where((n) => !n.isRead).length;
  }

  // ===================== AUTH STATE GETTERS =====================

  /// Check if user is authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;

  /// Get current auth token
  String? get authToken => _apiService.authToken;

  /// Get stored user role
  String? get userRole => _storage.read<String>(CacheKeys.userRole);

  /// Get stored user profile data
  Map<String, dynamic>? get userProfileData {
    final data = _storage.read<Map<String, dynamic>>(CacheKeys.userProfile);
    if (data != null) {
      final profileData = Map<String, dynamic>.from(data);
      profileData.remove('cached_at'); // Remove cache metadata
      return profileData;
    }
    return null;
  }

  /// Get user ID from stored profile
  int? get userId {
    final profile = userProfileData;
    return profile?['id'] as int?;
  }

  /// Get user name from stored profile
  String? get userName {
    final profile = userProfileData;
    return profile?['name'] as String?;
  }

  /// Get user phone from stored profile
  String? get userPhone {
    final profile = userProfileData;
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

  // ===================== VALIDATION & UTILITY =====================

  /// Auto-check authentication status
  Future<bool> checkAuthenticationStatus() async {
    if (!isAuthenticated) return false;

    try {
      // Verify token is still valid by making a profile request
      final result = await getProfile(useCache: false);
      return result.isSuccess;
    } catch (e) {
      // Token is invalid, clear auth data
      await logout();
      return false;
    }
  }

  /// Refresh all user data
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;

    try {
      await Future.wait([
        getProfile(forceRefresh: true),
        getNotifications(forceRefresh: true),
      ]);
      print('AuthRepository: User data refreshed');
    } catch (e) {
      print('❌ AuthRepository: Error refreshing user data - $e');
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _clearAllCache();
    print('🗑️ AuthRepository: All cache cleared');
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'profile_cached': _getCachedProfile() != null,
      'profile_cache_valid': _isProfileCacheValid(),
      'notifications_cached': _getCachedNotifications().length,
      'notifications_cache_valid': _isNotificationsCacheValid(),
      'unread_count': getCachedUnreadCount(),
      'is_authenticated': isAuthenticated,
      'user_role': userRole,
    };
  }
}