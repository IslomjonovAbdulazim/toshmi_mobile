import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/student_model.dart';
import '../models/homework_model.dart';
import '../models/grade_model.dart';
import '../models/attendance_model.dart';
import '../models/payment_model.dart';
import '../models/dashboard_models.dart';
import '../models/api_response_models.dart';
import '../services/api_service.dart';

class ParentRepository extends GetxService {
  static ParentRepository get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Cache duration constants
  static const Duration _childrenCacheDuration = Duration(hours: 24);
  static const Duration _childHomeworkCacheDuration = Duration(hours: 6);
  static const Duration _childGradesCacheDuration = Duration(hours: 12);
  static const Duration _childAttendanceCacheDuration = Duration(hours: 24);
  static const Duration _childPaymentsCacheDuration = Duration(hours: 24);
  static const Duration _dashboardCacheDuration = Duration(hours: 1);

  // Cache keys
  static const String _childrenCacheKey = '${CacheKeys.parentChildren}_data';
  static const String _dashboardCacheKey = 'parent_dashboard_data';

  // ===================== CHILDREN MANAGEMENT =====================

  /// Get list of parent's children
  Future<ApiResult<List<ChildModel>>> getChildren({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedChildren = _getCachedChildren();
      if (cachedChildren.isNotEmpty && _isChildrenCacheValid()) {
        print('ParentRepository: Using cached children (${cachedChildren.length})');
        // Refresh in background
        _refreshChildrenInBackground();
        return ApiResult.success(cachedChildren);
      }
    }

    // Fetch from API
    return await _fetchChildrenFromApi();
  }

