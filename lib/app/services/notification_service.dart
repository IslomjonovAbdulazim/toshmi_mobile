import 'package:get/get.dart';
import '../data/models/notification_model.dart' as model;
import 'api_service.dart';

class NotificationService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<model.Notification> notifications = <model.Notification>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final response = await _apiService.get('/auth/notifications');
      final notificationList = (response.data as List)
          .map((json) => model.Notification.fromJson(json))
          .toList();

      notifications.assignAll(notificationList);
      unreadCount.value = notificationList.where((n) => !n.isRead).length;
    } catch (e) {
      print('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
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