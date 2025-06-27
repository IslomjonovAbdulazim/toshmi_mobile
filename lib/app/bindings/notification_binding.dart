import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../core/constants/api_constants.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/notification_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/models/notification_model.dart';

/// Notification binding for notification-related dependencies
///
/// This binding handles all notification-related functionality including
/// displaying notifications, managing read/unread state, and real-time updates.
/// It's designed to work seamlessly with the authentication system.
class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    _ensureCoreDependencies();

    // Initialize notification dependencies
    _initializeNotificationDependencies();

    print('NotificationBinding: Notification dependencies initialized');
  }

  void _ensureCoreDependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(AuthRepository(), permanent: true);
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
  }

  void _initializeNotificationDependencies() {
    // Initialize NotificationController - manages notification state and UI
    Get.lazyPut<NotificationController>(
          () => NotificationController(),
      fenix: true,
    );

    // Auto-load notifications after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLoadNotifications();
    });
  }

  void _autoLoadNotifications() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isAuthenticated) {
        final notificationController = Get.find<NotificationController>();
        notificationController.loadNotifications();
        notificationController.loadUnreadCount();
        print('NotificationBinding: Auto-loaded notifications for authenticated user');
      }
    } catch (e) {
      print('NotificationBinding: Error auto-loading notifications - $e');
    }
  }
}

/// Permanent notification binding for persistent notification functionality
///
/// Use this binding when notifications should persist across the entire app session.
/// This ensures notification state is maintained regardless of navigation.
class NotificationPermanentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(AuthRepository(), permanent: true);
    }

    // Initialize notification controller permanently
    Get.put<NotificationController>(
      NotificationController(),
      permanent: true,
    );

    // Setup auto-refresh for notifications
    _setupAutoRefresh();

    print('NotificationPermanentBinding: Permanent notification dependencies initialized');
  }

  void _setupAutoRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final notificationController = Get.find<NotificationController>();
        // Setup periodic refresh every 5 minutes
        Timer.periodic(Duration(minutes: 5), (timer) {
          final authController = Get.find<AuthController>();
          if (authController.isAuthenticated && !notificationController.isLoading) {
            notificationController.loadUnreadCount();
          }
        });
        print('NotificationPermanentBinding: Auto-refresh setup complete');
      } catch (e) {
        print('NotificationPermanentBinding: Error setting up auto-refresh - $e');
      }
    });
  }
}

/// Smart notification binding that initializes based on auth state
///
/// This binding checks authentication status and only initializes notifications
/// for authenticated users. It also handles dynamic initialization when users
/// log in or out.
class NotificationSmartBinding extends Bindings {
  @override
  void dependencies() {
    try {
      final authController = Get.find<AuthController>();

      if (authController.isAuthenticated) {
        // User is authenticated, initialize full notification functionality
        _initializeForAuthenticatedUser();
        print('NotificationSmartBinding: Full initialization for authenticated user');
      } else {
        // User not authenticated, minimal initialization
        _initializeMinimal();
        print('NotificationSmartBinding: Minimal initialization for unauthenticated user');
      }
    } catch (e) {
      // AuthController not available, minimal initialization
      print('NotificationSmartBinding: AuthController not found, minimal initialization');
      _initializeMinimal();
    }
  }

  void _initializeForAuthenticatedUser() {
    // Full notification functionality
    Get.lazyPut<NotificationController>(
          () => NotificationController(),
      fenix: true,
    );

    // Auto-load notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final notificationController = Get.find<NotificationController>();
        notificationController.loadNotifications();
        notificationController.loadUnreadCount();
      } catch (e) {
        print('NotificationSmartBinding: Error loading initial notifications - $e');
      }
    });
  }

  void _initializeMinimal() {
    // Just register the controller, don't load data
    Get.lazyPut<NotificationController>(
          () => NotificationController(),
    );
  }
}

/// Real-time notification binding with live updates
///
/// This binding sets up real-time notification updates using periodic refresh.
/// Ideal for dashboard screens where users need immediate notification updates.
class NotificationRealtimeBinding extends Bindings {
  @override
  void dependencies() {
    // Standard notification dependencies
    NotificationBinding().dependencies();

    // Setup real-time updates
    _setupRealtimeUpdates();

    print('NotificationRealtimeBinding: Real-time notification dependencies initialized');
  }