  /// Fetch children from API
  Future<ApiResult<List<ChildModel>>> _fetchChildrenFromApi() async {
    final result = await _apiService.get<List<ChildModel>>(
      ParentEndpoints.children,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ChildModel.fromJson(item)).toList();
        }
        return <ChildModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheChildren(result.data!);
    }

    return result;
  }

  /// Refresh children in background
  Future<void> _refreshChildrenInBackground() async {
    try {
      await _fetchChildrenFromApi();
    } catch (e) {
      print('⚠️ ParentRepository: Background children refresh failed - $e');
    }
  }

  /// Cache children data
  Future<void> _cacheChildren(List<ChildModel> children) async {
    final cacheData = {
      'data': children.map((c) => c.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_childrenCacheKey, cacheData);
    print('ParentRepository: Cached ${children.length} children');
  }

  /// Get cached children
  List<ChildModel> _getCachedChildren() {
    final cachedData = _storage.read<Map<String, dynamic>>(_childrenCacheKey);
    if (cachedData?['data'] != null) {
      try {
        final childrenJson = cachedData!['data'] as List;
        return childrenJson
            .map((item) => ChildModel.fromJson(item))
            .toList();
      } catch (e) {
        print('ParentRepository: Error reading cached children - $e');
        _storage.remove(_childrenCacheKey);
      }
    }
    return [];
  }

  /// Check if children cache is valid
  bool _isChildrenCacheValid() {
    return _isCacheValid(_childrenCacheKey, _childrenCacheDuration);
  }

  /// Get child by ID
  ChildModel? getChildById(int childId) {
    final children = _getCachedChildren();
    return children.where((c) => c.id == childId).firstOrNull;
  }

  // ===================== CHILD HOMEWORK MONITORING =====================

  /// Get specific child's homework
  Future<ApiResult<List<HomeworkModel>>> getChildHomework(
      int childId, {
        bool useCache = true,
        bool forceRefresh = false,
      }) async {
    final cacheKey = _getChildHomeworkCacheKey(childId);

    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedHomework = _getCachedChildHomework(childId);
      if (cachedHomework.isNotEmpty && _isCacheValid(cacheKey, _childHomeworkCacheDuration)) {
        print('ParentRepository: Using cached homework for child $childId (${cachedHomework.length})');
        return ApiResult.success(cachedHomework);
      }
    }

    // Fetch from API
    final result = await _apiService.get<List<HomeworkModel>>(
      ParentEndpoints.childHomework(childId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => HomeworkModel.fromJson(item)).toList();
        }
        return <HomeworkModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheChildHomework(childId, result.data!);
    }

    return result;
  }

  /// Cache child homework
  Future<void> _cacheChildHomework(int childId, List<HomeworkModel> homework) async {
    final cacheKey = _getChildHomeworkCacheKey(childId);
    final cacheData = {
      'data': homework.map((h) => h.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(cacheKey, cacheData);
    print('ParentRepository: Cached ${homework.length} homework for child $childId');
  }

  /// Get cached child homework
  List<HomeworkModel> _getCachedChildHomework(int childId) {
    final cacheKey = _getChildHomeworkCacheKey(childId);
    final cachedData = _storage.read<Map<String, dynamic>>(cacheKey);
    if (cachedData?['data'] != null) {
      try {
        final homeworkJson = cachedData!['data'] as List;
        return homeworkJson
            .map((item) => HomeworkModel.fromJson(item))
            .toList();
      } catch (e) {
        print('ParentRepository: Error reading cached homework for child $childId - $e');
        _storage.remove(cacheKey);
      }
    }
    return [];
  }

  /// Get child homework cache key
  String _getChildHomeworkCacheKey(int childId) => 'child_${childId}_homework_data';

  // ===================== CHILD GRADES MONITORING =====================

  /// Get specific child's grades
  Future<ApiResult<GradesResponseModel>> getChildGrades(
      int childId, {
        bool useCache = true,
        bool forceRefresh = false,
      }) async {
    final cacheKey = _getChildGradesCacheKey(childId);

    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedGrades = _getCachedChildGrades(childId);
      if (cachedGrades != null && _isCacheValid(cacheKey, _childGradesCacheDuration)) {
        print('ParentRepository: Using cached grades for child $childId');
        return ApiResult.success(cachedGrades);
      }
    }

    // Fetch from API
    final result = await _apiService.get<GradesResponseModel>(
      ParentEndpoints.childGrades(childId),
      fromJson: (data) => GradesResponseModel.fromJson(data),
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheChildGrades(childId, result.data!);
    }

    return result;
  }

  /// Cache child grades
  Future<void> _cacheChildGrades(int childId, GradesResponseModel grades) async {
    final cacheKey = _getChildGradesCacheKey(childId);
    final cacheData = {
      'data': grades.toJson(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(cacheKey, cacheData);
    print('ParentRepository: Cached grades for child $childId');
  }

  /// Get cached child grades
  GradesResponseModel? _getCachedChildGrades(int childId) {
    final cacheKey = _getChildGradesCacheKey(childId);
    final cachedData = _storage.read<Map<String, dynamic>>(cacheKey);
    if (cachedData?['data'] != null) {
      try {
        return GradesResponseModel.fromJson(cachedData!['data']);
      } catch (e) {
        print('ParentRepository: Error reading cached grades for child $childId - $e');
        _storage.remove(cacheKey);
      }
    }
    return null;
  }

  /// Get child grades cache key
  String _getChildGradesCacheKey(int childId) => 'child_${childId}_grades_data';

  // ===================== CHILD ATTENDANCE MONITORING =====================

  /// Get specific child's attendance
  Future<ApiResult<List<AttendanceModel>>> getChildAttendance(
      int childId, {
        bool useCache = true,
        bool forceRefresh = false,
      }) async {
    final cacheKey = _getChildAttendanceCacheKey(childId);

    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedAttendance = _getCachedChildAttendance(childId);
      if (cachedAttendance.isNotEmpty && _isCacheValid(cacheKey, _childAttendanceCacheDuration)) {
        print('ParentRepository: Using cached attendance for child $childId (${cachedAttendance.length})');
        return ApiResult.success(cachedAttendance);
      }
    }

    // Fetch from API
    final result = await _apiService.get<List<AttendanceModel>>(
      ParentEndpoints.childAttendance(childId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => AttendanceModel.fromJson(item)).toList();
        }
        return <AttendanceModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheChildAttendance(childId, result.data!);
    }

    return result;
  }

  /// Cache child attendance
  Future<void> _cacheChildAttendance(int childId, List<AttendanceModel> attendance) async {
    final cacheKey = _getChildAttendanceCacheKey(childId);
    final cacheData = {
      'data': attendance.map((a) => a.toJson()).toList(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(cacheKey, cacheData);
    print('ParentRepository: Cached ${attendance.length} attendance records for child $childId');
  }

  /// Get cached child attendance
  List<AttendanceModel> _getCachedChildAttendance(int childId) {
    final cacheKey = _getChildAttendanceCacheKey(childId);
    final cachedData = _storage.read<Map<String, dynamic>>(cacheKey);
    if (cachedData?['data'] != null) {
      try {
        final attendanceJson = cachedData!['data'] as List;
        return attendanceJson
            .map((item) => AttendanceModel.fromJson(item))
            .toList();
      } catch (e) {
        print('ParentRepository: Error reading cached attendance for child $childId - $e');
        _storage.remove(cacheKey);
      }
    }
    return [];
  }

  /// Get child attendance cache key
  String _getChildAttendanceCacheKey(int childId) => 'child_${childId}_attendance_data';

  // ===================== CHILD PAYMENTS MONITORING =====================

  /// Get specific child's payments
  Future<ApiResult<PaymentsResponseModel>> getChildPayments(
      int childId, {
        bool useCache = true,
        bool forceRefresh = false,
      }) async {
    final cacheKey = _getChildPaymentsCacheKey(childId);

    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedPayments = _getCachedChildPayments(childId);
      if (cachedPayments != null && _isCacheValid(cacheKey, _childPaymentsCacheDuration)) {
        print('ParentRepository: Using cached payments for child $childId');
        return ApiResult.success(cachedPayments);
      }
    }

    // Fetch from API
    final result = await _apiService.get<PaymentsResponseModel>(
      ParentEndpoints.childPayments(childId),
      fromJson: (data) => PaymentsResponseModel.fromJson(data),
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheChildPayments(childId, result.data!);
    }

    return result;
  }

  /// Cache child payments
  Future<void> _cacheChildPayments(int childId, PaymentsResponseModel payments) async {
    final cacheKey = _getChildPaymentsCacheKey(childId);
    final cacheData = {
      'data': payments.toJson(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(cacheKey, cacheData);
    print('ParentRepository: Cached payments for child $childId');
  }

  /// Get cached child payments
  PaymentsResponseModel? _getCachedChildPayments(int childId) {
    final cacheKey = _getChildPaymentsCacheKey(childId);
    final cachedData = _storage.read<Map<String, dynamic>>(cacheKey);
    if (cachedData?['data'] != null) {
      try {
        return PaymentsResponseModel.fromJson(cachedData!['data']);
      } catch (e) {
        print('ParentRepository: Error reading cached payments for child $childId - $e');
        _storage.remove(cacheKey);
      }
    }
    return null;
  }

  /// Get child payments cache key
  String _getChildPaymentsCacheKey(int childId) => 'child_${childId}_payments_data';

  // ===================== PARENT DASHBOARD =====================

  /// Get parent dashboard with all children summary
  Future<ApiResult<ParentDashboardModel>> getDashboard({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (useCache && !forceRefresh) {
      final cachedDashboard = _getCachedDashboard();
      if (cachedDashboard != null && _isDashboardCacheValid()) {
        print('ParentRepository: Using cached dashboard');
        return ApiResult.success(cachedDashboard);
      }
    }

    // Fetch from API
    final result = await _apiService.get<ParentDashboardModel>(
      ParentEndpoints.dashboard,
      fromJson: (data) => ParentDashboardModel.fromJson(data),
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheDashboard(result.data!);
    }

    return result;
  }

  /// Cache dashboard data
  Future<void> _cacheDashboard(ParentDashboardModel dashboard) async {
    final cacheData = {
      'data': dashboard.toJson(),
      'cached_at': DateTime.now().toIso8601String(),
    };
    await _storage.write(_dashboardCacheKey, cacheData);
    print('ParentRepository: Cached dashboard data');
  }

  /// Get cached dashboard
  ParentDashboardModel? _getCachedDashboard() {
    final cachedData = _storage.read<Map<String, dynamic>>(_dashboardCacheKey);
    if (cachedData?['data'] != null) {
      try {
        return ParentDashboardModel.fromJson(cachedData!['data']);
      } catch (e) {
        print('ParentRepository: Error reading cached dashboard - $e');
        _storage.remove(_dashboardCacheKey);
      }
    }
    return null;
  }

  /// Check if dashboard cache is valid
  bool _isDashboardCacheValid() {
    return _isCacheValid(_dashboardCacheKey, _dashboardCacheDuration);
  }

  // ===================== BULK DATA OPERATIONS =====================

  /// Get all data for a specific child
  Future<Map<String, dynamic>> getAllChildData(int childId, {
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    try {
      final results = await Future.wait([
        getChildHomework(childId, useCache: useCache, forceRefresh: forceRefresh),
        getChildGrades(childId, useCache: useCache, forceRefresh: forceRefresh),
        getChildAttendance(childId, useCache: useCache, forceRefresh: forceRefresh),
        getChildPayments(childId, useCache: useCache, forceRefresh: forceRefresh),
      ]);

      return {
        'homework': results[0].isSuccess ? results[0].data : <HomeworkModel>[],
        'grades': results[1].isSuccess ? results[1].data : null,
        'attendance': results[2].isSuccess ? results[2].data : <AttendanceModel>[],
        'payments': results[3].isSuccess ? results[3].data : null,
        'success': results.every((r) => r.isSuccess),
      };
    } catch (e) {
      print('ParentRepository: Error getting all child data for $childId - $e');
      return {
        'homework': <HomeworkModel>[],
        'grades': null,
        'attendance': <AttendanceModel>[],
        'payments': null,
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get all cached data for a specific child
  Map<String, dynamic> getAllCachedChildData(int childId) {
    return {
      'homework': _getCachedChildHomework(childId),
      'grades': _getCachedChildGrades(childId),
      'attendance': _getCachedChildAttendance(childId),
      'payments': _getCachedChildPayments(childId),
    };
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
        print('ParentRepository: Error checking cache validity for $cacheKey - $e');
        _storage.remove(cacheKey);
      }
    }
    return false;
  }

  /// Refresh all parent data
  Future<void> refreshAllData() async {
    try {
      // Refresh children first
      await getChildren(forceRefresh: true);

      // Refresh dashboard
      await getDashboard(forceRefresh: true);

      // Refresh data for all children
      final children = _getCachedChildren();
      if (children.isNotEmpty) {
        await Future.wait(children.map((child) =>
            getAllChildData(child.id, forceRefresh: true)
        ));
      }

      print('✅ ParentRepository: All data refreshed');
    } catch (e) {
      print('❌ ParentRepository: Error refreshing all data - $e');
    }
  }

  /// Clear all cached parent data
  Future<void> clearAllCache() async {
    // Get all cache keys that might exist
    final cacheKeys = [
      _childrenCacheKey,
      _dashboardCacheKey,
    ];

    // Add child-specific cache keys
    final allKeys = _storage.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('child_') && key.endsWith('_data')) {
        cacheKeys.add(key);
      }
    }

    await Future.wait(cacheKeys.map((key) => _storage.remove(key)));
    print('🗑️ ParentRepository: All cache cleared');
  }

  /// Clear cache for specific child
  Future<void> clearChildCache(int childId) async {
    final childCacheKeys = [
      _getChildHomeworkCacheKey(childId),
      _getChildGradesCacheKey(childId),
      _getChildAttendanceCacheKey(childId),
      _getChildPaymentsCacheKey(childId),
    ];

    await Future.wait(childCacheKeys.map((key) => _storage.remove(key)));
    print('🗑️ ParentRepository: Cache cleared for child $childId');
  }

  /// Invalidate specific cache
  Future<void> invalidateCache(String cacheType, {int? childId}) async {
    switch (cacheType.toLowerCase()) {
      case 'children':
        await _storage.remove(_childrenCacheKey);
        break;
      case 'dashboard':
        await _storage.remove(_dashboardCacheKey);
        break;
      case 'homework':
        if (childId != null) {
          await _storage.remove(_getChildHomeworkCacheKey(childId));
        }
        break;
      case 'grades':
        if (childId != null) {
          await _storage.remove(_getChildGradesCacheKey(childId));
        }
        break;
      case 'attendance':
        if (childId != null) {
          await _storage.remove(_getChildAttendanceCacheKey(childId));
        }
        break;
      case 'payments':
        if (childId != null) {
          await _storage.remove(_getChildPaymentsCacheKey(childId));
        }
        break;
      case 'child':
        if (childId != null) {
          await clearChildCache(childId);
        }
        break;
      default:
        print('ParentRepository: Unknown cache type: $cacheType');
    }
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    final children = _getCachedChildren();
    final childCacheInfo = <String, Map<String, dynamic>>{};

    for (final child in children) {
      childCacheInfo['child_${child.id}'] = {
        'homework_cached': _getCachedChildHomework(child.id).length,
        'grades_cached': _getCachedChildGrades(child.id) != null,
        'attendance_cached': _getCachedChildAttendance(child.id).length,
        'payments_cached': _getCachedChildPayments(child.id) != null,
        'homework_cache_valid': _isCacheValid(_getChildHomeworkCacheKey(child.id), _childHomeworkCacheDuration),
        'grades_cache_valid': _isCacheValid(_getChildGradesCacheKey(child.id), _childGradesCacheDuration),
        'attendance_cache_valid': _isCacheValid(_getChildAttendanceCacheKey(child.id), _childAttendanceCacheDuration),
        'payments_cache_valid': _isCacheValid(_getChildPaymentsCacheKey(child.id), _childPaymentsCacheDuration),
      };
    }

    return {
      'children': {
        'cached_count': children.length,
        'cache_valid': _isChildrenCacheValid(),
      },
      'dashboard': {
        'cached': _getCachedDashboard() != null,
        'cache_valid': _isDashboardCacheValid(),
      },
      'child_data': childCacheInfo,
    };
  }
}