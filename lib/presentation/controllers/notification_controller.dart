import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/api_response_models.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final _authRepository = Get.find<AuthRepository>();

  // ===================== REACTIVE STATE =====================

  // Notifications data
  final _notifications = <NotificationModel>[].obs;
  final _unreadCount = 0.obs;
  final _filteredNotifications = <NotificationModel>[].obs;

  // Loading states
  final _isLoading = false.obs;
  final _isRefreshing = false.obs;
  final _isLoadingMore = false.obs;
  final _isMarkingRead = false.obs;

  // Filter and search states
  final _selectedFilter = 'all'.obs;
  final _searchQuery = ''.obs;
  final _showOnlyUnread = false.obs;

  // Error states
  final _error = Rxn<String>();
  final _lastRefresh = Rxn<DateTime>();

  // Pagination
  final _currentPage = 0.obs;
  final _hasMorePages = true.obs;
  static const int _pageSize = 20;

  // ===================== GETTERS =====================

  // Data getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get filteredNotifications => _filteredNotifications;
  int get unreadCount => _unreadCount.value;
  int get totalCount => _notifications.length;

  // Loading getters
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get isMarkingRead => _isMarkingRead.value;
  bool get isAnyLoading => isLoading || isRefreshing || isLoadingMore;

  // Filter getters
  String get selectedFilter => _selectedFilter.value;
  String get searchQuery => _searchQuery.value;
  bool get showOnlyUnread => _showOnlyUnread.value;
  bool get hasActiveFilters => selectedFilter != 'all' || searchQuery.isNotEmpty || showOnlyUnread;

  // State getters
  String? get error => _error.value;
  DateTime? get lastRefresh => _lastRefresh.value;
  bool get hasMorePages => _hasMorePages.value;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get hasUnreadNotifications => _unreadCount.value > 0;

  // Computed getters
  String get unreadBadgeText {
    if (_unreadCount.value == 0) return '';
    if (_unreadCount.value > 99) return '99+';
    return _unreadCount.value.toString();
  }

  String get lastRefreshText {
    if (_lastRefresh.value == null) return 'Hech qachon';
    final now = DateTime.now();
    final diff = now.difference(_lastRefresh.value!);

    if (diff.inMinutes < 1) return 'Hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  // Filter options
  List<Map<String, dynamic>> get filterOptions => [
    {'key': 'all', 'label': 'Hammasi', 'icon': Icons.notifications, 'count': totalCount},
    {'key': 'unread', 'label': 'O\'qilmaganlar', 'icon': Icons.circle, 'count': unreadCount},
    {'key': NotificationTypes.homework, 'label': 'Vazifalar', 'icon': Icons.assignment, 'count': _getTypeCount(NotificationTypes.homework)},
    {'key': NotificationTypes.exam, 'label': 'Imtihonlar', 'icon': Icons.quiz, 'count': _getTypeCount(NotificationTypes.exam)},
    {'key': NotificationTypes.grade, 'label': 'Baholar', 'icon': Icons.grade, 'count': _getTypeCount(NotificationTypes.grade)},
    {'key': NotificationTypes.attendance, 'label': 'Davomat', 'icon': Icons.event_available, 'count': _getTypeCount(NotificationTypes.attendance)},
    {'key': NotificationTypes.payment, 'label': 'To\'lovlar', 'icon': Icons.payment, 'count': _getTypeCount(NotificationTypes.payment)},
    {'key': NotificationTypes.general, 'label': 'Umumiy', 'icon': Icons.info, 'count': _getTypeCount(NotificationTypes.general)},
  ];

  // ===================== LIFECYCLE =====================

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  @override
  void onReady() {
    super.onReady();
    loadNotifications();
  }

  // ===================== INITIALIZATION =====================

  /// Initialize notifications from cache
  void _initializeNotifications() {
    final cachedNotifications = _authRepository.getCachedNotifications();
    final cachedUnreadCount = _authRepository.getCachedUnreadCount();

    if (cachedNotifications.isNotEmpty) {
      _notifications.value = cachedNotifications;
      _applyFilters();
      print('NotificationController: Loaded ${cachedNotifications.length} cached notifications');
    }

    _unreadCount.value = cachedUnreadCount;
    print('NotificationController: Initialized with ${_unreadCount.value} unread notifications');
  }

  // ===================== DATA LOADING =====================

  /// Load notifications from API
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (_isLoading.value) return;

    _isLoading.value = true;
    _error.value = null;
    _currentPage.value = 0;
    _hasMorePages.value = true;

    try {
      final result = await _authRepository.getNotifications(
        skip: 0,
        limit: _pageSize,
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _notifications.value = result.data!;
        _applyFilters();
        _updateUnreadCount();
        _lastRefresh.value = DateTime.now();
        _hasMorePages.value = result.data!.length == _pageSize;

        print('NotificationController: Loaded ${result.data!.length} notifications');
      } else {
        _error.value = result.error?.messageUz ?? 'Bildirishnomalarni yuklab bo\'lmadi';
        _showErrorMessage(_error.value!);
      }
    } catch (e) {
      _error.value = 'Kutilmagan xatolik yuz berdi';
      _showErrorMessage(_error.value!);
      print('NotificationController: Load error - $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh notifications (pull-to-refresh)
  Future<void> refreshNotifications() async {
    if (_isRefreshing.value) return;

    _isRefreshing.value = true;
    _error.value = null;

    try {
      await Future.wait([
        loadNotifications(forceRefresh: true),
        loadUnreadCount(),
      ]);

      _showSuccessMessage('Bildirishnomalar yangilandi');
      print('NotificationController: Notifications refreshed');
    } catch (e) {
      print('NotificationController: Refresh error - $e');
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (_isLoadingMore.value || !_hasMorePages.value) return;

    _isLoadingMore.value = true;

    try {
      final nextPage = _currentPage.value + 1;
      final result = await _authRepository.getNotifications(
        skip: nextPage * _pageSize,
        limit: _pageSize,
        useCache: false,
      );

      if (result.isSuccess && result.data != null) {
        _notifications.addAll(result.data!);
        _applyFilters();
        _currentPage.value = nextPage;
        _hasMorePages.value = result.data!.length == _pageSize;

        print('NotificationController: Loaded ${result.data!.length} more notifications (page $nextPage)');
      }
    } catch (e) {
      print('NotificationController: Load more error - $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final result = await _authRepository.getUnreadNotificationCount();
      if (result.isSuccess && result.data != null) {
        _unreadCount.value = result.data!.unreadCount;
      }
    } catch (e) {
      print('NotificationController: Unread count error - $e');
    }
  }

  // ===================== NOTIFICATION ACTIONS =====================

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    final notification = _notifications.firstWhereOrNull((n) => n.id == notificationId);
    if (notification?.isRead == true) return;

    try {
      final result = await _authRepository.markNotificationRead(notificationId);

      if (result.isSuccess) {
        // Update local state immediately
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _updateUnreadCount();
          _applyFilters();
        }

        print('NotificationController: Marked notification $notificationId as read');
      }
    } catch (e) {
      print('NotificationController: Mark as read error - $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_unreadCount.value == 0) return;

    _isMarkingRead.value = true;

    try {
      final result = await _authRepository.markAllNotificationsRead();

      if (result.isSuccess) {
        // Update local state
        _notifications.value = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _unreadCount.value = 0;
        _applyFilters();

        _showSuccessMessage('Barcha bildirishnomalar o\'qilgan deb belgilandi');
        print('NotificationController: Marked all notifications as read');
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Barcha bildirishnomalarni belgilashda xatolik');
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('NotificationController: Mark all as read error - $e');
    } finally {
      _isMarkingRead.value = false;
    }
  }

  // ===================== FILTERING & SEARCH =====================

  /// Set notification filter
  void setFilter(String filter) {
    _selectedFilter.value = filter;
    _applyFilters();
    print('NotificationController: Filter set to $filter');
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery.value = query.trim();
    _applyFilters();
    print('NotificationController: Search query: "$query"');
  }

  /// Toggle show only unread
  void toggleShowOnlyUnread() {
    _showOnlyUnread.value = !_showOnlyUnread.value;
    _applyFilters();
    print('NotificationController: Show only unread: ${_showOnlyUnread.value}');
  }

  /// Clear all filters
  void clearFilters() {
    _selectedFilter.value = 'all';
    _searchQuery.value = '';
    _showOnlyUnread.value = false;
    _applyFilters();
    print('NotificationController: Filters cleared');
  }

  /// Apply current filters to notifications
  void _applyFilters() {
    var filtered = List<NotificationModel>.from(_notifications);

    // Apply type filter
    if (_selectedFilter.value != 'all') {
      if (_selectedFilter.value == 'unread') {
        filtered = filtered.where((n) => !n.isRead).toList();
      } else {
        filtered = filtered.where((n) => n.type == _selectedFilter.value).toList();
      }
    }

    // Apply unread filter
    if (_showOnlyUnread.value) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((n) =>
      n.title.toLowerCase().contains(query) ||
          n.message.toLowerCase().contains(query)
      ).toList();
    }

    // Sort by priority and date
    filtered.sort((a, b) {
      // Unread first
      if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
      // Then by priority
      if (a.priorityLevel != b.priorityLevel) return b.priorityLevel.compareTo(a.priorityLevel);
      // Finally by date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    _filteredNotifications.value = filtered;
    print('NotificationController: Applied filters, ${filtered.length} notifications shown');
  }

  // ===================== UTILITY METHODS =====================

  /// Update unread count from notifications
  void _updateUnreadCount() {
    _unreadCount.value = _notifications.where((n) => !n.isRead).length;
  }

  /// Get notification count by type
  int _getTypeCount(String type) {
    return _notifications.where((n) => n.type == type).length;
  }

  /// Get notifications by priority
  List<NotificationModel> getHighPriorityNotifications() {
    return _notifications.where((n) => n.priorityLevel >= 3 && !n.isRead).toList();
  }

  /// Get today's notifications
  List<NotificationModel> getTodayNotifications() {
    return _notifications.where((n) => n.isToday).toList();
  }

  /// Get recent notifications (last 24 hours)
  List<NotificationModel> getRecentNotifications() {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    return _notifications.where((n) => n.createdAt.isAfter(yesterday)).toList();
  }

  /// Check if notification exists
  bool hasNotification(int notificationId) {
    return _notifications.any((n) => n.id == notificationId);
  }

  /// Get notification by ID
  NotificationModel? getNotificationById(int notificationId) {
    return _notifications.firstWhereOrNull((n) => n.id == notificationId);
  }

  /// Get notification summary text
  String getNotificationSummary() {
    if (_notifications.isEmpty) return 'Bildirishnomalar yo\'q';

    final unread = _unreadCount.value;
    final total = _notifications.length;

    if (unread == 0) {
      return '$total ta bildirishnoma (hammasi o\'qilgan)';
    } else if (unread == 1) {
      return '$total ta bildirishnoma (1 ta o\'qilmagan)';
    } else {
      return '$total ta bildirishnoma ($unread ta o\'qilmagan)';
    }
  }

  /// Check if should show unread badge
  bool shouldShowUnreadBadge() {
    return _unreadCount.value > 0;
  }

  /// Get notifications grouped by date
  Map<String, List<NotificationModel>> getNotificationsGroupedByDate() {
    final grouped = <String, List<NotificationModel>>{};

    for (final notification in _filteredNotifications) {
      final dateKey = _getDateGroupKey(notification.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(notification);
    }

    return grouped;
  }

  /// Get date group key for grouping
  String _getDateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDay = DateTime(date.year, date.month, date.day);

    if (notificationDay.isAtSameMomentAs(today)) {
      return 'Bugun';
    } else if (notificationDay.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Kecha';
    } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      const weekdays = ['Yakshanba', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba'];
      return weekdays[date.weekday % 7];
    } else {
      return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
  }

  // ===================== ERROR HANDLING =====================

  /// Clear error state
  void clearError() {
    _error.value = null;
  }

  /// Retry loading notifications
  Future<void> retryLoading() async {
    _error.value = null;
    await loadNotifications(forceRefresh: true);
  }

  // ===================== MESSAGING =====================

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Muvaffaqiyat',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  // ===================== NAVIGATION =====================

  /// Navigate to notification detail
  void openNotificationDetail(NotificationModel notification) {
    // Mark as read when opening
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationTypes.homework:
        Get.toNamed('/homework/${notification.id}');
        break;
      case NotificationTypes.exam:
        Get.toNamed('/exam/${notification.id}');
        break;
      case NotificationTypes.grade:
        Get.toNamed('/grades');
        break;
      case NotificationTypes.attendance:
        Get.toNamed('/attendance');
        break;
      case NotificationTypes.payment:
        Get.toNamed('/payments');
        break;
      default:
      // Show notification detail dialog or page
        _showNotificationDetail(notification);
    }
  }

  /// Show notification detail dialog
  void _showNotificationDetail(NotificationModel notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              'Vaqt: ${notification.formattedDate}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  // ===================== DEBUG =====================

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'total_notifications': totalCount,
      'unread_count': unreadCount,
      'filtered_count': _filteredNotifications.length,
      'current_filter': selectedFilter,
      'search_query': searchQuery,
      'show_only_unread': showOnlyUnread,
      'is_loading': isAnyLoading,
      'last_refresh': lastRefresh?.toIso8601String(),
      'has_more_pages': hasMorePages,
      'current_page': _currentPage.value,
      'error': error,
    };
  }
}