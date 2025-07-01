// lib/app/modules/teacher/views/home/teacher_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/teacher_home_controller.dart';
import '../shared/widgets/stats_card.dart';
import '../shared/widgets/quick_action_card.dart';
import '../homework/homework_list_view.dart';
import '../exams/exam_list_view.dart';
import '../grading/grading_view.dart';
import '../attendance/attendance_view.dart';

class TeacherHomeView extends GetView<TeacherHomeController> {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('O\'qituvchi Paneli'), // Uzbek: Teacher Dashboard
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshDashboard(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(theme),
              const SizedBox(height: 24),
              _buildStatsSection(theme),
              const SizedBox(height: 24),
              _buildQuickActionsSection(theme),
              const SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickCreateMenu(context),
        icon: const Icon(Icons.add),
        label: const Text('Yaratish'), // Uzbek: Create
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
          Text(
            greeting,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(now),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'O\'qitish va ilhomlantirish uchun tayyormiz!', // Uzbek: Ready to teach and inspire!
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
            ],
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
            'Umumiy ma\'lumot', // Uzbek: Overview
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Uy vazifalar', // Uzbek: Homework
                  value: '${controller.totalHomework.value}',
                  icon: Icons.assignment_outlined,
                  iconColor: theme.colorScheme.primary,
                  subtitle: 'Jami vazifalar', // Uzbek: Total assignments
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Imtihonlar', // Uzbek: Exams
                  value: '${controller.totalExams.value}',
                  icon: Icons.quiz_outlined,
                  iconColor: theme.colorScheme.secondary,
                  subtitle: 'Jami imtihonlar', // Uzbek: Total exams
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
          'Tezkor amallar', // Uzbek: Quick Actions
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Uy vazifalar', // Uzbek: Homework
                subtitle: 'Yaratish va boshqarish', // Uzbek: Create & manage
                icon: Icons.assignment_outlined,
                iconColor: theme.colorScheme.primary,
                onTap: () => Get.to(() => const HomeworkListView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Imtihonlar', // Uzbek: Exams
                subtitle: 'Yaratish va boshqarish', // Uzbek: Create & manage
                icon: Icons.quiz_outlined,
                iconColor: theme.colorScheme.secondary,
                onTap: () => Get.to(() => const ExamListView()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Baholar', // Uzbek: Grading
                subtitle: 'Ishlarni baholash', // Uzbek: Grade work
                icon: Icons.grade_outlined,
                iconColor: theme.colorScheme.tertiary,
                onTap: () => Get.to(() => const GradingView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Davomat', // Uzbek: Attendance
                subtitle: 'Davomat olish', // Uzbek: Take attendance
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
    if (hour < 12) return 'Xayrli tong!'; // Uzbek: Good Morning!
    if (hour < 17) return 'Xayrli kun!'; // Uzbek: Good Afternoon!
    return 'Xayrli kech!'; // Uzbek: Good Evening!
  }

  String _formatDate(DateTime date) {
    // Format in Uzbek style
    final weekdays = [
      '', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba'
    ];
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
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
              'Tezkor yaratish', // Uzbek: Quick Create
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickCreateItem(
                    'Uy vazifa', // Uzbek: Homework
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
                    'Imtihon', // Uzbek: Exam
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
                    'Davomat olish', // Uzbek: Take Attendance
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
                    'Baholash', // Uzbek: Grade Work
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

  Widget _buildQuickCreateItem(String title, IconData icon, Color color, VoidCallback onTap) {
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
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
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