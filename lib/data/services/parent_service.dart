import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response_models.dart';
import '../models/auth_models.dart';
import 'api_service.dart';

class ParentService extends GetxService {
  static ParentService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Cache duration
  static const Duration cacheValidDuration = Duration(hours: 1);

  // ===================== CHILDREN MANAGEMENT =====================

  /// Get parent's children
  Future<ApiResult<List<Map<String, dynamic>>>> getChildren({
    bool useCache = true,
  }) async {
    if (useCache && _isCacheValid('children')) {
      final cached = _getCachedChildren();
      if (cached.isNotEmpty) {
        _refreshChildrenInBackground();
        return ApiResult.success(cached);
      }
    }

    return await _refreshChildren();
  }

  /// Get child by ID
  Map<String, dynamic>? getChildById(int childId) {
    final children = _getCachedChildren();
    try {
      return children.firstWhere((child) => child['id'] == childId);
    } catch (e) {
      return null;
    }
  }

  /// Get active children (enrolled in current academic year)
  List<Map<String, dynamic>> getActiveChildren() {
    final children = _getCachedChildren();
    return children.where((child) => child['is_active'] == true).toList();
  }

  // ===================== CHILD-SPECIFIC DATA =====================

  /// Get child's homework
  Future<ApiResult<List<Map<String, dynamic>>>> getChildHomework(
      int childId, {
        int skip = 0,
        int limit = 20,
        bool useCache = true,
      }) async {
    if (useCache && _isCacheValid('homework_$childId')) {
      final cached = _getCachedChildData('homework', childId);
      if (cached.isNotEmpty) {
        _refreshChildHomeworkInBackground(childId);
        return ApiResult.success(cached);
      }
    }

    return await _refreshChildHomework(childId, skip: skip, limit: limit);
  }

  /// Get child's grades
  Future<ApiResult<List<Map<String, dynamic>>>> getChildGrades(
      int childId, {
        int skip = 0,
        int limit = 20,
        bool useCache = true,
      }) async {
    if (useCache && _isCacheValid('grades_$childId')) {
      final cached = _getCachedChildData('grades', childId);
      if (cached.isNotEmpty) {
        _refreshChildGradesInBackground(childId);
        return ApiResult.success(cached);
      }
    }

    return await _refreshChildGrades(childId, skip: skip, limit: limit);
  }

  /// Get child's attendance
  Future<ApiResult<List<Map<String, dynamic>>>> getChildAttendance(
      int childId, {
        DateTime? startDate,
        DateTime? endDate,
        bool useCache = true,
      }) async {
    if (useCache && _isCacheValid('attendance_$childId')) {
      final cached = _getCachedChildData('attendance', childId);
      if (cached.isNotEmpty) {
        _refreshChildAttendanceInBackground(childId);
        return ApiResult.success(cached);
      }
    }

    return await _refreshChildAttendance(childId, startDate: startDate, endDate: endDate);
  }

  /// Get child's payments
  Future<ApiResult<List<Map<String, dynamic>>>> getChildPayments(
      int childId, {
        int skip = 0,
        int limit = 20,
        bool useCache = true,
      }) async {
    if (useCache && _isCacheValid('payments_$childId')) {
      final cached = _getCachedChildData('payments', childId);
      if (cached.isNotEmpty) {
        _refreshChildPaymentsInBackground(childId);
        return ApiResult.success(cached);
      }
    }

    return await _refreshChildPayments(childId, skip: skip, limit: limit);
  }

  // ===================== DASHBOARD & SUMMARY =====================

