// lib/app/modules/teacher/views/home/teacher_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/teacher_home_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/teacher_drawer.dart';
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
      appBar: TeacherAppBar(
        title: 'Teacher Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () => _showNotifications(context),
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: theme.colorScheme.onError,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const TeacherDrawer(),
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
              const SizedBox(height: 24),
              _buildUpcomingSection(theme, context),
              const SizedBox(height: 24),
              _buildRecentActivitySection(theme),
              const SizedBox(height: 80), // Extra space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickCreateMenu(context),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
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
            DateFormat('EEEE, MMMM dd, yyyy').format(now),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ready to make today productive?',
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
      final data = controller.dashboardData;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Homework',
                  value: '${data['total_homework'] ?? 0}',
                  icon: Icons.assignment_outlined,
                  iconColor: theme.colorScheme.primary,
                  subtitle: 'Total assignments',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Exams',
                  value: '${data['total_exams'] ?? 0}',
                  icon: Icons.quiz_outlined,
                  iconColor: theme.colorScheme.secondary,
                  subtitle: 'Total exams',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Classes',
                  value: '4', // This would come from actual data
                  icon: Icons.class_outlined,
                  iconColor: theme.colorScheme.tertiary,
                  subtitle: 'Active classes',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Students',
                  value: '128', // This would come from actual data
                  icon: Icons.people_outlined,
                  iconColor: theme.colorScheme.error,
                  subtitle: 'Total students',
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
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Homework',
                subtitle: 'Manage assignments',
                icon: Icons.assignment_outlined,
                iconColor: theme.colorScheme.primary,
                onTap: () => Get.to(() => const HomeworkListView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Exams',
                subtitle: 'Manage exams',
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
                title: 'Grading',
                subtitle: 'Grade assignments',
                icon: Icons.grade_outlined,
                iconColor: theme.colorScheme.tertiary,
                onTap: () => Get.to(() => const GradingView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Attendance',
                subtitle: 'Take attendance',
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

  Widget _buildUpcomingSection(ThemeData theme, BuildContext context) {
    return Obx(() {
      final data = controller.dashboardData;
      final upcomingHomework = data['upcoming_homework'] as List? ?? [];
      final upcomingExams = data['upcoming_exams'] as List? ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _showAllUpcoming(context),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (upcomingHomework.isEmpty && upcomingExams.isEmpty)
            _buildEmptyUpcoming(theme)
          else
            _buildUpcomingList(theme, upcomingHomework, upcomingExams),
        ],
      );
    });
  }

  Widget _buildEmptyUpcoming(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'All Caught Up!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No upcoming deadlines',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingList(ThemeData theme, List upcomingHomework, List upcomingExams) {
    final allUpcoming = [
      ...upcomingHomework.map((h) => {...h, 'type': 'homework'}),
      ...upcomingExams.map((e) => {...e, 'type': 'exam'}),
    ];

    // Sort by date
    allUpcoming.sort((a, b) {
      final aDate = DateTime.parse(a['due_date'] ?? a['exam_date']);
      final bDate = DateTime.parse(b['due_date'] ?? b['exam_date']);
      return aDate.compareTo(bDate);
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allUpcoming.take(3).length,
      itemBuilder: (context, index) {
        final Map item = allUpcoming[index];
        return _buildUpcomingItem(theme, Map<String, dynamic>.from(item));
      },
    );
  }

  Widget _buildUpcomingItem(ThemeData theme, Map<String, dynamic> item) {
    final isHomework = item['type'] == 'homework';
    final date = DateTime.parse(item['due_date'] ?? item['exam_date']);
    final daysDiff = date.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isHomework
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer,
          child: Icon(
            isHomework ? Icons.assignment : Icons.quiz,
            color: isHomework
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(item['title'] ?? 'Untitled'),
        subtitle: Text('${item['subject']} • ${item['group']}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              daysDiff == 0 ? 'Today' :
              daysDiff == 1 ? 'Tomorrow' :
              '$daysDiff days',
              style: theme.textTheme.labelSmall?.copyWith(
                color: daysDiff <= 1
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              DateFormat('MMM dd').format(date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  theme,
                  icon: Icons.assignment_turned_in,
                  title: 'Graded Math Assignment #3',
                  subtitle: 'Grade 10A • 2 hours ago',
                  iconColor: theme.colorScheme.primary,
                ),
                const Divider(),
                _buildActivityItem(
                  theme,
                  icon: Icons.how_to_reg,
                  title: 'Attendance taken for Physics',
                  subtitle: 'Grade 11B • 5 hours ago',
                  iconColor: theme.colorScheme.secondary,
                ),
                const Divider(),
                _buildActivityItem(
                  theme,
                  icon: Icons.add_circle_outline,
                  title: 'Created new homework: Calculus Problems',
                  subtitle: 'Grade 12A • Yesterday',
                  iconColor: theme.colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      ThemeData theme, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color iconColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  void _showNotifications(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Get.theme.dividerColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildNotificationItem(
                    'New homework submitted',
                    'John Doe submitted Math Assignment #3',
                    '2 minutes ago',
                    Icons.assignment_turned_in,
                  ),
                  _buildNotificationItem(
                    'Exam reminder',
                    'Physics Midterm is tomorrow at 9:00 AM',
                    '1 hour ago',
                    Icons.schedule,
                  ),
                  _buildNotificationItem(
                    'Grade request',
                    'Parent requested grades for Sarah Wilson',
                    '3 hours ago',
                    Icons.grade,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Get.theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: Text(message),
        trailing: Text(
          time,
          style: Get.textTheme.bodySmall,
        ),
      ),
    );
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
              'Create New',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickCreateItem(
                    'Homework',
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
                    'Exam',
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
                    'Take Attendance',
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
                    'Grade Work',
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

  void _showAllUpcoming(BuildContext context) {
    Get.snackbar('Info', 'All upcoming view coming soon');
  }
}