  void _setupRealtimeUpdates() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final notificationController = Get.find<NotificationController>();

        // More frequent updates for real-time experience (every 30 seconds)
        Timer.periodic(Duration(seconds: 30), (timer) {
          final authController = Get.find<AuthController>();
          if (authController.isAuthenticated &&
              !notificationController.isLoading &&
              !notificationController.isRefreshing) {
            notificationController.loadUnreadCount();
          }
        });

        print('NotificationRealtimeBinding: Real-time updates setup complete');
      } catch (e) {
        print('NotificationRealtimeBinding: Error setting up real-time updates - $e');
      }
    });
  }
}

/// Utility class for managing notification dependencies
class NotificationDependencyManager {
  /// Check if notification dependencies are initialized
  static bool areNotificationDependenciesInitialized() {
    return Get.isRegistered<NotificationController>();
  }

  /// Initialize notification dependencies manually
  static void initializeNotificationDependencies({bool permanent = false, bool realtime = false}) {
    if (permanent) {
      NotificationPermanentBinding().dependencies();
    } else if (realtime) {
      NotificationRealtimeBinding().dependencies();
    } else {
      NotificationBinding().dependencies();
    }
  }

  /// Clean up notification dependencies
  static void cleanupNotificationDependencies() {
    if (Get.isRegistered<NotificationController>()) {
      Get.delete<NotificationController>();
    }
    print('NotificationDependencyManager: Notification dependencies cleaned up');
  }

  /// Reset notification dependencies
  static void resetNotificationDependencies({bool permanent = false}) {
    cleanupNotificationDependencies();
    initializeNotificationDependencies(permanent: permanent);
    print('NotificationDependencyManager: Notification dependencies reset');
  }

  /// Get notification dependency status
  static Map<String, dynamic> getNotificationDependencyStatus() {
    final isInitialized = areNotificationDependenciesInitialized();
    Map<String, dynamic> status = {
      'notificationController': isInitialized,
      'isInitialized': isInitialized,
    };

    if (isInitialized) {
      try {
        final controller = Get.find<NotificationController>();
        status.addAll({
          'notificationCount': controller.totalCount,
          'unreadCount': controller.unreadCount,
          'hasNotifications': controller.hasNotifications,
          'isLoading': controller.isLoading,
          'lastRefresh': controller.lastRefresh?.toIso8601String(),
        });
      } catch (e) {
        status['error'] = 'Error getting controller status: $e';
      }
    }

    return status;
  }

  /// Pre-load notifications for better UX
  static Future<void> preloadNotifications() async {
    if (!areNotificationDependenciesInitialized()) {
      NotificationBinding().dependencies();
      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 100));
    }

    try {
      final notificationController = Get.find<NotificationController>();
      await Future.wait([
        notificationController.loadNotifications(),
        notificationController.loadUnreadCount(),
      ]);
      print('NotificationDependencyManager: Notifications preloaded');
    } catch (e) {
      print('NotificationDependencyManager: Error preloading notifications - $e');
    }
  }

  /// Refresh all notification data
  static Future<void> refreshAllNotifications() async {
    if (!areNotificationDependenciesInitialized()) {
      print('NotificationDependencyManager: Dependencies not initialized, cannot refresh');
      return;
    }

    try {
      final notificationController = Get.find<NotificationController>();
      await notificationController.refreshNotifications();
      print('NotificationDependencyManager: All notifications refreshed');
    } catch (e) {
      print('NotificationDependencyManager: Error refreshing notifications - $e');
    }
  }

  /// Mark all notifications as read
  static Future<void> markAllAsRead() async {
    if (!areNotificationDependenciesInitialized()) {
      print('NotificationDependencyManager: Dependencies not initialized');
      return;
    }

    try {
      final notificationController = Get.find<NotificationController>();
      await notificationController.markAllAsRead();
      print('NotificationDependencyManager: All notifications marked as read');
    } catch (e) {
      print('NotificationDependencyManager: Error marking all as read - $e');
    }
  }

  /// Get unread notification count
  static int getUnreadCount() {
    if (!areNotificationDependenciesInitialized()) {
      return 0;
    }

    try {
      final notificationController = Get.find<NotificationController>();
      return notificationController.unreadCount;
    } catch (e) {
      print('NotificationDependencyManager: Error getting unread count - $e');
      return 0;
    }
  }

  /// Check if there are unread notifications
  static bool hasUnreadNotifications() {
    return getUnreadCount() > 0;
  }

  /// Initialize notifications after user login
  static void initializeAfterLogin() {
    if (!areNotificationDependenciesInitialized()) {
      NotificationBinding().dependencies();
    }

    // Load notifications after a short delay
    Timer(Duration(milliseconds: 500), () {
      preloadNotifications();
    });

    print('NotificationDependencyManager: Initialized notifications after login');
  }

  /// Cleanup notifications after user logout
  static void cleanupAfterLogout() {
    if (areNotificationDependenciesInitialized()) {
      try {
        final notificationController = Get.find<NotificationController>();
        notificationController.clearAllNotifications();
      } catch (e) {
        print('NotificationDependencyManager: Error clearing notifications - $e');
      }
    }

    print('NotificationDependencyManager: Cleaned up notifications after logout');
  }
}

