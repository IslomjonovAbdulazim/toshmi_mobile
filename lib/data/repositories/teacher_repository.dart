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
import '../services/api_service.dart';

class TeacherRepository extends GetxService {
  static TeacherRepository get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Cache duration constants
  static const Duration _homeworkCacheDuration = Duration(hours: 6);
  static const Duration _examsCacheDuration = Duration(hours: 12);
  static const Duration _studentsCacheDuration = Duration(hours: 24);

  // Cache keys
  static const String _homeworkCacheKey = '${CacheKeys.teacherHomework}_data';
  static const String _examsCacheKey = '${CacheKeys.teacherExams}_data';
  static const String _studentsCacheKey = 'teacher_students_data';

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

    // Invalidate homework cache if successful
    if (result.isSuccess) {
      await _invalidateHomeworkCache();
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

    // Invalidate homework cache if successful
    if (result.isSuccess) {
      await _invalidateHomeworkCache();
    }

    return result;
  }

  /// Delete homework (if no grades exist)
  Future<ApiResult<ApiResponse>> deleteHomework(int homeworkId) async {
    final result = await _apiService.delete<ApiResponse>(
      TeacherEndpoints.homeworkById(homeworkId),
      fromJson: (data) => ApiResponse.fromJson(data ?? {'message': 'Vazifa o\'chirildi'}),
    );

    // Invalidate homework cache if successful
    if (result.isSuccess) {
      await _invalidateHomeworkCache();
    }

    return result;
  }

  /// Get teacher's homework assignments
  Future<ApiResult<List<HomeworkModel>>> getMyHomework({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedHomework = _getCachedTeacherHomework();
      if (cachedHomework.isNotEmpty && _isHomeworkCacheValid()) {
        print('TeacherRepository: Using cached homework (${cachedHomework.length})');
        // Refresh in background
        _refreshHomeworkInBackground();
        return ApiResult.success(cachedHomework);
      }
    }

    // Fetch from API
    return await _fetchHomeworkFromApi();
  }

