import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/homework_model.dart';
import '../models/exam_model.dart';
import '../models/teacher_models.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../models/auth_models.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class TeacherService extends GetxService {
  static TeacherService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // ===================== HOMEWORK MANAGEMENT =====================

  /// Create new homework assignment
  Future<ApiResult<CreateResponse>> createHomework({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    final request = HomeworkRequest(
      groupSubjectId: groupSubjectId,
      title: title,
      description: description,
      dueDate: dueDate,
      maxPoints: maxPoints,
      externalLinks: externalLinks,
    );

    final result = await _apiService.post<CreateResponse>(
      TeacherEndpoints.homework,
      data: request.toJson(),
      fromJson: (data) => CreateResponse.fromJson(data),
    );

    // Refresh cached homework if successful
    if (result.isSuccess) {
      await _refreshTeacherHomework();
    }

    return result;
  }

  /// Update existing homework
  Future<ApiResult<ApiResponse>> updateHomework({
    required int homeworkId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    final request = HomeworkRequest(
      groupSubjectId: groupSubjectId,
      title: title,
      description: description,
      dueDate: dueDate,
      maxPoints: maxPoints,
      externalLinks: externalLinks,
    );

    final result = await _apiService.put<ApiResponse>(
      TeacherEndpoints.homeworkById(homeworkId),
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Refresh cached homework if successful
    if (result.isSuccess) {
      await _refreshTeacherHomework();
    }

    return result;
  }

  /// Delete homework (if no grades exist)
  Future<ApiResult<ApiResponse>> deleteHomework(int homeworkId) async {
    final result = await _apiService.delete<ApiResponse>(
      TeacherEndpoints.homeworkById(homeworkId),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Refresh cached homework if successful
    if (result.isSuccess) {
      await _refreshTeacherHomework();
    }

    return result;
  }

  /// Get teacher's homework assignments
  Future<ApiResult<List<HomeworkModel>>> getMyHomework({
    bool useCache = true,
  }) async {
    // Try cache first if requested
    if (useCache) {
      final cachedHomework = getCachedTeacherHomework();
      if (cachedHomework.isNotEmpty) {
        // Return cached data and refresh in background
        _refreshTeacherHomeworkInBackground();
        return ApiResult.success(cachedHomework);
      }
    }

    return await _refreshTeacherHomework();
  }

  /// Refresh teacher homework from API
  Future<ApiResult<List<HomeworkModel>>> _refreshTeacherHomework() async {
    final result = await _apiService.get<List<HomeworkModel>>(
      TeacherEndpoints.homework,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => HomeworkModel.fromJson(item)).toList();
        }
        return <HomeworkModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheTeacherHomework(result.data!);
    }

    return result;
  }

  /// Refresh teacher homework in background
  Future<void> _refreshTeacherHomeworkInBackground() async {
    try {
      await _refreshTeacherHomework();
    } catch (e) {
      print('⚠️ Background teacher homework refresh failed: $e');
    }
  }

  /// Cache teacher homework locally
  Future<void> _cacheTeacherHomework(List<HomeworkModel> homework) async {
    final homeworkJson = homework.map((h) => h.toJson()).toList();
    await _storage.write(CacheKeys.teacherHomework, homeworkJson);
  }

  /// Get cached teacher homework
  List<HomeworkModel> getCachedTeacherHomework() {
    final cachedData = _storage.read<List>(CacheKeys.teacherHomework);
    if (cachedData != null) {
      return cachedData
          .map((item) => HomeworkModel.fromJson(item))
          .toList();
    }
    return [];
  }

  // ===================== EXAM MANAGEMENT =====================

  /// Create new exam
  Future<ApiResult<CreateResponse>> createExam({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    final request = ExamRequest(
      groupSubjectId: groupSubjectId,
      title: title,
      description: description,
      examDate: examDate,
      maxPoints: maxPoints,
      externalLinks: externalLinks,
    );

    final result = await _apiService.post<CreateResponse>(
      TeacherEndpoints.exams,
      data: request.toJson(),
      fromJson: (data) => CreateResponse.fromJson(data),
    );

    // Refresh cached exams if successful
    if (result.isSuccess) {
      await _refreshTeacherExams();
    }

    return result;
  }

  /// Update existing exam
  Future<ApiResult<ApiResponse>> updateExam({
    required int examId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    final request = ExamRequest(
      groupSubjectId: groupSubjectId,
      title: title,
      description: description,
      examDate: examDate,
      maxPoints: maxPoints,
      externalLinks: externalLinks,
    );

    final result = await _apiService.put<ApiResponse>(
      TeacherEndpoints.examById(examId),
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Refresh cached exams if successful
    if (result.isSuccess) {
      await _refreshTeacherExams();
    }

    return result;
  }

  /// Delete exam (if no grades exist)
  Future<ApiResult<ApiResponse>> deleteExam(int examId) async {
    final result = await _apiService.delete<ApiResponse>(
      TeacherEndpoints.examById(examId),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Refresh cached exams if successful
    if (result.isSuccess) {
      await _refreshTeacherExams();
    }

    return result;
  }

  /// Get teacher's exams
  Future<ApiResult<List<ExamModel>>> getMyExams({
    bool useCache = true,
  }) async {
    // Try cache first if requested
    if (useCache) {
      final cachedExams = getCachedTeacherExams();
      if (cachedExams.isNotEmpty) {
        // Return cached data and refresh in background
        _refreshTeacherExamsInBackground();
        return ApiResult.success(cachedExams);
      }
    }

    return await _refreshTeacherExams();
  }

  /// Refresh teacher exams from API
  Future<ApiResult<List<ExamModel>>> _refreshTeacherExams() async {
    final result = await _apiService.get<List<ExamModel>>(
      TeacherEndpoints.exams,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ExamModel.fromJson(item)).toList();
        }
        return <ExamModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheTeacherExams(result.data!);
    }

    return result;
  }

  /// Refresh teacher exams in background
  Future<void> _refreshTeacherExamsInBackground() async {
    try {
      await _refreshTeacherExams();
    } catch (e) {
      print('⚠️ Background teacher exams refresh failed: $e');
    }
  }

  /// Cache teacher exams locally
  Future<void> _cacheTeacherExams(List<ExamModel> exams) async {
    final examsJson = exams.map((e) => e.toJson()).toList();
    await _storage.write(CacheKeys.teacherExams, examsJson);
  }

  /// Get cached teacher exams
  List<ExamModel> getCachedTeacherExams() {
    final cachedData = _storage.read<List>(CacheKeys.teacherExams);
    if (cachedData != null) {
      return cachedData
          .map((item) => ExamModel.fromJson(item))
          .toList();
    }
    return [];
  }

  // ===================== GRADING =====================

  /// Get homework grading table
  Future<ApiResult<GradingTableModel>> getHomeworkGradingTable(int homeworkId) async {
    return await _apiService.get<GradingTableModel>(
      TeacherEndpoints.homeworkGradingTable(homeworkId),
      fromJson: (data) => GradingTableModel.fromJson(data),
    );
  }

  /// Get exam grading table
  Future<ApiResult<GradingTableModel>> getExamGradingTable(int examId) async {
    return await _apiService.get<GradingTableModel>(
      TeacherEndpoints.examGradingTable(examId),
      fromJson: (data) => GradingTableModel.fromJson(data),
    );
  }

  /// Submit bulk homework grades
  Future<ApiResult<ApiResponse>> submitHomeworkGrades({
    required int homeworkId,
    required List<GradeRequest> grades,
  }) async {
    final request = BulkHomeworkGradeRequest(
      homeworkId: homeworkId,
      grades: grades,
    );

    return await _apiService.post<ApiResponse>(
      TeacherEndpoints.bulkHomeworkGrades,
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  /// Submit bulk exam grades
  Future<ApiResult<ApiResponse>> submitExamGrades({
    required int examId,
    required List<GradeRequest> grades,
  }) async {
    final request = BulkExamGradeRequest(
      examId: examId,
      grades: grades,
    );

    return await _apiService.post<ApiResponse>(
      TeacherEndpoints.bulkExamGrades,
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  /// Submit single homework grade
  Future<ApiResult<ApiResponse>> submitSingleHomeworkGrade({
    required int homeworkId,
    required int studentId,
    required int points,
    String comment = '',
  }) async {
    final grades = [
      GradeRequest(
        studentId: studentId,
        points: points,
        comment: comment,
      ),
    ];

    return await submitHomeworkGrades(
      homeworkId: homeworkId,
      grades: grades,
    );
  }

  /// Submit single exam grade
  Future<ApiResult<ApiResponse>> submitSingleExamGrade({
    required int examId,
    required int studentId,
    required int points,
    String comment = '',
  }) async {
    final grades = [
      GradeRequest(
        studentId: studentId,
        points: points,
        comment: comment,
      ),
    ];

    return await submitExamGrades(
      examId: examId,
      grades: grades,
    );
  }

  // ===================== ATTENDANCE MANAGEMENT =====================

  /// Get attendance table for group-subject
  Future<ApiResult<AttendanceTableModel>> getAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      QueryParams.groupSubjectId: groupSubjectId.toString(),
    };

    if (startDate != null || endDate != null) {
      queryParams.addAll(ApiConstants.buildDateRangeParams(
        startDate: startDate,
        endDate: endDate,
      ));
    }

    return await _apiService.get<AttendanceTableModel>(
      TeacherEndpoints.attendanceTable,
      queryParameters: queryParams,
      fromJson: (data) => AttendanceTableModel.fromJson(data),
    );
  }

  /// Submit bulk attendance for a specific date
  Future<ApiResult<ApiResponse>> submitAttendance({
    required int groupSubjectId,
    required DateTime date,
    required List<AttendanceRecord> records,
  }) async {
    final request = BulkAttendanceRequest(
      groupSubjectId: groupSubjectId,
      date: date,
      records: records,
    );

    return await _apiService.post<ApiResponse>(
      TeacherEndpoints.bulkAttendance,
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  /// Submit single student attendance
  Future<ApiResult<ApiResponse>> submitSingleAttendance({
    required int groupSubjectId,
    required DateTime date,
    required int studentId,
    required String status,
  }) async {
    final records = [
      AttendanceRecord(
        studentId: studentId,
        status: status,
      ),
    ];

    return await submitAttendance(
      groupSubjectId: groupSubjectId,
      date: date,
      records: records,
    );
  }

  /// Mark all students present for a date
  Future<ApiResult<ApiResponse>> markAllPresent({
    required int groupSubjectId,
    required DateTime date,
    required List<int> studentIds,
  }) async {
    final records = studentIds.map((id) => AttendanceRecord(
      studentId: id,
      status: AttendanceStatus.present,
    )).toList();

    return await submitAttendance(
      groupSubjectId: groupSubjectId,
      date: date,
      records: records,
    );
  }

  // ===================== GROUP & STUDENT MANAGEMENT =====================

  /// Get students in a specific group
  Future<ApiResult<List<StudentModel>>> getGroupStudents(int groupId) async {
    return await _apiService.get<List<StudentModel>>(
      TeacherEndpoints.groupStudents(groupId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => StudentModel.fromJson(item)).toList();
        }
        return <StudentModel>[];
      },
    );
  }

  // ===================== ANALYTICS & INSIGHTS =====================

  /// Get homework completion statistics
  Future<Map<String, dynamic>> getHomeworkStats() async {
    final homework = getCachedTeacherHomework();
    if (homework.isEmpty) return {};

    final now = DateTime.now();
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    final stats = {
      'total': homework.length,
      'thisWeek': homework.where((h) => h.createdAt?.isAfter(thisWeek) == true).length,
      'thisMonth': homework.where((h) => h.createdAt?.isAfter(thisMonth) == true).length,
      'upcoming': homework.where((h) => h.dueDate.isAfter(now)).length,
      'overdue': homework.where((h) => h.isOverdue).length,
      'dueSoon': homework.where((h) => h.isDueToday || h.isDueTomorrow).length,
    };

    return stats;
  }

  /// Get exam scheduling statistics
  Future<Map<String, dynamic>> getExamStats() async {
    final exams = getCachedTeacherExams();
    if (exams.isEmpty) return {};

    final now = DateTime.now();
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final stats = {
      'total': exams.length,
      'thisWeek': exams.where((e) => e.createdAt?.isAfter(thisWeek) == true).length,
      'thisMonth': exams.where((e) => e.createdAt?.isAfter(thisMonth) == true).length,
      'upcoming': exams.where((e) => e.examDate.isAfter(now)).length,
      'nextMonth': exams.where((e) =>
      e.examDate.isAfter(now) && e.examDate.isBefore(nextMonth)).length,
      'today': exams.where((e) => e.isToday).length,
      'thisWeekExams': exams.where((e) =>
      e.examDate.isAfter(thisWeek) && e.examDate.isBefore(thisWeek.add(const Duration(days: 7)))).length,
    };

    return stats;
  }

  /// Get teacher workload summary
  Map<String, dynamic> getWorkloadSummary() {
    final homework = getCachedTeacherHomework();
    final exams = getCachedTeacherExams();
    final now = DateTime.now();

    // Get subjects taught
    final subjects = <String>{};
    subjects.addAll(homework.map((h) => h.displaySubject));
    subjects.addAll(exams.map((e) => e.displaySubject));

    // Get groups taught
    final groups = <String>{};
    groups.addAll(homework.map((h) => h.displayGroup));
    groups.addAll(exams.map((e) => e.displayGroup));

    // Get pending work
    final pendingHomework = homework.where((h) =>
    h.dueDate.isAfter(now) && h.daysUntilDue <= 7).length;
    final upcomingExams = exams.where((e) =>
    e.examDate.isAfter(now) && e.daysUntilExam <= 7).length;

    return {
      'totalSubjects': subjects.length,
      'totalGroups': groups.length,
      'totalHomework': homework.length,
      'totalExams': exams.length,
      'pendingHomework': pendingHomework,
      'upcomingExams': upcomingExams,
      'workloadLevel': _calculateWorkloadLevel(pendingHomework + upcomingExams),
      'subjects': subjects.toList(),
      'groups': groups.toList(),
    };
  }

  /// Calculate workload level
  String _calculateWorkloadLevel(int totalPending) {
    if (totalPending >= 10) return 'Yuqori';
    if (totalPending >= 5) return 'O\'rta';
    if (totalPending >= 2) return 'Past';
    return 'Engil';
  }

  // ===================== UTILITY METHODS =====================

  /// Refresh all teacher data
  Future<void> refreshAllData() async {
    try {
      await Future.wait([
        getMyHomework(useCache: false),
        getMyExams(useCache: false),
      ]);
      print('✅ All teacher data refreshed');
    } catch (e) {
      print('❌ Error refreshing teacher data: $e');
    }
  }

  /// Clear all cached teacher data
  Future<void> clearCache() async {
    await _storage.remove(CacheKeys.teacherHomework);
    await _storage.remove(CacheKeys.teacherExams);
    print('🗑️ Teacher cache cleared');
  }

  /// Get today's urgent tasks
  List<dynamic> getTodaysUrgentTasks() {
    final homework = getCachedTeacherHomework();
    final exams = getCachedTeacherExams();
    final urgentTasks = <dynamic>[];

    // Homework due today or tomorrow
    urgentTasks.addAll(homework.where((h) => h.isDueToday || h.isDueTomorrow));

    // Exams today or tomorrow
    urgentTasks.addAll(exams.where((e) => e.isToday || e.isTomorrow));

    // Sort by urgency
    urgentTasks.sort((a, b) {
      final aUrgency = a is HomeworkModel ? a.priorityLevel : (a as ExamModel).priorityLevel;
      final bUrgency = b is HomeworkModel ? b.priorityLevel : (b as ExamModel).priorityLevel;
      return bUrgency.compareTo(aUrgency);
    });

    return urgentTasks;
  }

  /// Check if teacher has urgent tasks
  bool hasUrgentTasks() => getTodaysUrgentTasks().isNotEmpty;

  /// Get quick actions for teacher dashboard
  List<Map<String, dynamic>> getQuickActions() {
    final urgentCount = getTodaysUrgentTasks().length;
    final workload = getWorkloadSummary();

    return [
      {
        'title': 'Yangi vazifa yaratish',
        'icon': '📝',
        'color': '#2196F3',
        'action': 'create_homework',
      },
      {
        'title': 'Yangi imtihon rejalashtirish',
        'icon': '📋',
        'color': '#9C27B0',
        'action': 'create_exam',
      },
      {
        'title': 'Baholarni kiritish',
        'icon': '🎯',
        'color': '#4CAF50',
        'action': 'grade_assignments',
        'badge': urgentCount > 0 ? urgentCount.toString() : null,
      },
      {
        'title': 'Davomatni belgilash',
        'icon': '📅',
        'color': '#00BCD4',
        'action': 'mark_attendance',
      },
      {
        'title': 'Talabalarni ko\'rish',
        'icon': '👥',
        'color': '#FF9800',
        'action': 'view_students',
        'badge': workload['totalGroups'].toString(),
      },
    ];
  }
}