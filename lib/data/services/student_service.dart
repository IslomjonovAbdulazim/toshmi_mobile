import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/homework_model.dart';
import '../models/exam_model.dart';
import '../models/grade_model.dart';
import '../models/attendance_model.dart';
import '../models/schedule_model.dart';
import '../models/payment_model.dart';
import '../models/dashboard_models.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class StudentService extends GetxService {
  static StudentService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // ===================== HOMEWORK =====================

  /// Get student's homework assignments
  Future<ApiResult<List<HomeworkModel>>> getHomework({
    bool useCache = true,
  }) async {
    // Try cache first if requested
    if (useCache) {
      final cachedHomework = getCachedHomework();
      if (cachedHomework.isNotEmpty) {
        // Return cached data and refresh in background
        _refreshHomeworkInBackground();
        return ApiResult.success(cachedHomework);
      }
    }

    final result = await _apiService.get<List<HomeworkModel>>(
      StudentEndpoints.homework,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => HomeworkModel.fromJson(item)).toList();
        }
        return <HomeworkModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheHomework(result.data!);
    }

    return result;
  }

  /// Refresh homework in background
  Future<void> _refreshHomeworkInBackground() async {
    try {
      final result = await _apiService.get<List<HomeworkModel>>(
        StudentEndpoints.homework,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => HomeworkModel.fromJson(item)).toList();
          }
          return <HomeworkModel>[];
        },
      );

      if (result.isSuccess && result.data != null) {
        await _cacheHomework(result.data!);
      }
    } catch (e) {
      print('⚠️ Background homework refresh failed: $e');
    }
  }

  /// Cache homework locally
  Future<void> _cacheHomework(List<HomeworkModel> homework) async {
    final homeworkJson = homework.map((h) => h.toJson()).toList();
    await _storage.write(CacheKeys.studentHomework, homeworkJson);
  }

  /// Get cached homework
  List<HomeworkModel> getCachedHomework() {
    final cachedData = _storage.read<List>(CacheKeys.studentHomework);
    if (cachedData != null) {
      return cachedData
          .map((item) => HomeworkModel.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Get upcoming homework (due within next 7 days)
  List<HomeworkModel> getUpcomingHomework() {
    final allHomework = getCachedHomework();
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return allHomework
        .where((h) => h.dueDate.isAfter(now) && h.dueDate.isBefore(weekFromNow))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Get overdue homework
  List<HomeworkModel> getOverdueHomework() {
    final allHomework = getCachedHomework();
    return allHomework
        .where((h) => h.isOverdue && !h.hasGrade)
        .toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }

  // ===================== EXAMS =====================

  /// Get student's exams
  Future<ApiResult<List<ExamModel>>> getExams({
    bool useCache = true,
  }) async {
    // Try cache first if requested
    if (useCache) {
      final cachedExams = getCachedExams();
      if (cachedExams.isNotEmpty) {
        // Return cached data and refresh in background
        _refreshExamsInBackground();
        return ApiResult.success(cachedExams);
      }
    }

    final result = await _apiService.get<List<ExamModel>>(
      StudentEndpoints.exams,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ExamModel.fromJson(item)).toList();
        }
        return <ExamModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheExams(result.data!);
    }

    return result;
  }

  /// Refresh exams in background
  Future<void> _refreshExamsInBackground() async {
    try {
      final result = await _apiService.get<List<ExamModel>>(
        StudentEndpoints.exams,
        fromJson: (data) {
          if (data is List) {
            return data.map((item) => ExamModel.fromJson(item)).toList();
          }
          return <ExamModel>[];
        },
      );

      if (result.isSuccess && result.data != null) {
        await _cacheExams(result.data!);
      }
    } catch (e) {
      print('⚠️ Background exams refresh failed: $e');
    }
  }

  /// Cache exams locally
  Future<void> _cacheExams(List<ExamModel> exams) async {
    final examsJson = exams.map((e) => e.toJson()).toList();
    await _storage.write(CacheKeys.studentExams, examsJson);
  }

  /// Get cached exams
  List<ExamModel> getCachedExams() {
    final cachedData = _storage.read<List>(CacheKeys.studentExams);
    if (cachedData != null) {
      return cachedData
          .map((item) => ExamModel.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Get upcoming exams (within next 30 days)
  List<ExamModel> getUpcomingExams() {
    final allExams = getCachedExams();
    final now = DateTime.now();
    final monthFromNow = now.add(const Duration(days: 30));

    return allExams
        .where((e) => e.examDate.isAfter(now) && e.examDate.isBefore(monthFromNow))
        .toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  /// Get today's exams
  List<ExamModel> getTodaysExams() {
    final allExams = getCachedExams();
    return allExams.where((e) => e.isToday).toList();
  }

  // ===================== GRADES =====================

  /// Get student's grades
  Future<ApiResult<GradesResponseModel>> getGrades({
    bool useCache = true,
  }) async {
    // Try cache first if requested
    if (useCache) {
      final cachedGrades = getCachedGrades();
      if (cachedGrades != null) {
        // Return cached data and refresh in background
        _refreshGradesInBackground();
        return ApiResult.success(cachedGrades);
      }
    }

    final result = await _apiService.get<GradesResponseModel>(
      StudentEndpoints.grades,
      fromJson: (data) => GradesResponseModel.fromJson(data),
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheGrades(result.data!);
    }

    return result;
  }

  /// Refresh grades in background
  Future<void> _refreshGradesInBackground() async {
    try {
      final result = await _apiService.get<GradesResponseModel>(
        StudentEndpoints.grades,
        fromJson: (data) => GradesResponseModel.fromJson(data),
      );

      if (result.isSuccess && result.data != null) {
        await _cacheGrades(result.data!);
      }
    } catch (e) {
      print('⚠️ Background grades refresh failed: $e');
    }
  }

  /// Cache grades locally
  Future<void> _cacheGrades(GradesResponseModel grades) async {
    await _storage.write(CacheKeys.studentGrades, grades.toJson());
  }

  /// Get cached grades
  GradesResponseModel? getCachedGrades() {
    final cachedData = _storage.read<Map<String, dynamic>>(CacheKeys.studentGrades);
    if (cachedData != null) {
      return GradesResponseModel.fromJson(cachedData);
    }
    return null;
  }

  /// Get recent grades (last 10)
  List<dynamic> getRecentGrades() {
    final grades = getCachedGrades();
    if (grades == null) return [];

    final allGrades = <dynamic>[];
    allGrades.addAll(grades.homeworkGrades);
    allGrades.addAll(grades.examGrades);

    // Sort by graded date
    allGrades.sort((a, b) {
      final aDate = a.gradedAt as DateTime?;
      final bDate = b.gradedAt as DateTime?;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return allGrades.take(10).toList();
  }

  // ===================== ATTENDANCE =====================

  /// Get student's attendance records
  Future<ApiResult<List<AttendanceModel>>> getAttendance() async {
    return await _apiService.get<List<AttendanceModel>>(
      StudentEndpoints.attendance,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => AttendanceModel.fromJson(item)).toList();
        }
        return <AttendanceModel>[];
      },
    );
  }

  /// Get attendance statistics
  Future<AttendanceStats> calculateAttendanceStats(List<AttendanceModel> attendance) async {
    final stats = {
      'present': 0,
      'absent': 0,
      'late': 0,
      'excused': 0,
    };

    for (final record in attendance) {
      if (stats.containsKey(record.status)) {
        stats[record.status] = stats[record.status]! + 1;
      }
    }

    return AttendanceStats(
      present: stats['present']!,
      absent: stats['absent']!,
      late: stats['late']!,
      excused: stats['excused']!,
      totalDays: attendance.length,
    );
  }

  // ===================== SCHEDULE =====================

  /// Get student's class schedule
  Future<ApiResult<List<ScheduleModel>>> getSchedule() async {
    return await _apiService.get<List<ScheduleModel>>(
      StudentEndpoints.schedule,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ScheduleModel.fromJson(item)).toList();
        }
        return <ScheduleModel>[];
      },
    );
  }

  /// Get today's schedule
  Future<List<ScheduleModel>> getTodaysSchedule() async {
    final result = await getSchedule();
    if (result.isSuccess && result.data != null) {
      return result.data!.where((s) => s.isToday).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return [];
  }

  /// Get current class (if any)
  Future<ScheduleModel?> getCurrentClass() async {
    final todaysSchedule = await getTodaysSchedule();
    return todaysSchedule.where((s) => s.isCurrentlyActive).firstOrNull;
  }

  /// Get next class today
  Future<ScheduleModel?> getNextClass() async {
    final todaysSchedule = await getTodaysSchedule();
    return todaysSchedule.where((s) => s.isUpcomingToday).firstOrNull;
  }

  // ===================== PAYMENTS =====================

  /// Get student's payment records
  Future<ApiResult<PaymentsResponseModel>> getPayments() async {
    return await _apiService.get<PaymentsResponseModel>(
      StudentEndpoints.payments,
      fromJson: (data) => PaymentsResponseModel.fromJson(data),
    );
  }

  /// Get payment summary
  Future<Map<String, dynamic>> getPaymentSummary() async {
    final result = await getPayments();
    if (result.isSuccess && result.data != null) {
      final payments = result.data!;
      return {
        'totalPaid': payments.totalPaidAmount,
        'formattedTotal': payments.formattedTotal,
        'pendingCount': payments.pendingPaymentsCount,
        'completedCount': payments.completedPaymentsCount,
        'overdueCount': payments.overduePaymentsCount,
        'recentPayments': payments.recentPayments,
      };
    }
    return {};
  }

  // ===================== DASHBOARD =====================

  /// Get student dashboard data
  Future<ApiResult<StudentDashboardModel>> getDashboard({
    bool useCache = true,
  }) async {
    final result = await _apiService.get<StudentDashboardModel>(
      StudentEndpoints.dashboard,
      fromJson: (data) => StudentDashboardModel.fromJson(data),
    );

    // Update individual caches based on dashboard data
    if (result.isSuccess && result.data != null) {
      await _updateCachesFromDashboard(result.data!);
    }

    return result;
  }

  /// Update individual caches from dashboard data
  Future<void> _updateCachesFromDashboard(StudentDashboardModel dashboard) async {
    // Convert dashboard homework to full homework models (basic info only)
    final homework = dashboard.upcomingHomework.map((h) => HomeworkModel(
      id: h.id,
      title: h.title,
      description: '',
      dueDate: h.dueDate,
      maxPoints: 100,
      externalLinks: [],
      documentIds: [],
      subject: h.subject,
    )).toList();

    // Convert dashboard exams to full exam models (basic info only)
    final exams = dashboard.upcomingExams.map((e) => ExamModel(
      id: e.id,
      title: e.title,
      description: '',
      examDate: e.examDate,
      maxPoints: 100,
      externalLinks: [],
      documentIds: [],
      subject: e.subject,
    )).toList();

    // Only cache if we don't have existing cached data (to avoid overriding detailed data)
    if (getCachedHomework().isEmpty) {
      await _cacheHomework(homework);
    }
    if (getCachedExams().isEmpty) {
      await _cacheExams(exams);
    }
  }

  // ===================== UTILITY METHODS =====================

  /// Refresh all student data
  Future<void> refreshAllData() async {
    try {
      await Future.wait([
        getHomework(useCache: false),
        getExams(useCache: false),
        getGrades(useCache: false),
        getDashboard(useCache: false),
      ]);
      print('✅ All student data refreshed');
    } catch (e) {
      print('❌ Error refreshing student data: $e');
    }
  }

  /// Clear all cached student data
  Future<void> clearCache() async {
    await _storage.remove(CacheKeys.studentHomework);
    await _storage.remove(CacheKeys.studentExams);
    await _storage.remove(CacheKeys.studentGrades);
    print('🗑️ Student cache cleared');
  }

  /// Get academic performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final grades = getCachedGrades();
    final homework = getCachedHomework();
    final exams = getCachedExams();

    if (grades == null) {
      return {
        'averageGrade': 0.0,
        'totalAssignments': homework.length + exams.length,
        'completedAssignments': 0,
        'pendingAssignments': homework.length + exams.length,
        'performanceStatus': 'Ma\'lumot yo\'q',
      };
    }

    final totalAssignments = homework.length + exams.length;
    final completedAssignments = grades.gradedCount;
    final pendingAssignments = totalAssignments - completedAssignments;

    return {
      'averageGrade': grades.averageGrade,
      'totalAssignments': totalAssignments,
      'completedAssignments': completedAssignments,
      'pendingAssignments': pendingAssignments,
      'performanceStatus': grades.averageGradeStatus,
      'homeworkCount': homework.length,
      'examCount': exams.length,
      'gradedHomework': grades.homeworkGrades.length,
      'gradedExams': grades.examGrades.length,
    };
  }

  /// Get urgent items count (overdue homework + today's exams)
  int getUrgentItemsCount() {
    final overdueHomework = getOverdueHomework().length;
    final todaysExams = getCachedExams().where((e) => e.isToday).length;
    return overdueHomework + todaysExams;
  }

  /// Check if student has any urgent items
  bool hasUrgentItems() => getUrgentItemsCount() > 0;
}