import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/loading_widget.dart';
import '../../student/views/student_news_view.dart';
import '../controllers/parent_controller.dart';
import 'parent_homework_view.dart';
import 'parent_grades_view.dart';
import 'parent_attendance_view.dart';
import 'parent_payments_view.dart';
import 'parent_profile_view.dart';

class ParentHomeView extends StatelessWidget {
  const ParentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ParentController());
    final authService = Get.find<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'parent'.tr,
        showBackButton: false,
        leading: IconButton(
          onPressed: () => Get.to(() => const StudentNewsView()),
          icon: const Icon(Icons.newspaper),
          tooltip: 'news'.tr,
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const ParentProfileView()),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(authService, theme),
              const SizedBox(height: 20),
              _buildChildrenOverview(controller, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthService authService, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.parentColor,
              child: Text(
                _getInitials(authService.userFullName ?? 'parent'.tr),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'welcome'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    authService.userFullName ?? 'parent'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.parentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'parent'.tr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.parentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenOverview(ParentController controller, ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      if (controller.children.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.family_restroom,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'children_list_empty'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'my_children'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.children.map((child) => _buildChildCard(child, controller, theme)),
        ],
      );
    });
  }

  Widget _buildChildCard(Map<String, dynamic> child, ParentController controller, ThemeData theme) {
    final childId = child['id'] as int;
    final name = child['name'] as String;
    final groupName = child['group_name'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showChildActions(child, controller, theme),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.parentColor,
                    child: Text(
                      _getInitials(name),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          groupName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: controller.getChildComprehensiveDashboard(childId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.parentColor),
                      ),
                    );
                  }

                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final summary = snapshot.data!['summary'] as Map<String, dynamic>;
                  return Row(
                    children: [
                      _buildSummaryItem(
                        'average'.tr,
                        '${summary['overall_average'].toStringAsFixed(1)}%',
                        Icons.star,
                        AppColors.getGradeColor(summary['overall_average']),
                        theme,
                      ),
                      _buildSummaryItem(
                        'attendance'.tr,
                        '${summary['attendance_percentage'].toStringAsFixed(1)}%',
                        Icons.event_available,
                        AppColors.getAttendanceColor('present'),
                        theme,
                      ),
                      _buildSummaryItem(
                        'homework'.tr,
                        '${summary['pending_homework']}',
                        Icons.assignment,
                        AppColors.warning,
                        theme,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showChildActions(Map<String, dynamic> child, ParentController controller, ThemeData theme) {
    final childId = child['id'] as int;
    final name = child['name'] as String;
    controller.selectChild(childId);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildActionButton(
                  'homework'.tr,
                  Icons.assignment,
                      () {
                    Get.back();
                    Get.to(() => const ParentHomeworkView(), arguments: {'childId': childId});
                  },
                  theme,
                ),
                _buildActionButton(
                  'grades'.tr,
                  Icons.star,
                      () {
                    Get.back();
                    Get.to(() => const ParentGradesView(), arguments: {'childId': childId});
                  },
                  theme,
                ),
                _buildActionButton(
                  'attendance'.tr,
                  Icons.event_available,
                      () {
                    Get.back();
                    Get.to(() => const ParentAttendanceView(), arguments: {'childId': childId});
                  },
                  theme,
                ),
                _buildActionButton(
                  'payments'.tr,
                  Icons.credit_card,
                      () {
                    Get.back();
                    Get.to(() => const ParentPaymentsView(), arguments: {'childId': childId});
                  },
                  theme,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, ThemeData theme) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.parentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.parentColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.parentColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'O';
  }
}