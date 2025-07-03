import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../services/auth_service.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import 'student_attendance_view.dart';
import 'student_exams_view.dart';
import 'student_grades_view.dart';
import 'student_homework_view.dart';
import 'student_news_view.dart';
import 'student_payments_view.dart';
import 'student_profile_view.dart';
import 'student_schedule_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  final AuthService authService = Get.find<AuthService>();
  final StudentRepository studentRepository = StudentRepository();

  final isLoading = false.obs;
  final dashboardData = <String, dynamic>{}.obs;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final data = await studentRepository.getDashboard();
      dashboardData.value = data;
    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'student'.tr,
        leading: IconButton(
          onPressed: () => Get.to(() => const StudentNewsView()),
          icon: const Icon(Icons.newspaper),
          tooltip: 'news'.tr,
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const StudentProfileView()),
            icon: const Icon(Icons.person),
            tooltip: 'profile'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              Obx(() {
                if (isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildQuickStats(), _buildNavigationGrid()],
                );
              }),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.studentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 32,
                color: AppColors.studentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'welcome'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authService.userFullName ?? 'student'.tr,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.studentColor,
                      fontWeight: FontWeight.w600,
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

  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'today_status'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'homework'.tr,
                    '${(dashboardData['upcoming_homework'] as List?)?.length ?? 0}',
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'exams'.tr,
                    '${(dashboardData['upcoming_exams'] as List?)?.length ?? 0}',
                    Icons.quiz,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'grades'.tr,
                    '${(dashboardData['recent_grades'] as List?)?.length ?? 0}',
                    Icons.grade,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'sections'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildNavButton(
                  'homework'.tr,
                  Icons.assignment,
                  Colors.blue,
                      () => Get.to(() => const StudentHomeworkView()),
                ),
                _buildNavButton(
                  'exams'.tr,
                  Icons.quiz,
                  Colors.orange,
                      () => Get.to(() => const StudentExamsView()),
                ),
                _buildNavButton(
                  'grades'.tr,
                  Icons.grade,
                  Colors.green,
                      () => Get.to(() => const StudentGradesView()),
                ),
                _buildNavButton(
                  'schedule'.tr,
                  Icons.schedule,
                  Colors.purple,
                      () => Get.to(() => const StudentScheduleView()),
                ),
                _buildNavButton(
                  'attendance'.tr,
                  Icons.event_available,
                  Colors.teal,
                      () => Get.to(() => const StudentAttendanceView()),
                ),
                _buildNavButton(
                  'payments'.tr,
                  Icons.payment,
                  Colors.indigo,
                      () => Get.to(() => const StudentPaymentsView()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}