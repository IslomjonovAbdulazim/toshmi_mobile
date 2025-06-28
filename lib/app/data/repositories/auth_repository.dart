// lib/app/data/repositories/auth_repository.dart
import '../../../core/base/base_repository.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart' as model;
import '../../utils/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

class AuthRepository extends BaseRepository {
  final AuthService _authService = Get.find<AuthService>();

  // FIXED: Login user with proper role handling
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      print('🔐 Attempting login - Phone: $phone, Role: $role');

      final response = await post(ApiConstants.login, {
        'phone': phone,
        'password': password,
        'role': role,
      });

      final data = response.body as Map<String, dynamic>;
      print('📦 Login response data: $data');

      final token = data['access_token'] as String;
      final userRole = data['role'] as String; // Get role from top level
      final userData = data['user'] as Map<String, dynamic>;

      // FIXED: Add role to user data before creating User object
      final completeUserData = {
        ...userData,
        'role': userRole, // Add the role to user data
      };

      final user = User.fromJson(completeUserData);
      print('👤 Created user: ${user.fullName}, Role: ${user.role}');

      // Save auth data
      await _authService.login(token: token, user: user);
      print('✅ Auth service login completed');

      return data;
    } catch (e) {
      print('❌ Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Rest of your methods remain the same...
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

  Future<void> markNotificationRead(int notificationId) async {
    try {
      await put('${ApiConstants.notificationRead}/$notificationId/read', {});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await put(ApiConstants.notificationMarkAllRead, {});
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await get(ApiConstants.notificationUnreadCount);
      final data = response.body as Map<String, dynamic>;
      return data['unread_count'] as int;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<bool> refreshToken() async {
    try {
      return await _authService.refreshToken();
    } catch (e) {
      return false;
    }
  }

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