  /// Fetch homework from API
  Future<ApiResult<List<HomeworkModel>>> _fetchHomeworkFromApi() async {
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

  /// Refresh homework in background
  Future<void> _refreshHomeworkInBackground() async {
    try {
      await _fetchHomeworkFromApi();
    } catch (e) {
      print('⚠️ TeacherRepository: Background homework refresh failed - $e');
    }
  }

  /// Cache teacher homework
  Future<void> _cacheTeacherHomework(List<HomeworkModel> homework) async {
    final cacheData = {
      'data': homework.map((h) => h.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_homeworkCacheKey, cacheData);
    print('TeacherRepository: Cached ${homework.length} homework assignments');
  }

  /// Get cached teacher homework
  List<HomeworkModel> _getCachedTeacherHomework() {
    final cachedData = _storage.read<Map<String, dynamic>>(_homeworkCacheKey);
    if (cachedData?['data'] != null) {
      try {
        final homeworkJson = cachedData!['data'] as List;
        return homeworkJson
            .map((item) => HomeworkModel.fromJson(item))
            .toList();
      } catch (e) {
        print('TeacherRepository: Error reading cached homework - $e');
        _storage.remove(_homeworkCacheKey);
      }
    }
    return [];
  }

  /// Check if homework cache is valid
  bool _isHomeworkCacheValid() {
    return _isCacheValid(_homeworkCacheKey, _homeworkCacheDuration);
  }

  /// Invalidate homework cache
  Future<void> _invalidateHomeworkCache() async {
    await _storage.remove(_homeworkCacheKey);
    print('TeacherRepository: Homework cache invalidated');
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

    // Invalidate exams cache if successful
    if (result.isSuccess) {
      await _invalidateExamsCache();
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

    // Invalidate exams cache if successful
    if (result.isSuccess) {
      await _invalidateExamsCache();
    }

    return result;
  }

  /// Delete exam (if no grades exist)
  Future<ApiResult<ApiResponse>> deleteExam(int examId) async {
    final result = await _apiService.delete<ApiResponse>(
      TeacherEndpoints.examById(examId),
      fromJson: (data) => ApiResponse.fromJson(data ?? {'message': 'Imtihon o\'chirildi'}),
    );

    // Invalidate exams cache if successful
    if (result.isSuccess) {
      await _invalidateExamsCache();
    }

    return result;
  }

  /// Get teacher's exams
  Future<ApiResult<List<ExamModel>>> getMyExams({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedExams = _getCachedTeacherExams();
      if (cachedExams.isNotEmpty && _isExamsCacheValid()) {
        print('TeacherRepository: Using cached exams (${cachedExams.length})');
        // Refresh in background
        _refreshExamsInBackground();
        return ApiResult.success(cachedExams);
      }
    }

    // Fetch from API
    return await _fetchExamsFromApi();
  }

  /// Fetch exams from API
  Future<ApiResult<List<ExamModel>>> _fetchExamsFromApi() async {
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

  /// Refresh exams in background
  Future<void> _refreshExamsInBackground() async {
    try {
      await _fetchExamsFromApi();
    } catch (e) {
      print('⚠️ TeacherRepository: Background exams refresh failed - $e');
    }
  }

  /// Cache teacher exams
  Future<void> _cacheTeacherExams(List<ExamModel> exams) async {
    final cacheData = {
      'data': exams.map((e) => e.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_examsCacheKey, cacheData);
    print('TeacherRepository: Cached ${exams.length} exams');
  }

  /// Get cached teacher exams
  List<ExamModel> _getCachedTeacherExams() {
    final cachedData = _storage.read<Map<String, dynamic>>(_examsCacheKey);
    if (cachedData?['data'] != null) {
      try {
        final examsJson = cachedData!['data'] as List;
        return examsJson
            .map((item) => ExamModel.fromJson(item))
            .toList();
      } catch (e) {
        print('TeacherRepository: Error reading cached exams - $e');
        _storage.remove(_examsCacheKey);
      }
    }
    return [];
  }

  /// Check if exams cache is valid
  bool _isExamsCacheValid() {
    return _isCacheValid(_examsCacheKey, _examsCacheDuration);
  }

  /// Invalidate exams cache
  Future<void> _invalidateExamsCache() async {
    await _storage.remove(_examsCacheKey);
    print('TeacherRepository: Exams cache invalidated');
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

    final result = await _apiService.post<ApiResponse>(
      TeacherEndpoints.bulkHomeworkGrades,
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Invalidate homework cache if successful (grades affect homework data)
    if (result.isSuccess) {
      await _invalidateHomeworkCache();
    }

    return result;
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

    final result = await _apiService.post<ApiResponse>(
      TeacherEndpoints.bulkExamGrades,
      data: request.toJson(),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    // Invalidate exams cache if successful (grades affect exam data)
    if (result.isSuccess) {
      await _invalidateExamsCache();
    }

    return result;
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
  Future<ApiResult<List<StudentModel>>> getGroupStudents(
      int groupId, {
        bool useCache = true,
        bool forceRefresh = false,
      }) async {
    final cacheKey = '${_studentsCacheKey}_$groupId';

    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedStudents = _getCachedGroupStudents(groupId);
      if (cachedStudents.isNotEmpty && _isCacheValid(cacheKey, _studentsCacheDuration)) {
        print('TeacherRepository: Using cached students for group $groupId (${cachedStudents.length})');
        return ApiResult.success(cachedStudents);
      }
    }

    // Fetch from API
    final result = await _apiService.get<List<StudentModel>>(
      TeacherEndpoints.groupStudents(groupId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => StudentModel.fromJson(item)).toList();
        }
        return <StudentModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheGroupStudents(groupId, result.data!);
    }

    return result;
  }

  /// Cache group students
  Future<void> _cacheGroupStudents(int groupId, List<StudentModel> students) async {
    final cacheKey = '${_studentsCacheKey}_$groupId';
    final cacheData = {
      'data': students.map((s) => s.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(cacheKey, cacheData);
    print('TeacherRepository: Cached ${students.length} students for group $groupId');
  }

  /// Get cached group students
  List<StudentModel> _getCachedGroupStudents(int groupId) {
    final cacheKey = '${_studentsCacheKey}_$groupId';
    final cachedData = _storage.read<Map<String, dynamic>>(cacheKey);
    if (cachedData?['data'] != null) {
      try {
        final studentsJson = cachedData!['data'] as List;
        return studentsJson
            .map((item) => StudentModel.fromJson(item))
            .toList();
      } catch (e) {
        print('TeacherRepository: Error reading cached students - $e');
        _storage.remove(cacheKey);
      }
    }
    return [];
  }

  // ===================== CACHE UTILITIES =====================

  /// Generic cache validity checker
  bool _isCacheValid(String cacheKey, Duration duration) {
    final cachedData = _storage.read<Map<String, dynamic>>(cacheKey);
    if (cachedData?['cached_at'] != null) {
      try {
        final cachedAt = DateTime.parse(cachedData!['cached_at']);
        final now = DateTime.now();
        return now.difference(cachedAt) < duration;
      } catch (e) {
        print('TeacherRepository: Error checking cache validity for $cacheKey - $e');
        _storage.remove(cacheKey);
      }
    }
    return false;
  }

  /// Get all cached data (for quick access)
  Map<String, dynamic> getAllCachedData() {
    return {
      'homework': _getCachedTeacherHomework(),
      'exams': _getCachedTeacherExams(),
    };
  }

  /// Refresh all teacher data
  Future<void> refreshAllData() async {
    try {
      await Future.wait([
        getMyHomework(forceRefresh: true),
        getMyExams(forceRefresh: true),
      ]);
      print('✅ TeacherRepository: All data refreshed');
    } catch (e) {
      print('❌ TeacherRepository: Error refreshing all data - $e');
    }
  }

  /// Clear all cached teacher data
  Future<void> clearAllCache() async {
    // Get all cache keys that might exist
    final cacheKeys = [
      _homeworkCacheKey,
      _examsCacheKey,
    ];

    // Add group students cache keys (we can't know all group IDs, so clear what we can find)
    final allKeys = _storage.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_studentsCacheKey)) {
        cacheKeys.add(key);
      }
    }

    await Future.wait(cacheKeys.map((key) => _storage.remove(key)));
    print('🗑️ TeacherRepository: All cache cleared');
  }

  /// Invalidate specific cache
  Future<void> invalidateCache(String cacheType, {int? groupId}) async {
    switch (cacheType.toLowerCase()) {
      case 'homework':
        await _invalidateHomeworkCache();
        break;
      case 'exams':
        await _invalidateExamsCache();
        break;
      case 'students':
        if (groupId != null) {
          await _storage.remove('${_studentsCacheKey}_$groupId');
        } else {
          // Clear all student caches
          final allKeys = _storage.getKeys();
          final studentCacheKeys = allKeys.where((key) => key.startsWith(_studentsCacheKey));
          await Future.wait(studentCacheKeys.map((key) => _storage.remove(key)));
        }
        break;
      default:
        print('TeacherRepository: Unknown cache type: $cacheType');
    }
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'homework': {
        'cached_count': _getCachedTeacherHomework().length,
        'cache_valid': _isHomeworkCacheValid(),
      },
      'exams': {
        'cached_count': _getCachedTeacherExams().length,
        'cache_valid': _isExamsCacheValid(),
      },
      'students_cache_keys': _storage.getKeys()
          .where((key) => key.startsWith(_studentsCacheKey))
          .toList(),
    };
  }
}