// ===================== API EXCEPTIONS =====================

import 'package:dio/dio.dart';

import 'app_exception.dart';

class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? data;

  const ApiException(
    String message, {
    this.statusCode,
    this.data,
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException('Ulanishda vaqt tugadi');
      case DioExceptionType.sendTimeout:
        return const NetworkException('Ma\'lumot yuborishda vaqt tugadi');
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Ma\'lumot olishda vaqt tugadi');
      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException);
      case DioExceptionType.cancel:
        return const RequestCancelledException('So\'rov bekor qilindi');
      case DioExceptionType.connectionError:
        return const NetworkException('Internet aloqasi yo\'q');
      case DioExceptionType.unknown:
        return ServerException('Noma\'lum xatolik: ${dioException.message}');
      default:
        return ServerException('API xatosi: ${dioException.message}');
    }
  }

  static ApiException _handleBadResponse(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;

    switch (statusCode) {
      case 400:
        return BadRequestException(
          _extractErrorMessage(data) ?? 'Noto\'g\'ri so\'rov',
          data: data,
        );
      case 401:
        return UnauthorizedException(
          _extractErrorMessage(data) ?? 'Avtorizatsiya talab qilinadi',
          data: data,
        );
      case 403:
        return ForbiddenException(
          _extractErrorMessage(data) ?? 'Ruxsat berilmagan',
          data: data,
        );
      case 404:
        return NotFoundException(
          _extractErrorMessage(data) ?? 'Ma\'lumot topilmadi',
          data: data,
        );
      case 422:
        return ValidationException(
          _extractErrorMessage(data) ?? 'Ma\'lumotlar noto\'g\'ri',
          data: data,
        );
      case 429:
        return TooManyRequestsException(
          _extractErrorMessage(data) ?? 'Juda ko\'p so\'rov',
          data: data,
        );
      case 500:
        return ServerException(
          _extractErrorMessage(data) ?? 'Server xatosi',
          statusCode: statusCode,
          data: data,
        );
      case 502:
        return ServerException(
          'Bad Gateway - Server xatosi',
          statusCode: statusCode,
          data: data,
        );
      case 503:
        return ServerException(
          'Xizmat vaqtincha mavjud emas',
          statusCode: statusCode,
          data: data,
        );
      default:
        return ApiException(
          _extractErrorMessage(data) ?? 'HTTP $statusCode xatosi',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Try different possible error message fields
      return data['detail'] ??
          data['message'] ??
          data['error'] ??
          data['error_description'];
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ===================== SPECIFIC API EXCEPTIONS =====================

class NetworkException extends ApiException {
  const NetworkException(String message)
    : super(message, code: 'NETWORK_ERROR');
}

class ServerException extends ApiException {
  const ServerException(
    String message, {
    int? statusCode,
    Map<String, dynamic>? data,
  }) : super(message, code: 'SERVER_ERROR', originalError: null);
}

class BadRequestException extends ApiException {
  const BadRequestException(String message, {Map<String, dynamic>? data})
    : super(message, statusCode: 400, data: data, code: 'BAD_REQUEST');
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(String message, {Map<String, dynamic>? data})
    : super(message, statusCode: 401, data: data, code: 'UNAUTHORIZED');
}

class ForbiddenException extends ApiException {
  const ForbiddenException(String message, {Map<String, dynamic>? data})
    : super(message, statusCode: 403, data: data, code: 'FORBIDDEN');
}

class NotFoundException extends ApiException {
  const NotFoundException(String message, {Map<String, dynamic>? data})
    : super(message, statusCode: 404, data: data, code: 'NOT_FOUND');
}

class ValidationException extends ApiException {
  const ValidationException(String message, {Map<String, dynamic>? data})
    : super(message, statusCode: 422, data: data, code: 'VALIDATION_ERROR');
}

class TooManyRequestsException extends ApiException {
  const TooManyRequestsException(String message, {Map<String, dynamic>? data})
    : super(message, statusCode: 429, data: data, code: 'TOO_MANY_REQUESTS');
}

class RequestCancelledException extends ApiException {
  const RequestCancelledException(String message)
    : super(message, code: 'REQUEST_CANCELLED');
}

// ===================== AUTHENTICATION EXCEPTIONS =====================

class AuthException extends AppException {
  const AuthException(String message, {String? code})
    : super(message, code: code);
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException()
    : super('Token muddati tugagan', code: 'TOKEN_EXPIRED');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
    : super('Login yoki parol noto\'g\'ri', code: 'INVALID_CREDENTIALS');
}

class AccountLockedException extends AuthException {
  const AccountLockedException()
    : super('Hisob vaqtincha bloklangan', code: 'ACCOUNT_LOCKED');
}

// ===================== FILE EXCEPTIONS =====================

class FileException extends AppException {
  const FileException(String message, {String? code})
    : super(message, code: code);
}

class FileSizeException extends FileException {
  final int maxSize;
  final int actualSize;

  const FileSizeException(this.maxSize, this.actualSize)
    : super('Fayl hajmi juda katta', code: 'FILE_SIZE_EXCEEDED');
}

class FileTypeException extends FileException {
  final String fileType;
  final List<String> allowedTypes;

  const FileTypeException(this.fileType, this.allowedTypes)
    : super('Noto\'g\'ri fayl formati', code: 'INVALID_FILE_TYPE');
}

class FileNotFoundException extends FileException {
  const FileNotFoundException()
    : super('Fayl topilmadi', code: 'FILE_NOT_FOUND');
}

class FileUploadException extends FileException {
  const FileUploadException(String message)
    : super(message, code: 'FILE_UPLOAD_ERROR');
}

class FileDownloadException extends FileException {
  const FileDownloadException(String message)
    : super(message, code: 'FILE_DOWNLOAD_ERROR');
}

// ===================== CACHE EXCEPTIONS =====================

class CacheException extends AppException {
  const CacheException(String message, {String? code})
    : super(message, code: code);
}

class CacheCorruptedException extends CacheException {
  const CacheCorruptedException()
    : super('Kesh ma\'lumotlari buzilgan', code: 'CACHE_CORRUPTED');
}

class CacheFullException extends CacheException {
  const CacheFullException() : super('Kesh to\'lgan', code: 'CACHE_FULL');
}

// ===================== VALIDATION EXCEPTIONS =====================

class FormValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const FormValidationException(this.fieldErrors)
    : super('Form ma\'lumotlari noto\'g\'ri', code: 'FORM_VALIDATION_ERROR');

  String? getFieldError(String fieldName) => fieldErrors[fieldName];

  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);
}

class RequiredFieldException extends AppException {
  final String fieldName;

  const RequiredFieldException(this.fieldName)
    : super('$fieldName to\'ldirilishi shart', code: 'REQUIRED_FIELD');
}

class InvalidFormatException extends AppException {
  final String fieldName;
  final String expectedFormat;

  const InvalidFormatException(this.fieldName, this.expectedFormat)
    : super(
        '$fieldName formati noto\'g\'ri. Kutilgan format: $expectedFormat',
        code: 'INVALID_FORMAT',
      );
}

// ===================== BUSINESS LOGIC EXCEPTIONS =====================

class BusinessLogicException extends AppException {
  const BusinessLogicException(String message, {String? code})
    : super(message, code: code);
}

class HomeworkOverdueException extends BusinessLogicException {
  const HomeworkOverdueException()
    : super('Vazifa muddati tugagan', code: 'HOMEWORK_OVERDUE');
}

class ExamAlreadyStartedException extends BusinessLogicException {
  const ExamAlreadyStartedException()
    : super('Imtihon allaqachon boshlangan', code: 'EXAM_STARTED');
}

class GradeAlreadySubmittedException extends BusinessLogicException {
  const GradeAlreadySubmittedException()
    : super('Baho allaqachon qo\'yilgan', code: 'GRADE_SUBMITTED');
}

class AttendanceAlreadyMarkedException extends BusinessLogicException {
  const AttendanceAlreadyMarkedException()
    : super('Davomat allaqachon belgilangan', code: 'ATTENDANCE_MARKED');
}

// ===================== PERMISSION EXCEPTIONS =====================

class PermissionException extends AppException {
  const PermissionException(String message, {String? code})
    : super(message, code: code);
}

class StoragePermissionException extends PermissionException {
  const StoragePermissionException()
    : super('Fayl saqlash uchun ruxsat kerak', code: 'STORAGE_PERMISSION');
}

class CameraPermissionException extends PermissionException {
  const CameraPermissionException()
    : super('Kamera uchun ruxsat kerak', code: 'CAMERA_PERMISSION');
}

class NotificationPermissionException extends PermissionException {
  const NotificationPermissionException()
    : super(
        'Bildirishnoma uchun ruxsat kerak',
        code: 'NOTIFICATION_PERMISSION',
      );
}

// ===================== UTILITY FUNCTIONS =====================

class ExceptionHandler {
  static String getDisplayMessage(dynamic exception) {
    if (exception is AppException) {
      return exception.message;
    } else if (exception is DioException) {
      return ApiException.fromDioException(exception).message;
    } else {
      return 'Kutilmagan xatolik yuz berdi';
    }
  }

  static String getErrorCode(dynamic exception) {
    if (exception is AppException) {
      return exception.code ?? 'UNKNOWN_ERROR';
    } else if (exception is DioException) {
      return ApiException.fromDioException(exception).code ?? 'API_ERROR';
    } else {
      return 'UNKNOWN_ERROR';
    }
  }

  static bool isNetworkError(dynamic exception) {
    return exception is NetworkException ||
        (exception is DioException &&
            [
              DioExceptionType.connectionError,
              DioExceptionType.connectionTimeout,
              DioExceptionType.receiveTimeout,
              DioExceptionType.sendTimeout,
            ].contains(exception.type));
  }

  static bool isAuthError(dynamic exception) {
    return exception is AuthException ||
        exception is UnauthorizedException ||
        (exception is ApiException && exception.statusCode == 401);
  }

  static bool isValidationError(dynamic exception) {
    return exception is ValidationException ||
        exception is FormValidationException ||
        (exception is ApiException && exception.statusCode == 422);
  }

  static bool isServerError(dynamic exception) {
    return exception is ServerException ||
        (exception is ApiException &&
            exception.statusCode != null &&
            exception.statusCode! >= 500);
  }

  static void logException(dynamic exception, {String? context}) {
    print('🔥 Exception${context != null ? ' in $context' : ''}: $exception');
    if (exception is AppException && exception.originalError != null) {
      print('🔥 Original error: ${exception.originalError}');
    }
  }
}
