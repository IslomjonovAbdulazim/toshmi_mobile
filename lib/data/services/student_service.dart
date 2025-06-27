import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response_models.dart';
import '../models/auth_models.dart';
import 'api_service.dart';

class StudentService extends GetxService {
  static StudentService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Cache duration
  static const Duration cacheValidDuration = Duration(hours: 1);

  // ===================== HOMEWORK =====================

  /// Get student's homework assignments
  Future<ApiResult<List<Map<String, dynamic>>>> getHomework({
    int skip = 0,
    int limit = 20,
    bool useCache = true,
  }) async {
    if (useCache && _isCacheValid('homework')) {
      final cached = _getCachedHomework();
      if (cached.isNotEmpty) {
        _refreshHomeworkInBackground();
        return ApiResult.success(cached);
      }
    }

    return await _refreshHomework(skip: skip, limit: limit);
  }

  /// Submit homework
  Future<ApiResult<ApiResponse>> submitHomework({
    required int homeworkId,
    required String submissionText,
    List<int> fileIds = const [],
  }) async {
    final data = {
      'homework_id': homeworkId,
      'submission_text': submissionText,
      'file_ids': fileIds,
    };

    final result = await _apiService.post<ApiResponse>(
      '${StudentEndpoints.homework}/$homeworkId/submit',
      data: data,
      fromJson: (data) => ApiResponse.fromJson(data),
    );

    if (result.isSuccess) {
      await _refreshHomework();
    }

    return result;
  }

