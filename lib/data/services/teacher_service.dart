import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response_models.dart';
import '../models/auth_models.dart';
import 'api_service.dart';

class TeacherService extends GetxService {
  static TeacherService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // ===================== HOMEWORK MANAGEMENT =====================

  /// Get teacher's homework assignments
  Future<ApiResult<List<Map<String, dynamic>>>> getHomework({
    int skip = 0,
    int limit = 20,
    bool useCache = true,
  }) async {
    if (useCache) {
      final cached = _getCachedHomework();
      if (cached.isNotEmpty) {
        _refreshHomeworkInBackground();
        return ApiResult.success(cached);
      }
    }

    return await _refreshHomework(skip: skip, limit: limit);
  }

  /// Create new homework
  Future<ApiResult<CreateResponse>> createHomework({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    final data = {
      'group_subject_id': groupSubjectId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'max_points': maxPoints,
      'external_links': externalLinks,
    };

    final result = await _apiService.post<CreateResponse>(
      TeacherEndpoints.homework,
      data: data,
      fromJson: (data) => CreateResponse.fromJson(data),
    );

    if (result.isSuccess) {
      await _refreshHomework();
    }

    return result;
  }

  /// Update homework
  Future<ApiResult<ApiResponse>> updateHomework({
    required int homeworkId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
  }) async {
    final data = {
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'max_points': maxPoints,
    };

    final result = await _apiService.put<ApiResponse>(
      TeacherEndpoints.homeworkById(homeworkId),
      data: data,
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    if (result.isSuccess) {
      await _refreshHomework();
    }

    return result;
  }

  /// Delete homework
  Future<ApiResult<ApiResponse>> deleteHomework(int homeworkId) async {
    final result = await _apiService.delete<ApiResponse>(
      TeacherEndpoints.homeworkById(homeworkId),
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    if (result.isSuccess) {
      await _refreshHomework();
    }

    return result;
  }

  // ===================== EXAM MANAGEMENT =====================

  /// Get teacher's exams
  Future<ApiResult<List<Map<String, dynamic>>>> getExams({
    int skip = 0,
    int limit = 20,
    bool useCache = true,
  }) async {
    if (useCache) {
      final cached = _getCachedExams();
      if (cached.isNotEmpty) {
        _refreshExamsInBackground();
        return ApiResult.success(cached);
      }
    }

    return await _refreshExams(skip: skip, limit: limit);
  }

  /// Create new exam
  Future<ApiResult<CreateResponse>> createExam({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    required int duration,
    required int maxPoints,
  }) async {
    final data = {
      'group_subject_id': groupSubjectId,
      'title': title,
      'description': description,
      'exam_date': examDate.toIso8601String(),
      'duration': duration,
      'max_points': maxPoints,
    };

    final result = await _apiService.post<CreateResponse>(
      TeacherEndpoints.exams,
      data: data,
      fromJson: (data) => CreateResponse.fromJson(data),
    );

    if (result.isSuccess) {
      await _refreshExams();
    }

    return result;
  }

  // ===================== GRADING =====================

  /// Submit homework grades
  Future<ApiResult<ApiResponse>> submitHomeworkGrades({
    required int homeworkId,
    required List<Map<String, dynamic>> grades,
  }) async {
    final data = {
      'homework_id': homeworkId,
      'grades': grades,
    };

    return await _apiService.post<ApiResponse>(
      '${TeacherEndpoints.homework}/$homeworkId/grades',
      data: data,
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  /// Submit exam grades
  Future<ApiResult<ApiResponse>> submitExamGrades({
    required int examId,
    required List<Map<String, dynamic>> grades,
  }) async {
    final data = {
      'exam_id': examId,
      'grades': grades,
    };

    return await _apiService.post<ApiResponse>(
      '${TeacherEndpoints.exams}/$examId/grades',
      data: data,
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  // ===================== ATTENDANCE =====================

  /// Get attendance table
  Future<ApiResult<Map<String, dynamic>>> getAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = {
      'group_subject_id': groupSubjectId.toString(),
      if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
    };

    return await _apiService.get<Map<String, dynamic>>(
      TeacherEndpoints.attendance,
      queryParameters: queryParams,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Submit attendance
  Future<ApiResult<ApiResponse>> submitAttendance({
    required int groupSubjectId,
    required DateTime date,
    required List<Map<String, dynamic>> records,
  }) async {
    final data = {
      'group_subject_id': groupSubjectId,
      'date': date.toIso8601String().split('T')[0],
      'records': records,
    };

    return await _apiService.post<ApiResponse>(
      TeacherEndpoints.attendance,
      data: data,
      fromJson: (data) => ApiResponse.fromJson(data),
    );
  }

  // ===================== GROUP MANAGEMENT =====================

  /// Get teacher's groups
  Future<ApiResult<List<Map<String, dynamic>>>> getGroups() async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      TeacherEndpoints.groups,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Get group students
  Future<ApiResult<List<Map<String, dynamic>>>> getGroupStudents(int groupId) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      TeacherEndpoints.groupStudents(groupId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  // ===================== ANALYTICS =====================

  /// Get homework statistics
  Map<String, dynamic> getHomeworkStats() {
    final homework = _getCachedHomework();
    if (homework.isEmpty) return {};

    final now = DateTime.now();
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));

    return {
      'total': homework.length,
      'thisWeek': homework.where((h) {
        final createdAt = DateTime.tryParse(h['created_at']?.toString() ?? '');
        return createdAt?.isAfter(thisWeek) == true;
      }).length,
      'upcoming': homework.where((h) {
        final dueDate = DateTime.tryParse(h['due_date']?.toString() ?? '');
        return dueDate?.isAfter(now) == true;
      }).length,
    };
  }

  // ===================== PRIVATE METHODS =====================

  Future<ApiResult<List<Map<String, dynamic>>>> _refreshHomework({
    int skip = 0,
    int limit = 20,
  }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      TeacherEndpoints.homework,
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheHomework(result.data!);
    }

    return result;
  }

  Future<ApiResult<List<Map<String, dynamic>>>> _refreshExams({
    int skip = 0,
    int limit = 20,
  }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      TeacherEndpoints.exams,
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheExams(result.data!);
    }

    return result;
  }

  void _refreshHomeworkInBackground() async {
    try {
      await _refreshHomework();
    } catch (e) {
      print('Background homework refresh failed: $e');
    }
  }

  void _refreshExamsInBackground() async {
    try {
      await _refreshExams();
    } catch (e) {
      print('Background exams refresh failed: $e');
    }
  }

  void _cacheHomework(List<Map<String, dynamic>> homework) {
    _storage.write('teacher_homework', homework);
  }

  void _cacheExams(List<Map<String, dynamic>> exams) {
    _storage.write('teacher_exams', exams);
  }

  List<Map<String, dynamic>> _getCachedHomework() {
    final cached = _storage.read<List>('teacher_homework');
    if (cached != null) {
      return cached.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _getCachedExams() {
    final cached = _storage.read<List>('teacher_exams');
    if (cached != null) {
      return cached.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }
}