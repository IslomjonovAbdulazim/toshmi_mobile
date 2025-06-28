import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/models/notification_model.dart' as model;
import '../../../services/notification_service.dart';

class NotificationController extends BaseController {
  final NotificationService _notificationService = Get.find<NotificationService>();

  RxList<model.Notification> get notifications => _notificationService.notifications;
  RxInt get unreadCount => _notificationService.unreadCount;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // Load notifications
  Future<void> loadNotifications() async {
    try {
      setLoading(true);
      clearError();
      await _notificationService.loadNotifications();
    } catch (e) {
      setError('Bildirishnomalar yuklanmadi: $e');
    } finally {
      setLoading(false);
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
    } catch (e) {
      showError('Xatolik yuz berdi: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      showSuccess('Barcha bildirishnomalar o\'qilgan deb belgilandi');
    } catch (e) {
      showError('Xatolik yuz berdi: $e');
    }
  }

  // Get unread notifications
  List<model.Notification> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  // Get notifications by type
  List<model.Notification> getNotificationsByType(String type) {
    return notifications.where((n) => n.type == type).toList();
  }

  // Get today's notifications
  List<model.Notification> get todayNotifications {
    final today = DateTime.now();
    return notifications.where((n) =>
    n.createdAt.year == today.year &&
        n.createdAt.month == today.month &&
        n.createdAt.day == today.day
    ).toList();
  }

  @override
  Future<void> refreshData() async {
    await loadNotifications();
  }
}