import '../../../core/base/base_repository.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart' as model;
import '../../utils/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

class AuthRepository extends BaseRepository {
  final AuthService _authService = Get.find<AuthService>();

  // Login user
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await post(ApiConstants.login, {
        'phone': phone,
        'password': password,
        'role': role,
      });

      final data = response.body as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      await _authService.login(token: token, user: user);

      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await put(ApiConstants.changePassword, {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final response = await get(ApiConstants.profile);
      final userData = response.body as Map<String, dynamic>;
      final user = User.fromJson(userData);

      await _authService.updateUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      await put(ApiConstants.profile, {
        'first_name': firstName,
        'last_name': lastName,
      });

      return await getProfile();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get notifications
  Future<List<model.Notification>> getNotifications({
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final query = buildPaginationQuery(page: (skip ~/ limit) + 1, limit: limit);
      final response = await get(ApiConstants.notifications, query: query);

      return parseList(response.body, model.Notification.fromJson);
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  // Mark notification as read
  Future<void> markNotificationRead(int notificationId) async {
    try {
      await put('${ApiConstants.notifications}/$notificationId/read', {});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    try {
      await put('${ApiConstants.notifications}/mark-all-read', {});
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await get('${ApiConstants.notifications}/unread-count');
      final data = response.body as Map<String, dynamic>;
      return data['unread_count'] as int;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      // Implement token refresh if your API supports it
      return await _authService.refreshToken();
    } catch (e) {
      return false;
    }
  }

  // Verify token validity
  Future<bool> verifyToken() async {
    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void clearCache() {
    // Clear cached user data and notifications
  }
}