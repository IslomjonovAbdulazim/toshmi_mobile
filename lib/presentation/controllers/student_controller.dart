import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/models/homework_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/dashboard_models.dart';

class StudentController extends GetxController {
  static StudentController get to => Get.find();

  final _studentRepository = Get.find<StudentRepository>();

  // ===================== REACTIVE STATE =====================

  // Academic data
  final _homework = <HomeworkModel>[].obs;
  final _exams = <ExamModel>[].obs;
  final _grades = Rxn<GradesResponseModel>();
  final _attendance = <AttendanceModel>[].obs;
  final _schedule = <ScheduleModel>[].obs;
  final _payments = Rxn<PaymentsResponseModel>();
  final _dashboard = Rxn<StudentDashboardModel>();

  // Loading states
  final _isHomeworkLoading = false.obs;
  final _isExamsLoading = false.obs;
  final _isGradesLoading = false.obs;
  final _isAttendanceLoading = false.obs;
  final _isScheduleLoading = false.obs;
  final _isPaymentsLoading = false.obs;
  final _isDashboardLoading = false.obs;
  final _isRefreshing = false.obs;

  // Filter states
  final _homeworkFilter = 'all'.obs;
  final _examFilter = 'all'.obs;
  final _scheduleDay = (DateTime.now().weekday - 1).obs; // 0 = Monday

  // Error states
  final _homeworkError = Rxn<String>();
  final _examsError = Rxn<String>();
  final _gradesError = Rxn<String>();
  final _attendanceError = Rxn<String>();
  final _scheduleError = Rxn<String>();
  final _paymentsError = Rxn<String>();

  // UI states
  final _selectedTabIndex = 0.obs;
  final _showCompletedHomework = false.obs;

  // ===================== GETTERS =====================

  // Data getters
  List<HomeworkModel> get homework => _homework;
  List<ExamModel> get exams => _exams;
  GradesResponseModel? get grades => _grades.value;
  List<AttendanceModel> get attendance => _attendance;
  List<ScheduleModel> get schedule => _schedule;
  PaymentsResponseModel? get payments => _payments.value;
  StudentDashboardModel? get dashboard => _dashboard.value;

  // Loading getters
  bool get isHomeworkLoading => _isHomeworkLoading.value;
  bool get isExamsLoading => _isExamsLoading.value;
  bool get isGradesLoading => _isGradesLoading.value;
  bool get isAttendanceLoading => _isAttendanceLoading.value;
  bool get isScheduleLoading => _isScheduleLoading.value;
  bool get isPaymentsLoading => _isPaymentsLoading.value;
  bool get isDashboardLoading => _isDashboardLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isAnyLoading => isHomeworkLoading || isExamsLoading || isGradesLoading ||
      isAttendanceLoading || isScheduleLoading || isPaymentsLoading;

  // Filter getters
  String get homeworkFilter => _homeworkFilter.value;
  String get examFilter => _examFilter.value;
  int get scheduleDay => _scheduleDay.value;
  bool get showCompletedHomework => _showCompletedHomework.value;

  // Error getters
  String? get homeworkError => _homeworkError.value;
  String? get examsError => _examsError.value;
  String? get gradesError => _gradesError.value;
  String? get attendanceError => _attendanceError.value;
  String? get scheduleError => _scheduleError.value;
  String? get paymentsError => _paymentsError.value;

  // UI getters
  int get selectedTabIndex => _selectedTabIndex.value;

  // ===================== COMPUTED PROPERTIES =====================

