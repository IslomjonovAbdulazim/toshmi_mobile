import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:get_storage/get_storage.dart';
import '../../app/config/app_config.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response_models.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();

  late final Dio _dio;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _setupInterceptors();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      headers: AppConfig.defaultHeaders,
    ));
  }

  void _setupInterceptors() {
    if (AppConfig.enableApiLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read<String>(CacheKeys.userToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  void _handleUnauthorized() {
    _storage.remove(CacheKeys.userToken);
    _storage.remove(CacheKeys.userProfile);
    _storage.remove(CacheKeys.userRole);
    Get.offAllNamed('/login');
  }

  // Set auth token
  void setAuthToken(String token) {
    _storage.write(CacheKeys.userToken, token);
  }

  // Clear auth token
  void clearAuthToken() {
    _storage.remove(CacheKeys.userToken);
  }

  // Generic GET request
  Future<ApiResult<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        required T Function(dynamic) fromJson,
      }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final data = fromJson(response.data);
        return ApiResult.success(data);
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: e.toString(),
        type: 'unknown',
      ));
    }
  }

  // Generic POST request
  Future<ApiResult<T>> post<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        required T Function(dynamic) fromJson,
      }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final responseData = fromJson(response.data);
        return ApiResult.success(responseData);
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: e.toString(),
        type: 'unknown',
      ));
    }
  }

  // Generic PUT request
  Future<ApiResult<T>> put<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        required T Function(dynamic) fromJson,
      }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final responseData = fromJson(response.data);
        return ApiResult.success(responseData);
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: e.toString(),
        type: 'unknown',
      ));
    }
  }

  // Generic DELETE request
  Future<ApiResult<T>> delete<T>(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        required T Function(dynamic) fromJson,
      }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final responseData = fromJson(response.data ?? {'message': 'Deleted successfully'});
        return ApiResult.success(responseData);
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: e.toString(),
        type: 'unknown',
      ));
    }
  }

  // File upload
  Future<ApiResult<T>> uploadFile<T>(
      String endpoint,
      File file, {
        String fieldName = 'file',
        Map<String, dynamic>? additionalFields,
        ProgressCallback? onSendProgress,
        required T Function(dynamic) fromJson,
      }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
        ...?additionalFields,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final data = fromJson(response.data);
        return ApiResult.success(data);
      } else {
        return _handleErrorResponse(response);
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: e.toString(),
        type: 'file_upload_error',
      ));
    }
  }

  // File download
  Future<ApiResult<String>> downloadFile(
      String endpoint,
      String savePath, {
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResult.success(savePath);
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: e.toString(),
        type: 'file_download_error',
      ));
    }
  }

  // Helper methods
  bool _isSuccessStatusCode(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  ApiResult<T> _handleErrorResponse<T>(Response response) {
    try {
      final errorData = response.data;
      if (errorData is Map<String, dynamic>) {
        return ApiResult.error(ApiError.fromJson(errorData));
      }
      return ApiResult.error(ApiError(
        detail: 'Server error: ${response.statusCode}',
        type: 'server_error',
        statusCode: response.statusCode,
      ));
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: 'Unknown server error',
        type: 'server_error',
        statusCode: response.statusCode,
      ));
    }
  }

  ApiResult<T> _handleDioException<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResult.error(ApiError.networkError('Ulanish vaqti tugadi'));

      case DioExceptionType.badResponse:
        if (e.response != null) {
          return _handleErrorResponse(e.response!);
        }
        return ApiResult.error(ApiError.serverError());

      case DioExceptionType.cancel:
        return ApiResult.error(ApiError(
          detail: 'So\'rov bekor qilindi',
          type: 'cancelled',
        ));

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return ApiResult.error(ApiError.networkError('Internetga ulanish yo\'q'));
        }
        return ApiResult.error(ApiError(
          detail: 'Noma\'lum xatolik: ${e.message}',
          type: 'unknown',
        ));

      default:
        return ApiResult.error(ApiError(
          detail: e.message ?? 'Noma\'lum xatolik',
          type: 'unknown',
        ));
    }
  }
}