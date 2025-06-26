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
import '../services/api_service.dart';

class StudentRepository extends GetxService {
  static StudentRepository get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Cache duration constants
  static const Duration _homeworkCacheDuration = Duration(hours: 6);
  static const Duration _examsCacheDuration = Duration(hours: 12);
  static const Duration _gradesCacheDuration = Duration(hours: 24);
  static const Duration _scheduleCacheDuration = Duration(days: 7);
  static const Duration _paymentsCacheDuration = Duration(hours: 24);

  // Cache keys
  static const String _homeworkCacheKey = '${CacheKeys.studentHomework}_data';
  static const String _examsCacheKey = '${CacheKeys.studentExams}_data';
  static const String _gradesCacheKey = '${CacheKeys.studentGrades}_data';
  static const String _scheduleCacheKey = 'student_schedule_data';
  static const String _paymentsCacheKey = 'student_payments_data';

  // ===================== HOMEWORK =====================

  /// Get student's homework assignments
  Future<ApiResult<List<HomeworkModel>>> getHomework({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedHomework = _getCachedHomework();
      if (cachedHomework.isNotEmpty && _isHomeworkCacheValid()) {
        print('StudentRepository: Using cached homework (${cachedHomework.length})');
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
      await _fetchHomeworkFromApi();
    } catch (e) {
      print('⚠️ StudentRepository: Background homework refresh failed - $e');
    }
  }

  /// Cache homework data
  Future<void> _cacheHomework(List<HomeworkModel> homework) async {
    final cacheData = {
      'data': homework.map((h) => h.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_homeworkCacheKey, cacheData);
    print('StudentRepository: Cached ${homework.length} homework assignments');
  }

  /// Get cached homework
  List<HomeworkModel> _getCachedHomework() {
    final cachedData = _storage.read<Map<String, dynamic>>(_homeworkCacheKey);
    if (cachedData?['data'] != null) {
      try {
        final homeworkJson = cachedData!['data'] as List;
        return homeworkJson
            .map((item) => HomeworkModel.fromJson(item))
            .toList();
      } catch (e) {
        print('StudentRepository: Error reading cached homework - $e');
        _storage.remove(_homeworkCacheKey);
      }
    }
    return [];
  }

  /// Check if homework cache is valid
  bool _isHomeworkCacheValid() {
    return _isCacheValid(_homeworkCacheKey, _homeworkCacheDuration);
  }

  // ===================== EXAMS =====================

  /// Get student's exams
  Future<ApiResult<List<ExamModel>>> getExams({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedExams = _getCachedExams();
      if (cachedExams.isNotEmpty && _isExamsCacheValid()) {
        print('StudentRepository: Using cached exams (${cachedExams.length})');
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
      await _fetchExamsFromApi();
    } catch (e) {
      print('⚠️ StudentRepository: Background exams refresh failed - $e');
    }
  }

  /// Cache exams data
  Future<void> _cacheExams(List<ExamModel> exams) async {
    final cacheData = {
      'data': exams.map((e) => e.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_examsCacheKey, cacheData);
    print('StudentRepository: Cached ${exams.length} exams');
  }

  /// Get cached exams
  List<ExamModel> _getCachedExams() {
    final cachedData = _storage.read<Map<String, dynamic>>(_examsCacheKey);
    if (cachedData?['data'] != null) {
      try {
        final examsJson = cachedData!['data'] as List;
        return examsJson
            .map((item) => ExamModel.fromJson(item))
            .toList();
      } catch (e) {
        print('StudentRepository: Error reading cached exams - $e');
        _storage.remove(_examsCacheKey);
      }
    }
    return [];
  }

  /// Check if exams cache is valid
  bool _isExamsCacheValid() {
    return _isCacheValid(_examsCacheKey, _examsCacheDuration);
  }

  // ===================== GRADES =====================

  /// Get student's grades
  Future<ApiResult<GradesResponseModel>> getGrades({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedGrades = _getCachedGrades();
      if (cachedGrades != null && _isGradesCacheValid()) {
        print('StudentRepository: Using cached grades');
        // Refresh in background
        _refreshGradesInBackground();
        return ApiResult.success(cachedGrades);
      }
    }

    // Fetch from API
    return await _fetchGradesFromApi();
  }

  /// Fetch grades from API
  Future<ApiResult<GradesResponseModel>> _fetchGradesFromApi() async {
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
      await _fetchGradesFromApi();
    } catch (e) {
      print('⚠️ StudentRepository: Background grades refresh failed - $e');
    }
  }

  /// Cache grades data
  Future<void> _cacheGrades(GradesResponseModel grades) async {
    final cacheData = {
      'data': grades.toJson(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_gradesCacheKey, cacheData);
    print('StudentRepository: Cached grades data');
  }

  /// Get cached grades
  GradesResponseModel? _getCachedGrades() {
    final cachedData = _storage.read<Map<String, dynamic>>(_gradesCacheKey);
    if (cachedData?['data'] != null) {
      try {
        return GradesResponseModel.fromJson(cachedData!['data']);
      } catch (e) {
        print('StudentRepository: Error reading cached grades - $e');
        _storage.remove(_gradesCacheKey);
      }
    }
    return null;
  }

  /// Check if grades cache is valid
  bool _isGradesCacheValid() {
    return _isCacheValid(_gradesCacheKey, _gradesCacheDuration);
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

  // ===================== SCHEDULE =====================

  /// Get student's class schedule
  Future<ApiResult<List<ScheduleModel>>> getSchedule({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first (schedule changes less frequently)
    if (useCache && !forceRefresh) {
      final cachedSchedule = _getCachedSchedule();
      if (cachedSchedule.isNotEmpty && _isScheduleCacheValid()) {
        print('StudentRepository: Using cached schedule (${cachedSchedule.length})');
        return ApiResult.success(cachedSchedule);
      }
    }

    // Fetch from API
    final result = await _apiService.get<List<ScheduleModel>>(
      StudentEndpoints.schedule,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ScheduleModel.fromJson(item)).toList();
        }
        return <ScheduleModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheSchedule(result.data!);
    }

    return result;
  }

  /// Cache schedule data
  Future<void> _cacheSchedule(List<ScheduleModel> schedule) async {
    final cacheData = {
      'data': schedule.map((s) => s.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_scheduleCacheKey, cacheData);
    print('StudentRepository: Cached ${schedule.length} schedule items');
  }

  /// Get cached schedule
  List<ScheduleModel> _getCachedSchedule() {
    final cachedData = _storage.read<Map<String, dynamic>>(_scheduleCacheKey);
    if (cachedData?['data'] != null) {
      try {
        final scheduleJson = cachedData!['data'] as List;
        return scheduleJson
            .map((item) => ScheduleModel.fromJson(item))
            .toList();
      } catch (e) {
        print('StudentRepository: Error reading cached schedule - $e');
        _storage.remove(_scheduleCacheKey);
      }
    }
    return [];
  }

  /// Check if schedule cache is valid
  bool _isScheduleCacheValid() {
    return _isCacheValid(_scheduleCacheKey, _scheduleCacheDuration);
  }

  // ===================== PAYMENTS =====================

  /// Get student's payment records
  Future<ApiResult<PaymentsResponseModel>> getPayments({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedPayments = _getCachedPayments();
      if (cachedPayments != null && _isPaymentsCacheValid()) {
        print('StudentRepository: Using cached payments');
        return ApiResult.success(cachedPayments);
      }
    }

    // Fetch from API
    final result = await _apiService.get<PaymentsResponseModel>(
      StudentEndpoints.payments,
      fromJson: (data) => PaymentsResponseModel.fromJson(data),
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cachePayments(result.data!);
    }

    return result;
  }

  /// Cache payments data
  Future<void> _cachePayments(PaymentsResponseModel payments) async {
    final cacheData = {
      'data': payments.toJson(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_paymentsCacheKey, cacheData);
    print('StudentRepository: Cached payments data');
  }

  /// Get cached payments
  PaymentsResponseModel? _getCachedPayments() {
    final cachedData = _storage.read<Map<String, dynamic>>(_paymentsCacheKey);
    if (cachedData?['data'] != null) {
      try {
        return PaymentsResponseModel.fromJson(cachedData!['data']);
      } catch (e) {
        print('StudentRepository: Error reading cached payments - $e');
        _storage.remove(_paymentsCacheKey);
      }
    }
    return null;
  }

  /// Check if payments cache is valid
  bool _isPaymentsCacheValid() {
    return _isCacheValid(_paymentsCacheKey, _paymentsCacheDuration);
  }

  // ===================== DASHBOARD =====================

  /// Get student dashboard data
  Future<ApiResult<StudentDashboardModel>> getDashboard() async {
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
    try {
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

      // Only update cache if we don't have fresh data
      if (!_isHomeworkCacheValid()) {
        await _cacheHomework(homework);
      }
      if (!_isExamsCacheValid()) {
        await _cacheExams(exams);
      }

      print('StudentRepository: Updated caches from dashboard data');
    } catch (e) {
      print('StudentRepository: Error updating caches from dashboard - $e');
    }
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
        print('StudentRepository: Error checking cache validity for $cacheKey - $e');
        _storage.remove(cacheKey);
      }
    }
    return false;
  }

  /// Get all cached data (for quick access)
  Map<String, dynamic> getAllCachedData() {
    return {
      'homework': _getCachedHomework(),
      'exams': _getCachedExams(),
      'grades': _getCachedGrades(),
      'schedule': _getCachedSchedule(),
      'payments': _getCachedPayments(),
    };
  }

  /// Refresh all student data
  Future<void> refreshAllData() async {
    try {
      await Future.wait([
        getHomework(forceRefresh: true),
        getExams(forceRefresh: true),
        getGrades(forceRefresh: true),
        getSchedule(forceRefresh: true),
        getPayments(forceRefresh: true),
      ]);
      print('✅ StudentRepository: All data refreshed');
    } catch (e) {
      print('❌ StudentRepository: Error refreshing all data - $e');
    }
  }

  /// Clear all cached student data
  Future<void> clearAllCache() async {
    final cacheKeys = [
      _homeworkCacheKey,
      _examsCacheKey,
      _gradesCacheKey,
      _scheduleCacheKey,
      _paymentsCacheKey,
    ];

    await Future.wait(cacheKeys.map((key) => _storage.remove(key)));
    print('🗑️ StudentRepository: All cache cleared');
  }

  /// Invalidate specific cache
  Future<void> invalidateCache(String cacheType) async {
    switch (cacheType.toLowerCase()) {
      case 'homework':
        await _storage.remove(_homeworkCacheKey);
        break;
      case 'exams':
        await _storage.remove(_examsCacheKey);
        break;
      case 'grades':
        await _storage.remove(_gradesCacheKey);
        break;
      case 'schedule':
        await _storage.remove(_scheduleCacheKey);
        break;
      case 'payments':
        await _storage.remove(_paymentsCacheKey);
        break;
      default:
        print('StudentRepository: Unknown cache type: $cacheType');
    }
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'homework': {
        'cached_count': _getCachedHomework().length,
        'cache_valid': _isHomeworkCacheValid(),
      },
      'exams': {
        'cached_count': _getCachedExams().length,
        'cache_valid': _isExamsCacheValid(),
      },
      'grades': {
        'cached': _getCachedGrades() != null,
        'cache_valid': _isGradesCacheValid(),
      },
      'schedule': {
        'cached_count': _getCachedSchedule().length,
        'cache_valid': _isScheduleCacheValid(),
      },
      'payments': {
        'cached': _getCachedPayments() != null,
        'cache_valid': _isPaymentsCacheValid(),
      },
    };
  }
}