  /// Get homework details
  Future<ApiResult<Map<String, dynamic>>> getHomeworkDetails(int homeworkId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${StudentEndpoints.homework}/$homeworkId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ===================== EXAMS =====================

  /// Get student's exams
  Future<ApiResult<List<Map<String, dynamic>>>> getExams({
    int skip = 0,
    int limit = 20,
    bool useCache = true,
  }) async {
    if (useCache && _isCacheValid('exams')) {
      final cached = _getCachedExams();
      if (cached.isNotEmpty) {
        _refreshExamsInBackground();
        return ApiResult.success(cached);
      }
    }

    return await _refreshExams(skip: skip, limit: limit);
  }

  /// Get exam details
  Future<ApiResult<Map<String, dynamic>>> getExamDetails(int examId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${StudentEndpoints.exams}/$examId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ===================== GRADES =====================

  /// Get student's grades
  Future<ApiResult<List<Map<String, dynamic>>>> getGrades({
    int skip = 0,
    int limit = 20,
    bool useCache = true,
  }) async {
    if (useCache && _isCacheValid('grades')) {
      final cached = _getCachedGrades();
      if (cached.isNotEmpty) {
        _refreshGradesInBackground();
        return ApiResult.success(cached);
      }
    }

    return await _refreshGrades(skip: skip, limit: limit);
  }

  /// Get grades summary
  Future<ApiResult<Map<String, dynamic>>> getGradesSummary() async {
    return await _apiService.get<Map<String, dynamic>>(
      '${StudentEndpoints.grades}/summary',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ===================== ATTENDANCE =====================

  /// Get student's attendance
  Future<ApiResult<List<Map<String, dynamic>>>> getAttendance({
    DateTime? startDate,
    DateTime? endDate,
    bool useCache = true,
  }) async {
    if (useCache && _isCacheValid('attendance')) {
      final cached = _getCachedAttendance();
      if (cached.isNotEmpty) {
        _refreshAttendanceInBackground();
        return ApiResult.success(cached);
      }
    }

    return await _refreshAttendance(startDate: startDate, endDate: endDate);
  }

  /// Get attendance summary
  Future<ApiResult<Map<String, dynamic>>> getAttendanceSummary() async {
    return await _apiService.get<Map<String, dynamic>>(
      '${StudentEndpoints.attendance}/summary',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ===================== SCHEDULE =====================

  /// Get student's schedule
  Future<ApiResult<List<Map<String, dynamic>>>> getSchedule({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    return await _apiService.get<List<Map<String, dynamic>>>(
      StudentEndpoints.schedule,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Get today's schedule
  Future<ApiResult<List<Map<String, dynamic>>>> getTodaySchedule() async {
    final today = DateTime.now();
    return await getSchedule(startDate: today, endDate: today);
  }

  // ===================== PAYMENTS =====================

  /// Get student's payments
  Future<ApiResult<List<Map<String, dynamic>>>> getPayments({
    int skip = 0,
    int limit = 20,
  }) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      StudentEndpoints.payments,
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  /// Get payment summary
  Future<ApiResult<Map<String, dynamic>>> getPaymentSummary() async {
    return await _apiService.get<Map<String, dynamic>>(
      '${StudentEndpoints.payments}/summary',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ===================== DASHBOARD =====================

  /// Get student dashboard data
  Future<ApiResult<Map<String, dynamic>>> getDashboard() async {
    return await _apiService.get<Map<String, dynamic>>(
      '/student/dashboard',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ===================== ANALYTICS =====================

  /// Get student statistics
  Map<String, dynamic> getStudentStats() {
    final homework = _getCachedHomework();
    final grades = _getCachedGrades();
    final attendance = _getCachedAttendance();

    final now = DateTime.now();
    final thisWeek = now.subtract(Duration(days: now.weekday - 1));

    return {
      'homework': {
        'total': homework.length,
        'completed': homework.where((h) => h['status'] == 'submitted').length,
        'pending': homework.where((h) => h['status'] == 'pending').length,
        'overdue': homework.where((h) => h['status'] == 'overdue').length,
      },
      'grades': {
        'total': grades.length,
        'thisWeek': grades.where((g) {
          final gradedAt = DateTime.tryParse(g['graded_at']?.toString() ?? '');
          return gradedAt?.isAfter(thisWeek) == true;
        }).length,
        'average': _calculateAverageGrade(grades),
      },
      'attendance': {
        'total': attendance.length,
        'present': attendance.where((a) => a['status'] == 'present').length,
        'absent': attendance.where((a) => a['status'] == 'absent').length,
        'percentage': _calculateAttendancePercentage(attendance),
      },
    };
  }

  // ===================== PRIVATE METHODS =====================

  Future<ApiResult<List<Map<String, dynamic>>>> _refreshHomework({
    int skip = 0,
    int limit = 20,
  }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      StudentEndpoints.homework,
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheData('homework', result.data!);
    }

    return result;
  }

  Future<ApiResult<List<Map<String, dynamic>>>> _refreshExams({
    int skip = 0,
    int limit = 20,
  }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      StudentEndpoints.exams,
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheData('exams', result.data!);
    }

    return result;
  }

  Future<ApiResult<List<Map<String, dynamic>>>> _refreshGrades({
    int skip = 0,
    int limit = 20,
  }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      StudentEndpoints.grades,
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheData('grades', result.data!);
    }

    return result;
  }

  Future<ApiResult<List<Map<String, dynamic>>>> _refreshAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    final result = await _apiService.get<List<Map<String, dynamic>>>(
      StudentEndpoints.attendance,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheData('attendance', result.data!);
    }

    return result;
  }

  // Background refresh methods
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

  void _refreshGradesInBackground() async {
    try {
      await _refreshGrades();
    } catch (e) {
      print('Background grades refresh failed: $e');
    }
  }

  void _refreshAttendanceInBackground() async {
    try {
      await _refreshAttendance();
    } catch (e) {
      print('Background attendance refresh failed: $e');
    }
  }

  // Cache management
  void _cacheData(String key, List<Map<String, dynamic>> data) {
    _storage.write('student_$key', data);
    _storage.write('student_${key}_timestamp', DateTime.now().toIso8601String());
  }

  bool _isCacheValid(String key) {
    final timestamp = _storage.read<String>('student_${key}_timestamp');
    if (timestamp == null) return false;

    final cacheTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) < cacheValidDuration;
  }

  List<Map<String, dynamic>> _getCachedHomework() => _getCachedData('homework');
  List<Map<String, dynamic>> _getCachedExams() => _getCachedData('exams');
  List<Map<String, dynamic>> _getCachedGrades() => _getCachedData('grades');
  List<Map<String, dynamic>> _getCachedAttendance() => _getCachedData('attendance');

  List<Map<String, dynamic>> _getCachedData(String key) {
    final cached = _storage.read<List>('student_$key');
    if (cached != null) {
      return cached.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  // Analytics helpers
  double _calculateAverageGrade(List<Map<String, dynamic>> grades) {
    if (grades.isEmpty) return 0.0;

    final total = grades.fold<double>(0.0, (sum, grade) {
      final points = (grade['points'] as num?)?.toDouble() ?? 0.0;
      return sum + points;
    });

    return total / grades.length;
  }

  double _calculateAttendancePercentage(List<Map<String, dynamic>> attendance) {
    if (attendance.isEmpty) return 0.0;

    final present = attendance.where((a) => a['status'] == 'present').length;
    return (present / attendance.length) * 100;
  }
}