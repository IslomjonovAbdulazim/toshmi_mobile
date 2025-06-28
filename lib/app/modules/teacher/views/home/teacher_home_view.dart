// lib/app/modules/teacher/views/teacher_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/loading_widget.dart';
import '../../../../utils/widgets/common/error_widget.dart';
import '../../../../utils/extensions/datetime_extensions.dart';
import '../../controllers/teacher_home_controller.dart';

class TeacherHomeView extends GetView<TeacherHomeController> {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'O\'qituvchi paneli',
        actions: [
          IconButton(
            onPressed: () => controller.loadDashboardData(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                controller.logout();
              } else if (value == 'profile') {
                Get.toNamed('/profile');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Chiqish'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Ma\'lumotlar yuklanmoqda...');
        }

        if (controller.hasError.value) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                _buildWelcomeSection(),
                const SizedBox(height: 24),

                // Quick stats cards
                _buildQuickStatsSection(),
                const SizedBox(height: 24),

                // Main action buttons
                _buildMainActionsSection(),
                const SizedBox(height: 24),

                // Upcoming deadlines
                _buildUpcomingDeadlinesSection(),
                const SizedBox(height: 24),

                // Recent assignments
                _buildRecentAssignmentsSection(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yangi vazifa'),
        backgroundColor: AppColors.teacherColor,
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.teacherColor,
            AppColors.teacherColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xush kelibsiz!',
            style: Get.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.teacherName,
            style: Get.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugun ${DateTime.now().formatDate}',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Obx(() {
      final stats = controller.quickStats;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tezkor ko\'rsatkichlar',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Jami vazifalar',
                  value: stats['total_assignments'].toString(),
                  icon: Icons.assignment,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Bu hafta',
                  value: stats['this_week_deadlines'].toString(),
                  icon: Icons.schedule,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Shoshilinch',
                  value: stats['urgent_deadlines'].toString(),
                  icon: Icons.priority_high,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Baholash kerak',
                  value: stats['pending_grading'].toString(),
                  icon: Icons.grade,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: Get.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Boshqaruv',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              title: 'Vazifalar',
              icon: Icons.assignment,
              color: AppColors.primaryBlue,
              onTap: controller.navigateToHomework,
            ),
            _buildActionCard(
              title: 'Imtihonlar',
              icon: Icons.quiz,
              color: AppColors.secondaryOrange,
              onTap: controller.navigateToExams,
            ),
            _buildActionCard(
              title: 'Baholash',
              icon: Icons.grade,
              color: AppColors.success,
              onTap: controller.navigateToGrading,
            ),
            _buildActionCard(
              title: 'Davomat',
              icon: Icons.how_to_reg,
              color: AppColors.teacherColor,
              onTap: controller.navigateToAttendance,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Get.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDeadlinesSection() {
    return Obx(() {
      final deadlines = controller.upcomingDeadlines;

      if (deadlines.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yaqin muddatlar',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full deadlines view
                },
                child: const Text('Barchasini ko\'rish'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deadlines.take(3).length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final deadline = deadlines[index];
              return _buildDeadlineCard(deadline);
            },
          ),
        ],
      );
    });
  }

  Widget _buildDeadlineCard(Map<String, dynamic> deadline) {
    final isUrgent = deadline['is_urgent'] == true;
    final color = isUrgent ? AppColors.error : AppColors.warning;
    final daysUntil = deadline['days_until'] as int;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            deadline['type'] == 'homework' ? Icons.assignment : Icons.quiz,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadline['title'],
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${deadline['subject']} • ${deadline['group']}',
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              daysUntil == 0 ? 'Bugun' : '$daysUntil kun',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAssignmentsSection() {
    return Obx(() {
      final recentHomework = controller.recentHomework;
      final recentExams = controller.recentExams;

      if (recentHomework.isEmpty && recentExams.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'So\'nggi vazifalar',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (recentHomework.isNotEmpty) ...[
            _buildAssignmentsList('Vazifalar', recentHomework, 'homework'),
            const SizedBox(height: 16),
          ],
          if (recentExams.isNotEmpty)
            _buildAssignmentsList('Imtihonlar', recentExams, 'exam'),
        ],
      );
    });
  }

  Widget _buildAssignmentsList(String title, List<dynamic> assignments, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignments.take(3).length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return _buildAssignmentCard(assignment, type);
          },
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(dynamic assignment, String type) {
    final date = DateTime.parse(
        type == 'homework' ? assignment['due_date'] : assignment['exam_date']
    );

    return Card(
      child: ListTile(
        leading: Icon(
          type == 'homework' ? Icons.assignment : Icons.quiz,
          color: type == 'homework' ? AppColors.primaryBlue : AppColors.secondaryOrange,
        ),
        title: Text(
          assignment['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${assignment['subject']} • ${assignment['group']}'),
            Text(
              '${type == 'homework' ? 'Muddat' : 'Sana'}: ${date.formatDate}',
              style: TextStyle(
                color: Get.theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'grade') {
              if (type == 'homework') {
                controller.navigateToGrading();
              }
            } else if (value == 'edit') {
              // Navigate to edit
            } else if (value == 'delete') {
              // Delete assignment
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'grade',
              child: Row(
                children: [
                  Icon(Icons.grade),
                  SizedBox(width: 8),
                  Text('Baholash'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Tahrirlash'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('O\'chirish', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Yangi vazifa yaratish'),
        content: const Text('Qaysi turdagi vazifa yaratmoqchisiz?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              controller.createHomework();
            },
            child: const Text('Uy vazifasi'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.createExam();
            },
            child: const Text('Imtihon'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
        ],
      ),
    );
  }
}