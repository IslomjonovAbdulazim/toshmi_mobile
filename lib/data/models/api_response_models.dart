import 'package:json_annotation/json_annotation.dart';

part 'api_response_models.g.dart';

// Generic API error model
@JsonSerializable()
class ApiError {
  final String detail;
  final int? statusCode;
  final String? type;

  const ApiError({
    required this.detail,
    this.statusCode,
    this.type,
  });

  // Get error message in Uzbek (if needed)
  String get messageUz {
    switch (detail.toLowerCase()) {
      case 'invalid credentials':
        return 'Telefon raqam yoki parol noto\'g\'ri';
      case 'permission denied':
        return 'Ruxsat rad etildi';
      case 'not found':
        return 'Topilmadi';
      case 'unauthorized':
        return 'Ruxsat berilmagan kirish';
      case 'forbidden':
        return 'Taqiqlangan';
      case 'validation error':
        return 'Ma\'lumot xatosi';
      case 'server error':
        return 'Server xatosi';
      case 'network error':
        return 'Internet aloqasi xatosi';
      default:
        return detail;
    }
  }

  // Check error type
  bool get isNetworkError => type == 'network' || detail.toLowerCase().contains('network');
  bool get isAuthError => statusCode == 401 || detail.toLowerCase().contains('unauthorized');
  bool get isValidationError => statusCode == 422 || detail.toLowerCase().contains('validation');
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isNotFoundError => statusCode == 404 || detail.toLowerCase().contains('not found');
  bool get isPermissionError => statusCode == 403 || detail.toLowerCase().contains('permission');

  // Get error category
  String get errorCategory {
    if (isNetworkError) return 'Tarmoq xatosi';
    if (isAuthError) return 'Autentifikatsiya xatosi';
    if (isValidationError) return 'Ma\'lumot xatosi';
    if (isServerError) return 'Server xatosi';
    if (isNotFoundError) return 'Topilmadi xatosi';
    if (isPermissionError) return 'Ruxsat xatosi';
    return 'Umumiy xato';
  }

  // JSON serialization
  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @override
  String toString() {
    return 'ApiError(detail: $detail, statusCode: $statusCode, category: $errorCategory)';
  }
}

// Paginated response wrapper
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int skip;
  final int limit;
  @JsonKey(name: 'has_more')
  final bool hasMore;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.skip,
    required this.limit,
    required this.hasMore,
  });

  // Get current page number (1-based)
  int get currentPage => (skip ~/ limit) + 1;

  // Get total pages
  int get totalPages => (total / limit).ceil();

  // Check if has next page
  bool get hasNextPage => hasMore;

  // Check if has previous page
  bool get hasPreviousPage => skip > 0;

  // Get next skip value
  int get nextSkip => skip + limit;

  // Get previous skip value
  int get previousSkip => skip - limit < 0 ? 0 : skip - limit;

  // Get items range text
  String get itemsRangeText {
    final start = skip + 1;
    final end = skip + data.length;
    return '$start-$end / $total';
  }

  // Check if this is the first page
  bool get isFirstPage => skip == 0;

  // Check if this is the last page
  bool get isLastPage => !hasMore;

  // JSON serialization
  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) => _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);

  @override
  String toString() {
    return 'PaginatedResponse(items: ${data.length}, total: $total, page: $currentPage/$totalPages)';
  }
}

// List response wrapper for non-paginated lists
@JsonSerializable(genericArgumentFactories: true)
class ListResponse<T> {
  final List<T> data;
  final int count;

  const ListResponse({
    required this.data,
    required this.count,
  });

  // Check if list is empty
  bool get isEmpty => data.isEmpty;

  // Check if list has data
  bool get hasData => data.isNotEmpty;

  // Get first item (if exists)
  T? get firstItem => data.isNotEmpty ? data.first : null;

  // Get last item (if exists)
  T? get lastItem => data.isNotEmpty ? data.last : null;

