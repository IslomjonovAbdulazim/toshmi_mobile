import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../student/views/student_news_view.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/teacher_home_controller.dart';
import '../attendance/attendance_view.dart';
import '../exams/exam_list_view.dart';
import '../grading/grading_view.dart';
import '../homework/homework_list_view.dart';
import '../profile/profile_view.dart';
import '../shared/widgets/quick_action_card.dart';
import '../shared/widgets/stats_card.dart';

class TeacherHomeView extends GetView<TeacherHomeController> {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('teacher_dashboard'.tr),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.to(() => const StudentNewsView()),
          icon: const Icon(Icons.newspaper),
          tooltip: 'news'.tr,
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!Get.isRegistered<ProfileController>()) {
                Get.lazyPut<ProfileController>(() => ProfileController());
              }
              Get.to(() => const ProfileView());
            },
            icon: const Icon(Icons.person_outline),
            tooltip: 'profile'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshDashboard(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(theme),
              const SizedBox(height: 16),
              _buildStatsSection(theme),
              const SizedBox(height: 16),
              _buildQuickActionsSection(theme),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickCreateMenu(context),
        icon: const Icon(Icons.add),
        label: Text('create'.tr),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    final now = DateTime.now();
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                greeting,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(now),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'overview'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'homework'.tr,
                  value: '${controller.totalHomework.value}',
                  icon: Icons.assignment_outlined,
                  iconColor: theme.colorScheme.primary,
                  subtitle: 'total_assignments'.tr,
                ),
              ),
              Expanded(
                child: StatsCard(
                  title: 'exams'.tr,
                  value: '${controller.totalExams.value}',
                  icon: Icons.quiz_outlined,
                  iconColor: theme.colorScheme.secondary,
                  subtitle: 'total_exams'.tr,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'quick_actions'.tr,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'homework'.tr,
                subtitle: 'create_manage'.tr,
                icon: Icons.assignment_outlined,
                iconColor: theme.colorScheme.primary,
                onTap: () => Get.to(() => const HomeworkListView()),
              ),
            ),
            Expanded(
              child: QuickActionCard(
                title: 'exams'.tr,
                subtitle: 'create_manage'.tr,
                icon: Icons.quiz_outlined,
                iconColor: theme.colorScheme.secondary,
                onTap: () => Get.to(() => const ExamListView()),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'grading'.tr,
                subtitle: 'grade_work'.tr,
                icon: Icons.grade_outlined,
                iconColor: theme.colorScheme.tertiary,
                onTap: () => Get.to(() => const GradingView()),
              ),
            ),
            Expanded(
              child: QuickActionCard(
                title: 'attendance'.tr,
                subtitle: 'take_attendance'.tr,
                icon: Icons.how_to_reg_outlined,
                iconColor: theme.colorScheme.error,
                onTap: () => Get.to(() => const AttendanceView()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      '',
      'monday'.tr,
      'tuesday'.tr,
      'wednesday'.tr,
      'thursday'.tr,
      'friday'.tr,
      'saturday'.tr,
      'sunday'.tr,
    ];
    final months = [
      '',
      'january'.tr,
      'february'.tr,
      'march'.tr,
      'april'.tr,
      'may'.tr,
      'june'.tr,
      'july'.tr,
      'august'.tr,
      'september'.tr,
      'october'.tr,
      'november'.tr,
      'december'.tr,
    ];

    return '${weekdays[date.weekday]}, ${date.day} ${months[date.month]}, ${date.year}';
  }

  void _showQuickCreateMenu(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'quick_create'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickCreateItem(
                    'homework'.tr,
                    Icons.assignment_outlined,
                    Get.theme.colorScheme.primary,
                        () {
                      Get.back();
                      Get.to(() => const HomeworkListView());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickCreateItem(
                    'exams'.tr,
                    Icons.quiz_outlined,
                    Get.theme.colorScheme.secondary,
                        () {
                      Get.back();
                      Get.to(() => const ExamListView());
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickCreateItem(
                    'take_attendance'.tr,
                    Icons.how_to_reg_outlined,
                    Get.theme.colorScheme.tertiary,
                        () {
                      Get.back();
                      Get.to(() => const AttendanceView());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickCreateItem(
                    'grade_work'.tr,
                    Icons.grade_outlined,
                    Get.theme.colorScheme.error,
                        () {
                      Get.back();
                      Get.to(() => const GradingView());
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCreateItem(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Get.textTheme.bodyMedium?.copyWith(
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
}