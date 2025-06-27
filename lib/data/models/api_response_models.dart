// Generic API result wrapper
class ApiResult<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  const ApiResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  factory ApiResult.error(ApiError error) {
    return ApiResult._(error: error, isSuccess: false);
  }

  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error ?? ApiError(detail: 'Unknown error', type: 'unknown');
  }

  T getDataOrElse(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResult.success($data)';
    } else {
      return 'ApiResult.error($error)';
    }
  }
}

// API error model
class ApiError {
  final String detail;
  final String type;
  final String? field;
  final int? statusCode;

  const ApiError({
    required this.detail,
    required this.type,
    this.field,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      detail: json['detail'] as String? ?? 'Unknown error',
      type: json['type'] as String? ?? 'unknown',
      field: json['field'] as String?,
      statusCode: json['status_code'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detail': detail,
      'type': type,
      if (field != null) 'field': field,
      if (statusCode != null) 'status_code': statusCode,
    };
  }

  // Common error types
  static ApiError networkError([String? message]) => ApiError(
    detail: message ?? 'Internetga ulanishda xatolik',
    type: 'network_error',
  );

  static ApiError serverError([String? message]) => ApiError(
    detail: message ?? 'Server xatosi',
    type: 'server_error',
  );

  static ApiError validationError(String message, [String? field]) => ApiError(
    detail: message,
    type: 'validation_error',
    field: field,
  );

  static ApiError authError([String? message]) => ApiError(
    detail: message ?? 'Avtorizatsiya xatosi',
    type: 'auth_error',
  );

  static ApiError notFoundError([String? message]) => ApiError(
    detail: message ?? 'Ma\'lumot topilmadi',
    type: 'not_found',
  );

  @override
  String toString() => 'ApiError(detail: $detail, type: $type)';
}

// File progress model for upload/download
class FileProgress {
  final int fileId;
  final String fileName;
  final double progress;
  final String status;

  const FileProgress({
    required this.fileId,
    required this.fileName,
    required this.progress,
    required this.status,
  });

  bool get isCompleted => progress >= 1.0;
  bool get isInProgress => progress > 0.0 && progress < 1.0;
  int get progressPercentage => (progress * 100).round();

  FileProgress copyWith({
    int? fileId,
    String? fileName,
    double? progress,
    String? status,
  }) {
    return FileProgress(
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      status: status ?? this.status,
    );
  }

  @override
  String toString() => 'FileProgress(fileId: $fileId, progress: ${progressPercentage}%, status: $status)';
}

// File validation result
class FileValidationResult {
  final bool isValid;
  final String? errorMessage;

  const FileValidationResult(this.isValid, [this.errorMessage]);

  factory FileValidationResult.valid() => const FileValidationResult(true);
  factory FileValidationResult.invalid(String message) => FileValidationResult(false, message);

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $errorMessage';
}

// Pagination info
class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  int get totalPages => (total / limit).ceil();
  int get currentPage => page;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
    );
  }

  @override
  String toString() => 'PaginationInfo(page: $page/$totalPages, total: $total)';
}

// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> items;
  final PaginationInfo pagination;

  const PaginatedResponse({
    required this.items,
    required this.pagination,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() => 'PaginatedResponse(items: ${items.length}, pagination: $pagination)';
}