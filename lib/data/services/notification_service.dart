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

  // Cache keys
  static const String _notificationsKey = 'notifications_cache';
  static const String _unreadCountKey = 'unread_count_cache';
  static const String _lastFetchKey = 'notifications_last_fetch';

  // Cache duration (30 minutes)
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
    print('NotificationService: initialized');
    _loadCachedData();
    fetchNotifications();
  }

  // ===================== FETCH NOTIFICATIONS =====================

  /// Get all notifications with caching
  Future<ApiResult<List<NotificationModel>>> fetchNotifications({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    print('NotificationService: fetching notifications');

    // Use cache if available and valid
    if (useCache && !forceRefresh && _isCacheValid()) {
      final cachedNotifications = _getCachedNotifications();
      if (cachedNotifications.isNotEmpty) {
        print('NotificationService: using cached notifications (${cachedNotifications.length})');
        _notifications.value = cachedNotifications;
        return ApiResult.success(cachedNotifications);
      }
    }

    _isLoading.value = true;

    try {
      final result = await _apiService.get<List<NotificationModel>>(
        '/notifications', // Adjust endpoint as needed
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => NotificationModel.fromJson(item)).toList();
          }
          return <NotificationModel>[];
        },
      );

      if (result.isSuccess && result.data != null) {
        print('NotificationService: fetched ${result.data!.length} notifications');

        // Sort by priority and date
        final sortedNotifications = _sortNotifications(result.data!);

        _notifications.value = sortedNotifications;
        _cacheNotifications(sortedNotifications);
        _updateUnreadCount();

        return ApiResult.success(sortedNotifications);
      } else {
        print('NotificationService: fetch failed - ${result.error?.detail}');
        return result;
      }
    } catch (e) {
      print('NotificationService: fetch error - $e');
      return ApiResult.error(ApiError(
        detail: 'Bildirishnomalarni yuklashda xatolik yuz berdi',
        type: 'fetch_error',
      ));
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get unread notifications count
  Future<ApiResult<UnreadCountModel>> fetchUnreadCount({
    bool useCache = true,
  }) async {
    print('NotificationService: fetching unread count');

    // Use cache if available and valid
    if (useCache && _isCacheValid()) {
      final cachedCount = _getCachedUnreadCount();
      if (cachedCount != null) {
        print('NotificationService: using cached unread count ($cachedCount)');
        _unreadCount.value = cachedCount;
        return ApiResult.success(UnreadCountModel(unreadCount: cachedCount));
      }
    }

    try {
      final result = await _apiService.get<UnreadCountModel>(
        '/notifications/unread-count', // Adjust endpoint as needed
        fromJson: (data) => UnreadCountModel.fromJson(data),
      );

      if (result.isSuccess && result.data != null) {
        print('NotificationService: unread count: ${result.data!.unreadCount}');
        _unreadCount.value = result.data!.unreadCount;
        _cacheUnreadCount(result.data!.unreadCount);

        return result;
      } else {
        print('NotificationService: unread count fetch failed - ${result.error?.detail}');
        return result;
      }
    } catch (e) {
      print('NotificationService: unread count error - $e');
      return ApiResult.error(ApiError(
        detail: 'O\'qilmagan bildirishnomalar sonini olishda xatolik',
        type: 'fetch_error',
      ));
    }
  }

  // ===================== MARK AS READ =====================

  /// Mark single notification as read
  Future<ApiResult<ApiResponse>> markAsRead(int notificationId) async {
    print('NotificationService: marking notification $notificationId as read');

    try {
      final result = await _apiService.put<ApiResponse>(
        '/notifications/$notificationId/read', // Adjust endpoint as needed
        fromJson: (data) => ApiResponse.fromJson(data ?? {'message': 'Bildirishnoma o\'qildi'}),
      );

      if (result.isSuccess) {
        print('NotificationService: notification marked as read');

        // Update local state
        _updateNotificationReadStatus(notificationId, true);
        _decrementUnreadCount();

        return result;
      } else {
        print('NotificationService: mark as read failed - ${result.error?.detail}');
        return result;
      }
    } catch (e) {
      print('NotificationService: mark as read error - $e');
      return ApiResult.error(ApiError(
        detail: 'Bildirishnomani o\'qilgan deb belgilashda xatolik',
        type: 'update_error',
      ));
    }
  }

  /// Mark all notifications as read
  Future<ApiResult<ApiResponse>> markAllAsRead() async {
    print('NotificationService: marking all notifications as read');

    try {
      final result = await _apiService.put<ApiResponse>(
        '/notifications/mark-all-read', // Adjust endpoint as needed
        fromJson: (data) => ApiResponse.fromJson(data ?? {'message': 'Barcha bildirishnomalar o\'qildi'}),
      );

      if (result.isSuccess) {
        print('NotificationService: all notifications marked as read');

        // Update local state
        _markAllNotificationsAsRead();
        _unreadCount.value = 0;
        _cacheUnreadCount(0);

        return result;
      } else {
        print('NotificationService: mark all as read failed - ${result.error?.detail}');
        return result;
      }
    } catch (e) {
      print('NotificationService: mark all as read error - $e');
      return ApiResult.error(ApiError(
        detail: 'Barcha bildirishnomalarni o\'qilgan deb belgilashda xatolik',
        type: 'update_error',
      ));
    }
  }

  // ===================== UTILITY METHODS =====================

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Get today's notifications
  List<NotificationModel> getTodayNotifications() {
    return _notifications.where((n) => n.isToday).toList();
  }

  /// Get notifications by priority
  List<NotificationModel> getHighPriorityNotifications() {
    return _notifications.where((n) => n.priorityLevel >= 3).toList();
  }

  /// Refresh notifications (force fetch from server)
  Future<void> refreshNotifications() async {
    print('NotificationService: refreshing notifications');
    await fetchNotifications(forceRefresh: true);
    await fetchUnreadCount(useCache: false);
  }

  // ===================== SORTING & FILTERING =====================

  List<NotificationModel> _sortNotifications(List<NotificationModel> notifications) {
    // Sort by: unread first, then by priority, then by date (newest first)
    notifications.sort((a, b) {
      // Unread notifications first
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }

      // Then by priority (highest first)
      if (a.priorityLevel != b.priorityLevel) {
        return b.priorityLevel.compareTo(a.priorityLevel);
      }

      // Finally by date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return notifications;
  }

  // ===================== LOCAL STATE MANAGEMENT =====================

  void _updateNotificationReadStatus(int notificationId, bool isRead) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: isRead);
      _cacheNotifications(_notifications);
      print('NotificationService: updated notification $notificationId read status to $isRead');
    }
  }

  void _markAllNotificationsAsRead() {
    final updatedNotifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notifications.value = updatedNotifications;
    _cacheNotifications(updatedNotifications);
    print('NotificationService: marked all notifications as read locally');
  }

  void _updateUnreadCount() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    _unreadCount.value = unreadCount;
    _cacheUnreadCount(unreadCount);
    print('NotificationService: updated unread count to $unreadCount');
  }

  void _decrementUnreadCount() {
    if (_unreadCount.value > 0) {
      _unreadCount.value = _unreadCount.value - 1;
      _cacheUnreadCount(_unreadCount.value);
      print('NotificationService: decremented unread count to ${_unreadCount.value}');
    }
  }

  // ===================== CACHE MANAGEMENT =====================

  void _loadCachedData() {
    final cachedNotifications = _getCachedNotifications();
    final cachedUnreadCount = _getCachedUnreadCount();

    if (cachedNotifications.isNotEmpty) {
      _notifications.value = cachedNotifications;
      print('NotificationService: loaded ${cachedNotifications.length} cached notifications');
    }

    if (cachedUnreadCount != null) {
      _unreadCount.value = cachedUnreadCount;
      print('NotificationService: loaded cached unread count: $cachedUnreadCount');
    }
  }

  void _cacheNotifications(List<NotificationModel> notifications) {
    final notificationsJson = notifications.map((n) => n.toJson()).toList();
    _storage.write(_notificationsKey, notificationsJson);
    _storage.write(_lastFetchKey, DateTime.now().toIso8601String());
    print('NotificationService: cached ${notifications.length} notifications');
  }

  List<NotificationModel> _getCachedNotifications() {
    final cachedData = _storage.read<List>(_notificationsKey);
    if (cachedData != null) {
      try {
        return cachedData.map((item) => NotificationModel.fromJson(item)).toList();
      } catch (e) {
        print('NotificationService: error reading cached notifications - $e');
        _storage.remove(_notificationsKey);
      }
    }
    return [];
  }

  void _cacheUnreadCount(int count) {
    _storage.write(_unreadCountKey, count);
    print('NotificationService: cached unread count: $count');
  }

  int? _getCachedUnreadCount() {
    return _storage.read<int>(_unreadCountKey);
  }

  bool _isCacheValid() {
    final lastFetchStr = _storage.read<String>(_lastFetchKey);
    if (lastFetchStr == null) return false;

    try {
      final lastFetch = DateTime.parse(lastFetchStr);
      final now = DateTime.now();
      final difference = now.difference(lastFetch);

      final isValid = difference < cacheValidDuration;
      print('NotificationService: cache valid: $isValid (last fetch: ${difference.inMinutes} minutes ago)');
      return isValid;
    } catch (e) {
      print('NotificationService: error checking cache validity - $e');
      return false;
    }
  }

  /// Clear notification cache
  void clearCache() {
    _storage.remove(_notificationsKey);
    _storage.remove(_unreadCountKey);
    _storage.remove(_lastFetchKey);
    _notifications.clear();
    _unreadCount.value = 0;
    print('NotificationService: cache cleared');
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    final lastFetchStr = _storage.read<String>(_lastFetchKey);
    final cachedCount = _getCachedNotifications().length;
    final cachedUnreadCount = _getCachedUnreadCount();

    return {
      'cached_notifications': cachedCount,
      'cached_unread_count': cachedUnreadCount,
      'last_fetch': lastFetchStr,
      'cache_valid': _isCacheValid(),
    };
  }
}