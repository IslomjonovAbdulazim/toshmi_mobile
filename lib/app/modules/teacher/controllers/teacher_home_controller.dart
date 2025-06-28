// lib/app/modules/teacher/controllers/teacher_home_controller.dart
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../services/auth_service.dart';

class TeacherHomeController extends BaseController {
  final TeacherRepository _repository = Get.find<TeacherRepository>();
  final AuthService _authService = Get.find<AuthService>();

  // Dashboard data
  final RxMap<String, dynamic> dashboardData = <String, dynamic>{}.obs;
  final RxInt currentPageIndex = 0.obs;

  // Statistics
  final RxInt totalHomework = 0.obs;
  final RxInt totalExams = 0.obs;
  final RxList<dynamic> upcomingHomework = <dynamic>[].obs;
  final RxList<dynamic> upcomingExams = <dynamic>[].obs;
  final RxList<dynamic> recentHomework = <dynamic>[].obs;
  final RxList<dynamic> recentExams = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      setLoading(true);
      clearError();

      final data = await _repository.getDashboardData();
      dashboardData.value = data;

      // Update statistics
      totalHomework.value = data['total_homework'] ?? 0;
      totalExams.value = data['total_exams'] ?? 0;
      upcomingHomework.assignAll(data['upcoming_homework'] ?? []);
      upcomingExams.assignAll(data['upcoming_exams'] ?? []);
      recentHomework.assignAll(data['recent_homework'] ?? []);
      recentExams.assignAll(data['recent_exams'] ?? []);

      print('✅ Dashboard data loaded - Homework: ${totalHomework.value}, Exams: ${totalExams.value}');
    } catch (e) {
      setError('Dashboard ma\'lumotlari yuklanmadi: $e');
    } finally {
      setLoading(false);
    }
  }

  // Navigation methods
  void navigateToHomework() {
    Get.toNamed('/teacher/homework');
  }

  void navigateToExams() {
    Get.toNamed('/teacher/exams');
  }

  void navigateToGrading() {
    Get.toNamed('/teacher/grading');
  }

  void navigateToAttendance() {
    Get.toNamed('/teacher/attendance');
  }

  void navigateToStudents() {
    Get.toNamed('/teacher/students');
  }

  // Create new assignment quick actions
  void createHomework() {
    Get.toNamed('/teacher/homework/create');
  }

  void createExam() {
    Get.toNamed('/teacher/exams/create');
  }

  // Page navigation for bottom nav
  void changePageIndex(int index) {
    currentPageIndex.value = index;
  }

  // Logout
  void logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      showError('Chiqishda xatolik: $e');
    }
  }

  // Get user info
  String get teacherName => _authService.userFullName ?? 'O\'qituvchi';
  String get teacherPhone => _authService.userPhone ?? '';

  // Get dashboard statistics
  Map<String, dynamic> get dashboardStats => {
    'homework_count': totalHomework.value,
    'exam_count': totalExams.value,
    'upcoming_assignments': upcomingHomework.length + upcomingExams.length,
    'pending_grading': _getPendingGradingCount(),
  };

  int _getPendingGradingCount() {
    // Calculate pending grading from recent assignments
    int pendingCount = 0;

    for (var homework in recentHomework) {
      // Check if homework needs grading (you might need to adjust this logic)
      if (homework['needs_grading'] == true) {
        pendingCount++;
      }
    }

    for (var exam in recentExams) {
      // Check if exam needs grading
      if (exam['needs_grading'] == true) {
        pendingCount++;
      }
    }

    return pendingCount;
  }

  // Get upcoming deadline alerts
  List<Map<String, dynamic>> get upcomingDeadlines {
    List<Map<String, dynamic>> deadlines = [];

    // Add homework deadlines
    for (var homework in upcomingHomework) {
      final dueDate = DateTime.parse(homework['due_date']);
      final daysUntil = dueDate.difference(DateTime.now()).inDays;

      deadlines.add({
        'type': 'homework',
        'title': homework['title'],
        'subject': homework['subject'] ?? 'Noma\'lum fan',
        'group': homework['group'] ?? 'Noma\'lum guruh',
        'due_date': dueDate,
        'days_until': daysUntil,
        'is_urgent': daysUntil <= 1,
      });
    }

    // Add exam deadlines
    for (var exam in upcomingExams) {
      final examDate = DateTime.parse(exam['exam_date']);
      final daysUntil = examDate.difference(DateTime.now()).inDays;

      deadlines.add({
        'type': 'exam',
        'title': exam['title'],
        'subject': exam['subject'] ?? 'Noma\'lum fan',
        'group': exam['group'] ?? 'Noma\'lum guruh',
        'due_date': examDate,
        'days_until': daysUntil,
        'is_urgent': daysUntil <= 2,
      });
    }

    // Sort by due date
    deadlines.sort((a, b) => a['due_date'].compareTo(b['due_date']));

    return deadlines.take(5).toList();
  }

  // Quick stats for overview cards
  Map<String, dynamic> get quickStats => {
    'total_assignments': totalHomework.value + totalExams.value,
    'this_week_deadlines': upcomingDeadlines.where((d) => d['days_until'] <= 7).length,
    'urgent_deadlines': upcomingDeadlines.where((d) => d['is_urgent'] == true).length,
    'pending_grading': _getPendingGradingCount(),
  };

  @override
  Future<void> refreshData() async {
    await loadDashboardData();
  }
}