  // JSON serialization
  factory ListResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json) fromJsonT,
      ) => _$ListResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ListResponseToJson(this, toJsonT);

  @override
  String toString() {
    return 'ListResponse(count: $count, hasData: $hasData)';
  }
}

// Statistics response model
@JsonSerializable()
class StatsResponse {
  @JsonKey(name: 'total_users')
  final int totalUsers;
  @JsonKey(name: 'total_students')
  final int totalStudents;
  @JsonKey(name: 'total_groups')
  final int totalGroups;
  @JsonKey(name: 'total_subjects')
  final int totalSubjects;
  @JsonKey(name: 'active_users')
  final int activeUsers;
  @JsonKey(name: 'active_students')
  final int activeStudents;
  final int teachers;
  final int parents;
  final int admins;

  const StatsResponse({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalGroups,
    required this.totalSubjects,
    required this.activeUsers,
    required this.activeStudents,
    required this.teachers,
    required this.parents,
    required this.admins,
  });

  // Get user distribution
  Map<String, int> get userDistribution => {
    'Jami foydalanuvchilar': totalUsers,
    'Talabalar': totalStudents,
    'Ustazlar': teachers,
    'Ota-onalar': parents,
    'Administratorlar': admins,
  };

  // Get active user percentage
  double get activeUserPercentage {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }

  // Get active student percentage
  double get activeStudentPercentage {
    if (totalStudents == 0) return 0.0;
    return (activeStudents / totalStudents) * 100;
  }

  // JSON serialization
  factory StatsResponse.fromJson(Map<String, dynamic> json) => _$StatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StatsResponseToJson(this);

  @override
  String toString() {
    return 'StatsResponse(totalUsers: $totalUsers, activeUsers: $activeUsers, students: $totalStudents)';
  }
}

// Health check response model
@JsonSerializable()
class HealthResponse {
  final String status;
  @JsonKey(name: 'database_connected')
  final bool databaseConnected;
  final String version;

  const HealthResponse({
    required this.status,
    required this.databaseConnected,
    required this.version,
  });

  // Check if system is healthy
  bool get isHealthy => status == 'healthy' && databaseConnected;

  // Get status in Uzbek
  String get statusUz {
    switch (status) {
      case 'healthy':
        return 'Sog\'lom';
      case 'unhealthy':
        return 'Nosog\'lom';
      default:
        return status;
    }
  }

  // JSON serialization
  factory HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);

  @override
  String toString() {
    return 'HealthResponse(status: $statusUz, database: $databaseConnected, version: $version)';
  }
}

// Result wrapper for API operations
class ApiResult<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  const ApiResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  // Create successful result
  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  // Create error result
  factory ApiResult.error(ApiError error) {
    return ApiResult._(error: error, isSuccess: false);
  }

  // Create error result from exception
  factory ApiResult.errorFromException(Exception exception) {
    return ApiResult._(
      error: ApiError(
        detail: exception.toString(),
        type: 'exception',
      ),
      isSuccess: false,
    );
  }

  // Check if result has data
  bool get hasData => isSuccess && data != null;

  // Check if result has error
  bool get hasError => !isSuccess && error != null;

  // Get data or throw error
  T get dataOrThrow {
    if (isSuccess && data != null) return data!;
    throw Exception(error?.detail ?? 'Unknown error');
  }

  // Get data or return default
  T getDataOrDefault(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }

  // Map success data to another type
  ApiResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return ApiResult.success(mapper(data!));
      } catch (e) {
        return ApiResult.error(ApiError(detail: e.toString()));
      }
    }
    return ApiResult.error(error ?? ApiError(detail: 'No data to map'));
  }

  // Handle result with callbacks
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError error) error,
  }) {
    if (isSuccess && data != null) {
      return success(data!);
    } else {
      return error(this.error ?? ApiError(detail: 'Unknown error'));
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResult.success(data: $data)';
    } else {
      return 'ApiResult.error(error: $error)';
    }
  }
}