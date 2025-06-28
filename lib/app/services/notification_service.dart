import 'package:get/get.dart';
import '../data/models/notification_model.dart' as model;
import 'api_service.dart';
import 'auth_service.dart';

class NotificationService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<model.Notification> notifications = <model.Notification>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Don't auto-load notifications - wait for explicit call
  }

  Future<void> loadNotifications() async {
    // Only load if user is authenticated
    if (!_authService.isLoggedIn) {
      print('Cannot load notifications: User not authenticated');
      return;
    }

    try {
      final response = await _apiService.get('/auth/notifications');
      final notificationList = (response.data as List)
          .map((json) => model.Notification.fromJson(json))
          .toList();

      notifications.assignAll(notificationList);
      unreadCount.value = notificationList.where((n) => !n.isRead).length;

      print('Loaded ${notificationList.length} notifications');
    } catch (e) {
      print('Failed to load notifications: $e');
      // Don't throw error to prevent app crashes
    }
  }

  Future<void> markAsRead(int notificationId) async {
    if (!_authService.isLoggedIn) return;

    try {
      await _apiService.put('/auth/notifications/$notificationId/read', data: {});

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (!_authService.isLoggedIn) return;

    try {
      await _apiService.put('/auth/notifications/mark-all-read', data: {});

      final updatedNotifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifications.assignAll(updatedNotifications);
      unreadCount.value = 0;
    } catch (e) {
      print('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> getUnreadCount() async {
    if (!_authService.isLoggedIn) return;

    try {
      final response = await _apiService.get('/auth/notifications/unread-count');
      unreadCount.value = response.data['unread_count'] ?? 0;
    } catch (e) {
      print('Failed to get unread count: $e');
    }
  }

  void clearNotifications() {
    notifications.clear();
    unreadCount.value = 0;
  }
}