  // Homework computations
  List<HomeworkModel> get filteredHomework {
    var filtered = _homework.toList();

    switch (_homeworkFilter.value) {
      case 'pending':
        filtered = filtered.where((h) => !h.hasGrade && h.dueDate.isAfter(DateTime.now())).toList();
        break;
      case 'overdue':
        filtered = filtered.where((h) => h.isOverdue && !h.hasGrade).toList();
        break;
      case 'completed':
        filtered = filtered.where((h) => h.hasGrade).toList();
        break;
      case 'due_soon':
        filtered = filtered.where((h) => h.isDueToday || h.isDueTomorrow).toList();
        break;
      default: // 'all'
        if (!_showCompletedHomework.value) {
          filtered = filtered.where((h) => !h.hasGrade).toList();
        }
    }

    // Sort by priority and due date
    filtered.sort((a, b) {
      if (a.priorityLevel != b.priorityLevel) {
        return b.priorityLevel.compareTo(a.priorityLevel);
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return filtered;
  }

  List<HomeworkModel> get upcomingHomework => _homework.where((h) =>
  !h.hasGrade && h.dueDate.isAfter(DateTime.now()) && h.daysUntilDue <= 7).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<HomeworkModel> get overdueHomework => _homework.where((h) =>
  h.isOverdue && !h.hasGrade).toList()
    ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

  List<HomeworkModel> get dueTodayHomework => _homework.where((h) => h.isDueToday).toList();

  int get pendingHomeworkCount => _homework.where((h) => !h.hasGrade && !h.isOverdue).length;
  int get overdueHomeworkCount => overdueHomework.length;

  // Exam computations
  List<ExamModel> get filteredExams {
    var filtered = _exams.toList();

    switch (_examFilter.value) {
      case 'upcoming':
        filtered = filtered.where((e) => e.examDate.isAfter(DateTime.now())).toList();
        break;
      case 'past':
        filtered = filtered.where((e) => e.isPast).toList();
        break;
      case 'this_week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        filtered = filtered.where((e) =>
        e.examDate.isAfter(weekStart) && e.examDate.isBefore(weekEnd)).toList();
        break;
      default: // 'all'
    }

    // Sort by exam date
    filtered.sort((a, b) => a.examDate.compareTo(b.examDate));
    return filtered;
  }

  List<ExamModel> get upcomingExams => _exams.where((e) =>
  e.examDate.isAfter(DateTime.now()) && e.daysUntilExam <= 30).toList()
    ..sort((a, b) => a.examDate.compareTo(b.examDate));

  List<ExamModel> get todaysExams => _exams.where((e) => e.isToday).toList();
  List<ExamModel> get tomorrowsExams => _exams.where((e) => e.isTomorrow).toList();

  // Schedule computations
  List<ScheduleModel> get filteredSchedule {
    return _schedule.where((s) => s.day == _scheduleDay.value).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<ScheduleModel> get todaysSchedule => _schedule.where((s) => s.isToday).toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  ScheduleModel? get currentClass => todaysSchedule.where((s) => s.isCurrentlyActive).firstOrNull;
  ScheduleModel? get nextClass => todaysSchedule.where((s) => s.isUpcomingToday).firstOrNull;

  // Grade computations
  double get averageGrade => _grades.value?.averageGrade ?? 0.0;
  String get gradeStatus => _grades.value?.averageGradeStatus ?? 'Ma\'lumot yo\'q';
  int get totalGrades => _grades.value?.totalGradesCount ?? 0;
  int get pendingGrades => _grades.value?.pendingCount ?? 0;

  List<dynamic> get recentGrades {
    if (_grades.value == null) return [];

    final allGrades = <dynamic>[];
    allGrades.addAll(_grades.value!.homeworkGrades);
    allGrades.addAll(_grades.value!.examGrades);

    allGrades.sort((a, b) {
      final aDate = a.gradedAt as DateTime?;
      final bDate = b.gradedAt as DateTime?;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return allGrades.take(5).toList();
  }

  // Payment computations
  int get totalPaidAmount => _payments.value?.totalPaidAmount ?? 0;
  String get formattedTotalPaid => _payments.value?.formattedTotal ?? '0 so\'m';
  int get pendingPaymentsCount => _payments.value?.pendingPaymentsCount ?? 0;
  int get overduePaymentsCount => _payments.value?.overduePaymentsCount ?? 0;
  List<PaymentModel> get recentPayments => _payments.value?.recentPayments ?? [];

  // Dashboard computations
  int get urgentItemsCount => (dashboard?.urgentItemsCount ?? 0) + overdueHomeworkCount;
  bool get hasUrgentItems => urgentItemsCount > 0;

  // Performance summary
  Map<String, dynamic> get performanceSummary {
    return {
      'averageGrade': averageGrade,
      'gradeStatus': gradeStatus,
      'totalHomework': _homework.length,
      'pendingHomework': pendingHomeworkCount,
      'overdueHomework': overdueHomeworkCount,
      'totalExams': _exams.length,
      'upcomingExams': upcomingExams.length,
      'attendancePercentage': 0.0, // Would need attendance calculation
      'totalPayments': totalPaidAmount,
      'pendingPayments': pendingPaymentsCount,
    };
  }

  // ===================== LIFECYCLE =====================

  @override
  void onInit() {
    super.onInit();
    _initializeFromCache();
  }

  @override
  void onReady() {
    super.onReady();
    loadDashboard();
  }

  // ===================== INITIALIZATION =====================

  /// Initialize data from cache
  void _initializeFromCache() {
    final cachedData = _studentRepository.getAllCachedData();

    _homework.value = cachedData['homework'] ?? [];
    _exams.value = cachedData['exams'] ?? [];
    _grades.value = cachedData['grades'];
    _schedule.value = cachedData['schedule'] ?? [];
    _payments.value = cachedData['payments'];

    print('StudentController: Initialized from cache');
    print('- Homework: ${_homework.length}');
    print('- Exams: ${_exams.length}');
    print('- Schedule: ${_schedule.length}');
  }

  // ===================== DATA LOADING =====================

  /// Load dashboard data
  Future<void> loadDashboard({bool forceRefresh = false}) async {
    _isDashboardLoading.value = true;

    try {
      final result = await _studentRepository.getDashboard();

      if (result.isSuccess && result.data != null) {
        _dashboard.value = result.data;
        print('StudentController: Dashboard loaded');
      }
    } catch (e) {
      print('StudentController: Dashboard load error - $e');
    } finally {
      _isDashboardLoading.value = false;
    }
  }

  /// Load homework data
  Future<void> loadHomework({bool forceRefresh = false}) async {
    _isHomeworkLoading.value = true;
    _homeworkError.value = null;

    try {
      final result = await _studentRepository.getHomework(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _homework.value = result.data!;
        print('StudentController: Loaded ${result.data!.length} homework assignments');
      } else {
        _homeworkError.value = result.error?.messageUz ?? 'Vazifalarni yuklab bo\'lmadi';
      }
    } catch (e) {
      _homeworkError.value = 'Kutilmagan xatolik yuz berdi';
      print('StudentController: Homework load error - $e');
    } finally {
      _isHomeworkLoading.value = false;
    }
  }

  /// Load exams data
  Future<void> loadExams({bool forceRefresh = false}) async {
    _isExamsLoading.value = true;
    _examsError.value = null;

    try {
      final result = await _studentRepository.getExams(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _exams.value = result.data!;
        print('StudentController: Loaded ${result.data!.length} exams');
      } else {
        _examsError.value = result.error?.messageUz ?? 'Imtihonlarni yuklab bo\'lmadi';
      }
    } catch (e) {
      _examsError.value = 'Kutilmagan xatolik yuz berdi';
      print('StudentController: Exams load error - $e');
    } finally {
      _isExamsLoading.value = false;
    }
  }

  /// Load grades data
  Future<void> loadGrades({bool forceRefresh = false}) async {
    _isGradesLoading.value = true;
    _gradesError.value = null;

    try {
      final result = await _studentRepository.getGrades(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _grades.value = result.data;
        print('StudentController: Grades loaded (${result.data!.totalGradesCount} total)');
      } else {
        _gradesError.value = result.error?.messageUz ?? 'Baholarni yuklab bo\'lmadi';
      }
    } catch (e) {
      _gradesError.value = 'Kutilmagan xatolik yuz berdi';
      print('StudentController: Grades load error - $e');
    } finally {
      _isGradesLoading.value = false;
    }
  }

  /// Load attendance data
  Future<void> loadAttendance() async {
    _isAttendanceLoading.value = true;
    _attendanceError.value = null;

    try {
      final result = await _studentRepository.getAttendance();

      if (result.isSuccess && result.data != null) {
        _attendance.value = result.data!;
        print('StudentController: Loaded ${result.data!.length} attendance records');
      } else {
        _attendanceError.value = result.error?.messageUz ?? 'Davomatni yuklab bo\'lmadi';
      }
    } catch (e) {
      _attendanceError.value = 'Kutilmagan xatolik yuz berdi';
      print('StudentController: Attendance load error - $e');
    } finally {
      _isAttendanceLoading.value = false;
    }
  }

  /// Load schedule data
  Future<void> loadSchedule({bool forceRefresh = false}) async {
    _isScheduleLoading.value = true;
    _scheduleError.value = null;

    try {
      final result = await _studentRepository.getSchedule(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _schedule.value = result.data!;
        print('StudentController: Loaded ${result.data!.length} schedule items');
      } else {
        _scheduleError.value = result.error?.messageUz ?? 'Dars jadvalni yuklab bo\'lmadi';
      }
    } catch (e) {
      _scheduleError.value = 'Kutilmagan xatolik yuz berdi';
      print('StudentController: Schedule load error - $e');
    } finally {
      _isScheduleLoading.value = false;
    }
  }

  /// Load payments data
  Future<void> loadPayments({bool forceRefresh = false}) async {
    _isPaymentsLoading.value = true;
    _paymentsError.value = null;

    try {
      final result = await _studentRepository.getPayments(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _payments.value = result.data;
        print('StudentController: Payments loaded');
      } else {
        _paymentsError.value = result.error?.messageUz ?? 'To\'lovlarni yuklab bo\'lmadi';
      }
    } catch (e) {
      _paymentsError.value = 'Kutilmagan xatolik yuz berdi';
      print('StudentController: Payments load error - $e');
    } finally {
      _isPaymentsLoading.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    _isRefreshing.value = true;

    try {
      await Future.wait([
        loadDashboard(forceRefresh: true),
        loadHomework(forceRefresh: true),
        loadExams(forceRefresh: true),
        loadGrades(forceRefresh: true),
        loadSchedule(forceRefresh: true),
        loadPayments(forceRefresh: true),
      ]);

      _showSuccessMessage('Ma\'lumotlar yangilandi');
      print('StudentController: All data refreshed');
    } catch (e) {
      _showErrorMessage('Ma\'lumotlarni yangilashda xatolik');
      print('StudentController: Refresh error - $e');
    } finally {
      _isRefreshing.value = false;
    }
  }

  // ===================== FILTERS & UI CONTROLS =====================

  /// Set homework filter
  void setHomeworkFilter(String filter) {
    _homeworkFilter.value = filter;
    print('StudentController: Homework filter set to $filter');
  }

  /// Set exam filter
  void setExamFilter(String filter) {
    _examFilter.value = filter;
    print('StudentController: Exam filter set to $filter');
  }

  /// Set schedule day
  void setScheduleDay(int day) {
    _scheduleDay.value = day;
    print('StudentController: Schedule day set to $day');
  }

  /// Toggle show completed homework
  void toggleShowCompletedHomework() {
    _showCompletedHomework.value = !_showCompletedHomework.value;
    print('StudentController: Show completed homework: ${_showCompletedHomework.value}');
  }

  /// Set selected tab index
  void setSelectedTabIndex(int index) {
    _selectedTabIndex.value = index;
  }

  // ===================== NAVIGATION HELPERS =====================

  /// Navigate to homework detail
  void openHomeworkDetail(HomeworkModel homework) {
    Get.toNamed('/student/homework/${homework.id}', arguments: homework);
  }

  /// Navigate to exam detail
  void openExamDetail(ExamModel exam) {
    Get.toNamed('/student/exam/${exam.id}', arguments: exam);
  }

  /// Navigate to grades page
  void openGrades() {
    Get.toNamed('/student/grades');
  }

  /// Navigate to attendance page
  void openAttendance() {
    Get.toNamed('/student/attendance');
  }

  /// Navigate to schedule page
  void openSchedule() {
    Get.toNamed('/student/schedule');
  }

  /// Navigate to payments page
  void openPayments() {
    Get.toNamed('/student/payments');
  }

  // ===================== QUICK ACTIONS =====================

  /// Get quick actions for dashboard
  List<Map<String, dynamic>> getQuickActions() {
    return [
      {
        'title': 'Vazifalar',
        'subtitle': '$pendingHomeworkCount ta kutilmoqda',
        'icon': Icons.assignment,
        'color': overdueHomeworkCount > 0 ? Colors.red : Colors.blue,
        'badge': overdueHomeworkCount > 0 ? overdueHomeworkCount.toString() : null,
        'onTap': () => Get.toNamed('/student/homework'),
      },
      {
        'title': 'Imtihonlar',
        'subtitle': '${upcomingExams.length} ta yaqinlashmoqda',
        'icon': Icons.quiz,
        'color': todaysExams.isNotEmpty ? Colors.orange : Colors.purple,
        'badge': todaysExams.isNotEmpty ? todaysExams.length.toString() : null,
        'onTap': () => Get.toNamed('/student/exams'),
      },
      {
        'title': 'Baholar',
        'subtitle': 'O\'rtacha: ${averageGrade.toStringAsFixed(1)}%',
        'icon': Icons.grade,
        'color': averageGrade >= 70 ? Colors.green : Colors.orange,
        'onTap': () => openGrades(),
      },
      {
        'title': 'Dars jadvali',
        'subtitle': currentClass?.displaySubject ?? 'Hozir dars yo\'q',
        'icon': Icons.schedule,
        'color': currentClass != null ? Colors.green : Colors.grey,
        'onTap': () => openSchedule(),
      },
    ];
  }

  /// Get urgent tasks for today
  List<Map<String, dynamic>> getUrgentTasks() {
    final tasks = <Map<String, dynamic>>[];

    // Overdue homework
    for (final homework in overdueHomework.take(3)) {
      tasks.add({
        'type': 'homework',
        'title': homework.title,
        'subtitle': 'Muddat: ${homework.daysUntilDue.abs()} kun kech',
        'priority': 'high',
        'onTap': () => openHomeworkDetail(homework),
      });
    }

    // Due today homework
    for (final homework in dueTodayHomework.take(2)) {
      tasks.add({
        'type': 'homework',
        'title': homework.title,
        'subtitle': 'Bugun topshirish kerak',
        'priority': 'medium',
        'onTap': () => openHomeworkDetail(homework),
      });
    }

    // Today's exams
    for (final exam in todaysExams) {
      tasks.add({
        'type': 'exam',
        'title': exam.title,
        'subtitle': 'Bugun ${exam.formattedExamTime}da',
        'priority': 'high',
        'onTap': () => openExamDetail(exam),
      });
    }

    // Sort by priority
    tasks.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      final aPriority = priorityOrder[a['priority']] ?? 0;
      final bPriority = priorityOrder[b['priority']] ?? 0;
      return bPriority.compareTo(aPriority);
    });

    return tasks.take(5).toList();
  }

  // ===================== UTILITY METHODS =====================

  /// Clear all errors
  void clearErrors() {
    _homeworkError.value = null;
    _examsError.value = null;
    _gradesError.value = null;
    _attendanceError.value = null;
    _scheduleError.value = null;
    _paymentsError.value = null;
  }

  /// Get study progress
  Map<String, dynamic> getStudyProgress() {
    final totalAssignments = _homework.length + _exams.length;
    final completedAssignments = _homework.where((h) => h.hasGrade).length +
        _exams.where((e) => e.hasGrade).length;

    return {
      'totalAssignments': totalAssignments,
      'completedAssignments': completedAssignments,
      'progressPercentage': totalAssignments > 0 ? (completedAssignments / totalAssignments * 100) : 0.0,
      'pendingAssignments': totalAssignments - completedAssignments,
    };
  }

  /// Get week summary
  Map<String, dynamic> getWeekSummary() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekHomework = _homework.where((h) =>
    h.dueDate.isAfter(weekStart) && h.dueDate.isBefore(weekEnd)).length;

    final weekExams = _exams.where((e) =>
    e.examDate.isAfter(weekStart) && e.examDate.isBefore(weekEnd)).length;

    return {
      'weekHomework': weekHomework,
      'weekExams': weekExams,
      'totalWeekEvents': weekHomework + weekExams,
      'weekStart': weekStart,
      'weekEnd': weekEnd,
    };
  }

  // ===================== MESSAGING =====================

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Muvaffaqiyat',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ===================== DEBUG =====================

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'homework_count': _homework.length,
      'exams_count': _exams.length,
      'grades_loaded': _grades.value != null,
      'attendance_count': _attendance.length,
      'schedule_count': _schedule.length,
      'payments_loaded': _payments.value != null,
      'loading_states': {
        'homework': isHomeworkLoading,
        'exams': isExamsLoading,
        'grades': isGradesLoading,
        'attendance': isAttendanceLoading,
        'schedule': isScheduleLoading,
        'payments': isPaymentsLoading,
      },
      'filters': {
        'homework_filter': homeworkFilter,
        'exam_filter': examFilter,
        'schedule_day': scheduleDay,
        'show_completed': showCompletedHomework,
      },
      'performance': performanceSummary,
      'repository_cache_info': _studentRepository.getCacheInfo(),
    };
  }
}