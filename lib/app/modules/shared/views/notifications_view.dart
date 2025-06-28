import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/empty_state_widget.dart';
import '../../../utils/widgets/common/error_widget.dart';
import '../../../utils/widgets/common/loading_widget.dart';
import '../controllers/notification_controller.dart';

class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bildirishnomalar',
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? IconButton(
            onPressed: controller.markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Barchasini o\'qilgan deb belgilash',
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Bildirishnomalar yuklanmoqda...');
        }

        if (controller.hasError.value) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }

        if (controller.notifications.isEmpty) {
          return const EmptyStateWidget(
            title: 'Bildirishnomalar yo\'q',
            message: 'Hozircha hech qanday bildirishnoma yo\'q',
            icon: Icons.notifications_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildNotificationCard(notification),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(notification) {
    return Card(
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead
                ? Colors.transparent
                : AppColors.primaryBlue.withOpacity(0.05),
          ),
          child: Row(
            children: [
              _buildNotificationIcon(notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.createdAt.relativeTime,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'homework':
        icon = Icons.assignment;
        color = AppColors.info;
        break;
      case 'exam':
        icon = Icons.quiz;
        color = AppColors.warning;
        break;
      case 'grade':
        icon = Icons.grade;
        color = AppColors.success;
        break;
      case 'attendance':
        icon = Icons.how_to_reg;
        color = AppColors.secondaryOrange;
        break;
      case 'payment':
        icon = Icons.payment;
        color = AppColors.primaryBlue;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _handleNotificationTap(notification) {
    if (!notification.isRead) {
      controller.markAsRead(notification.id);
    }
    // Navigate based on notification type
    _navigateToNotificationTarget(notification);
  }

  void _navigateToNotificationTarget(notification) {
    // Implement navigation based on notification type
    switch (notification.type) {
      case 'homework':
        Get.toNamed('/homework');
        break;
      case 'exam':
        Get.toNamed('/exams');
        break;
      case 'grade':
        Get.toNamed('/grades');
        break;
      case 'attendance':
        Get.toNamed('/attendance');
        break;
      case 'payment':
        Get.toNamed('/payments');
        break;
      default:
        break;
    }
  }
}