/// Notification action helper for common operations
class NotificationActionHelper {
  /// Show notification count badge
  static Widget buildNotificationBadge({
    required Widget child,
    bool showBadge = true,
    Color badgeColor = Colors.red,
    Color textColor = Colors.white,
  }) {
    if (!NotificationDependencyManager.areNotificationDependenciesInitialized()) {
      return child;
    }

    return GetBuilder<NotificationController>(
      builder: (controller) {
        final unreadCount = controller.unreadCount;

        if (!showBadge || unreadCount == 0) {
          return child;
        }

        return Badge(
          label: Text(
            controller.unreadBadgeText,
            style: TextStyle(color: textColor, fontSize: 12),
          ),
          backgroundColor: badgeColor,
          child: child,
        );
      },
    );
  }

  /// Quick mark notification as read
  static Future<void> quickMarkAsRead(int notificationId) async {
    if (!NotificationDependencyManager.areNotificationDependenciesInitialized()) {
      return;
    }

    try {
      final notificationController = Get.find<NotificationController>();
      await notificationController.markAsRead(notificationId);
    } catch (e) {
      print('NotificationActionHelper: Error marking notification as read - $e');
    }
  }

  /// Show notification bottom sheet
  static void showNotificationSheet() {
    if (!NotificationDependencyManager.areNotificationDependenciesInitialized()) {
      NotificationBinding().dependencies();
    }

    Get.bottomSheet(
      NotificationBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

/// Notification bottom sheet widget
class NotificationBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bildirishnomalar',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => NotificationDependencyManager.markAllAsRead(),
                  child: Text('Barchasini belgilash'),
                ),
              ],
            ),
          ),

          // Notification list
          Expanded(
            child: GetBuilder<NotificationController>(
              builder: (controller) {
                if (controller.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!controller.hasNotifications) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Bildirishnomalar mavjud emas'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshNotifications(),
                  child: ListView.builder(
                    itemCount: controller.filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = controller.filteredNotifications[index];
                      return NotificationTile(notification: notification);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual notification tile widget
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
        child: Icon(
          _getNotificationIcon(notification.type),
          color: Colors.white,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          SizedBox(height: 4),
          Text(
            notification.timeAgo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () async {
        if (!notification.isRead) {
          await NotificationActionHelper.quickMarkAsRead(notification.id);
        }
        // Handle notification tap action
        _handleNotificationTap(notification);
      },
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case NotificationTypes.homework:
        return Icons.assignment;
      case NotificationTypes.exam:
        return Icons.quiz;
      case NotificationTypes.grade:
        return Icons.grade;
      case NotificationTypes.attendance:
        return Icons.event_available;
      case NotificationTypes.payment:
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationTypes.homework:
      // Navigate to homework detail
        break;
      case NotificationTypes.exam:
      // Navigate to exam detail
        break;
      case NotificationTypes.grade:
      // Navigate to grades
        break;
      case NotificationTypes.attendance:
      // Navigate to attendance
        break;
      case NotificationTypes.payment:
      // Navigate to payments
        break;
    }
  }
}