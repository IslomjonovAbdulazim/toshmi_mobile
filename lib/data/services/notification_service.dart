import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_models.dart';
import '../models/notification_model.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Cache settings
  static const Duration cacheValidDuration = Duration(minutes: 30);

  // Observable data
  final _notifications = <NotificationModel>[].obs;
  final _unreadCount = 0.obs;
  final _isLoading = false.obs;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount.value;
  bool get isLoading => _isLoading.value;
  bool get hasUnread => _unreadCount.value > 0;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
    fetchNotifications();
  }

  // Fetch all notifications
  Future<ApiResult<List<NotificationModel>>> fetchNotifications({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Use cache if available and valid
    if (useCache && !forceRefresh && _isCacheValid()) {
      final cachedNotifications = _getCachedNotifications();
      if (cachedNotifications.isNotEmpty) {
        _notifications.value = cachedNotifications;
        return ApiResult.success(cachedNotifications);
      }
    }

    _isLoading.value = true;

    try {
      final result = await _apiService.get<List<NotificationModel>>(
        PublicEndpoints.notifications,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => NotificationModel.fromJson(item)).toList();
          }
          return <NotificationModel>[];
        },
      );

      if (result.isSuccess && result.data != null) {
        final sortedNotifications = _sortNotifications(result.data!);
        _notifications.value = sortedNotifications;
        _cacheNotifications(sortedNotifications);
        await _updateUnreadCount();
        return ApiResult.success(sortedNotifications);
      } else {
        return result;
      }
    } finally {
      _isLoading.value = false;
    }
  }

  // Mark notification as read
  Future<ApiResult<void>> markAsRead(int notificationId) async {
    final result = await _apiService.put<ApiResponse>(
      '${PublicEndpoints.notifications}/$notificationId/read',
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    if (result.isSuccess) {
      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedNotification = _notifications[index].copyWith(isRead: true);
        _notifications[index] = updatedNotification;
        _notifications.refresh();

        // Update unread count
        _unreadCount.value = _notifications.where((n) => !n.isRead).length;
        _cacheNotifications(_notifications);
      }
    }

    return ApiResult.success(null);
  }

  // Mark all notifications as read
  Future<ApiResult<void>> markAllAsRead() async {
    final result = await _apiService.put<ApiResponse>(
      '${PublicEndpoints.notifications}/read-all',
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    if (result.isSuccess) {
      // Update all local notifications
      _notifications.value = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _unreadCount.value = 0;
      _cacheNotifications(_notifications);
    }

    return ApiResult.success(null);
  }

  // Get unread count
  Future<ApiResult<int>> getUnreadCount() async {
    final result = await _apiService.get<UnreadCountModel>(
      '${PublicEndpoints.notifications}/unread-count',
      fromJson: (data) => UnreadCountModel.fromJson(data),
    );

    if (result.isSuccess && result.data != null) {
      _unreadCount.value = result.data!.unreadCount;
      return ApiResult.success(result.data!.unreadCount);
    }

    return ApiResult.error(result.error!);
  }

  // Refresh notifications
  Future<void> refresh() async {
    await fetchNotifications(forceRefresh: true);
  }

  // Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Get recent notifications (last 24 hours)
  List<NotificationModel> getRecentNotifications() {
    return _notifications.where((n) => n.isRecent).toList();
  }

  // Private helper methods
  List<NotificationModel> _sortNotifications(List<NotificationModel> notifications) {
    notifications.sort((a, b) {
      // Sort by read status first (unread first)
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }
      // Then by importance
      if (a.isImportant != b.isImportant) {
        return a.isImportant ? -1 : 1;
      }
      // Finally by date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
    return notifications;
  }

  Future<void> _updateUnreadCount() async {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  void _loadCachedData() {
    final cachedNotifications = _getCachedNotifications();
    if (cachedNotifications.isNotEmpty) {
      _notifications.value = cachedNotifications;
      _unreadCount.value = cachedNotifications.where((n) => !n.isRead).length;
    }
  }

  List<NotificationModel> _getCachedNotifications() {
    final cachedData = _storage.read<List<dynamic>>(CacheKeys.notifications);
    if (cachedData != null) {
      return cachedData
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  void _cacheNotifications(List<NotificationModel> notifications) {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    _storage.write(CacheKeys.notifications, jsonList);
    _storage.write('notifications_last_fetch', DateTime.now().toIso8601String());
  }

  bool _isCacheValid() {
    final lastFetchStr = _storage.read<String>('notifications_last_fetch');
    if (lastFetchStr == null) return false;

    final lastFetch = DateTime.parse(lastFetchStr);
    final now = DateTime.now();
    return now.difference(lastFetch) < cacheValidDuration;
  }
}