  /// Get parent dashboard data
  Future<ApiResult<Map<String, dynamic>>> getDashboard() async {
    return await _apiService.get<Map<String, dynamic>>(
      ParentEndpoints.dashboard,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get child's academic summary
  Future<ApiResult<Map<String, dynamic>>> getChildAcademicSummary(int childId) async {
    return await _apiService.get<Map<String, dynamic>>(
      '${ParentEndpoints.children}/$childId/summary',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get child's progress report
  Future<ApiResult<Map<String, dynamic>>> getChildProgressReport(
      int childId, {
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

    return await _apiService.get<Map<String, dynamic>>(
      '${ParentEndpoints.children}/$childId/progress',
      queryParameters: queryParams,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ===================== NOTIFICATIONS & COMMUNICATION =====================

  /// Get child-specific notifications
  Future<ApiResult<List<Map<String, dynamic>>>> getChildNotifications(
      int childId, {
        int skip = 0,
        int limit = 20,
      }) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '${ParentEndpoints.children}/$childId/notifications',
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );
  }

  // ===================== ANALYTICS =====================

  /// Get comprehensive statistics for all children
  Map<String, dynamic> getChildrenStats() {
    final children = _getCachedChildren();
    final stats = <String, dynamic>{
      'totalChildren': children.length,
      'activeChildren': children.where((c) => c['is_active'] == true).length,
      'children': <Map<String, dynamic>>[],
    };

    for (final child in children) {
      final childId = child['id'] as int;
      final childStats = _getChildStats(childId);
      stats['children'].add({
        'id': childId,
        'name': child['name'],
        'stats': childStats,
      });
    }

    return stats;
  }

  /// Get statistics for a specific child
  Map<String, dynamic> _getChildStats(int childId) {
    final homework = _getCachedChildData('homework', childId);
    final grades = _getCachedChildData('grades', childId);
    final attendance = _getCachedChildData('attendance', childId);
    final payments = _getCachedChildData('payments', childId);

    return {
      'homework': {
        'total': homework.length,
        'completed': homework.where((h) => h['status'] == 'submitted').length,
        'pending': homework.where((h) => h['status'] == 'pending').length,
        'overdue': homework.where((h) => h['status'] == 'overdue').length,
      },
      'grades': {
        'total': grades.length,
        'average': _calculateAverageGrade(grades),
        'latest': grades.isNotEmpty ? grades.first : null,
      },
      'attendance': {
        'total': attendance.length,
        'present': attendance.where((a) => a['status'] == 'present').length,
        'absent': attendance.where((a) => a['status'] == 'absent').length,
        'percentage': _calculateAttendancePercentage(attendance),
      },
      'payments': {
        'total': payments.length,
        'paid': payments.where((p) => p['status'] == 'paid').length,
        'pending': payments.where((p) => p['status'] == 'pending').length,
        'overdue': payments.where((p) => p['status'] == 'overdue').length,
      },
    };
  }

  // ===================== PRIVATE METHODS =====================

  /// Refresh children data
  Future<ApiResult<List<Map<String, dynamic>>>> _refreshChildren() async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      ParentEndpoints.children,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheData('children', result.data!);
    }

    return result;
  }

  /// Refresh child homework
  Future<ApiResult<List<Map<String, dynamic>>>> _refreshChildHomework(
      int childId, {
        int skip = 0,
        int limit = 20,
      }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      ParentEndpoints.childHomework(childId),
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheChildData('homework', childId, result.data!);
    }

    return result;
  }

  /// Refresh child grades
  Future<ApiResult<List<Map<String, dynamic>>>> _refreshChildGrades(
      int childId, {
        int skip = 0,
        int limit = 20,
      }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      ParentEndpoints.childGrades(childId),
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheChildData('grades', childId, result.data!);
    }

    return result;
  }

  /// Refresh child attendance
  Future<ApiResult<List<Map<String, dynamic>>>> _refreshChildAttendance(
      int childId, {
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
      ParentEndpoints.childAttendance(childId),
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheChildData('attendance', childId, result.data!);
    }

    return result;
  }

  /// Refresh child payments
  Future<ApiResult<List<Map<String, dynamic>>>> _refreshChildPayments(
      int childId, {
        int skip = 0,
        int limit = 20,
      }) async {
    final result = await _apiService.get<List<Map<String, dynamic>>>(
      ParentEndpoints.childPayments(childId),
      queryParameters: {'skip': skip, 'limit': limit},
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        }
        return <Map<String, dynamic>>[];
      },
    );

    if (result.isSuccess && result.data != null) {
      _cacheChildData('payments', childId, result.data!);
    }

    return result;
  }

  // Background refresh methods
  void _refreshChildrenInBackground() async {
    try {
      await _refreshChildren();
    } catch (e) {
      print('Background children refresh failed: $e');
    }
  }

  void _refreshChildHomeworkInBackground(int childId) async {
    try {
      await _refreshChildHomework(childId);
    } catch (e) {
      print('Background child homework refresh failed: $e');
    }
  }

  void _refreshChildGradesInBackground(int childId) async {
    try {
      await _refreshChildGrades(childId);
    } catch (e) {
      print('Background child grades refresh failed: $e');
    }
  }

  void _refreshChildAttendanceInBackground(int childId) async {
    try {
      await _refreshChildAttendance(childId);
    } catch (e) {
      print('Background child attendance refresh failed: $e');
    }
  }

  void _refreshChildPaymentsInBackground(int childId) async {
    try {
      await _refreshChildPayments(childId);
    } catch (e) {
      print('Background child payments refresh failed: $e');
    }
  }

  // Cache management
  void _cacheData(String key, List<Map<String, dynamic>> data) {
    _storage.write('parent_$key', data);
    _storage.write('parent_${key}_timestamp', DateTime.now().toIso8601String());
  }

  void _cacheChildData(String key, int childId, List<Map<String, dynamic>> data) {
    _storage.write('parent_${key}_$childId', data);
    _storage.write('parent_${key}_${childId}_timestamp', DateTime.now().toIso8601String());
  }

  bool _isCacheValid(String key) {
    final timestamp = _storage.read<String>('parent_${key}_timestamp');
    if (timestamp == null) return false;

    final cacheTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    return now.difference(cacheTime) < cacheValidDuration;
  }

  List<Map<String, dynamic>> _getCachedChildren() {
    return _getCachedData('children');
  }

  List<Map<String, dynamic>> _getCachedChildData(String key, int childId) {
    final cached = _storage.read<List>('parent_${key}_$childId');
    if (cached != null) {
      return cached.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _getCachedData(String key) {
    final cached = _storage.read<List>('parent_$key');
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