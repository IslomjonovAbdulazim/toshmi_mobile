import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response_models.dart';

class ApiService extends getx.GetxService {
  static ApiService get to => getx.Get.find();

  late final Dio _dio;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: ApiConstants.defaultHeaders,
      validateStatus: (status) => status != null && status < 500,
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = _storage.read<String>(CacheKeys.userToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Log request
        _logRequest(options);
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        _logResponse(response);
        handler.next(response);
      },
      onError: (error, handler) {
        // Log error
        _logError(error);

        // Handle specific errors
        final processedError = _processError(error);
        handler.next(processedError);
      },
    ));

    // Token refresh interceptor (if needed)
    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  void _logRequest(RequestOptions options) {
    print('🚀 REQUEST: ${options.method} ${options.uri}');
    if (options.data != null) {
      print('📤 DATA: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('📋 PARAMS: ${options.queryParameters}');
    }
  }

  void _logResponse(Response response) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    if (response.data != null) {
      print('📥 DATA: ${response.data}');
    }
  }

  void _logError(DioException error) {
    print('❌ ERROR: ${error.type} ${error.requestOptions.uri}');
    print('📄 MESSAGE: ${error.message}');
    if (error.response?.data != null) {
      print('📥 ERROR DATA: ${error.response!.data}');
    }
  }

  DioException _processError(DioException error) {
    // Add custom error processing here
    return error;
  }

  Future<void> _handleUnauthorized() async {
    // Clear user data and redirect to login
    await _storage.remove(CacheKeys.userToken);
    await _storage.remove(CacheKeys.userProfile);
    await _storage.remove(CacheKeys.userRole);

    // Navigate to login (implement based on your routing)
    getx.Get.offAllNamed('/login');
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

      if (response.statusCode == 200 || response.statusCode == 201) {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
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

      if (response.statusCode == 200 || response.statusCode == 204) {
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

  // File upload request
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
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?additionalFields,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  // Download file
  Future<ApiResult<String>> downloadFile(
      String endpoint,
      String savePath, {
        ProgressCallback? onReceiveProgress,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
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

  // Handle error responses
  ApiResult<T> _handleErrorResponse<T>(Response response) {
    String errorMessage = ErrorMessages.serverError;

    try {
      if (response.data is Map<String, dynamic>) {
        errorMessage = response.data['detail'] ??
            response.data['message'] ??
            errorMessage;
      } else if (response.data is String) {
        errorMessage = response.data;
      }
    } catch (e) {
      // Keep default error message
    }

    return ApiResult.error(ApiError(
      detail: errorMessage,
      statusCode: response.statusCode,
      type: 'http_error',
    ));
  }

  // Handle Dio exceptions
  ApiResult<T> _handleDioException<T>(DioException e) {
    late String errorMessage;
    late String errorType;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = ErrorMessages.connectionTimeout;
        errorType = 'timeout';
        break;

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        errorType = 'http_error';

        switch (statusCode) {
          case 400:
            errorMessage = ErrorMessages.validationError;
            break;
          case 401:
            errorMessage = ErrorMessages.unauthorizedAccess;
            errorType = 'auth_error';
            break;
          case 403:
            errorMessage = ErrorMessages.permissionDenied;
            break;
          case 404:
            errorMessage = ErrorMessages.dataNotFound;
            break;
          case 422:
            errorMessage = ErrorMessages.validationError;
            break;
          default:
            errorMessage = ErrorMessages.serverError;
        }

        // Try to extract detailed error message
        try {
          if (e.response?.data is Map<String, dynamic>) {
            final data = e.response!.data as Map<String, dynamic>;
            errorMessage = data['detail'] ?? data['message'] ?? errorMessage;
          }
        } catch (_) {
          // Keep default message
        }
        break;

      case DioExceptionType.cancel:
        errorMessage = 'So\'rov bekor qilindi';
        errorType = 'cancelled';
        break;

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          errorMessage = ErrorMessages.networkError;
          errorType = 'network';
        } else {
          errorMessage = ErrorMessages.serverError;
          errorType = 'unknown';
        }
        break;
    }

    return ApiResult.error(ApiError(
      detail: errorMessage,
      statusCode: e.response?.statusCode,
      type: errorType,
    ));
  }

  // Check internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get(
        PublicEndpoints.health,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Clear all stored data
  Future<void> clearStorage() async {
    await _storage.erase();
  }

  // Update base URL (if needed)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  // Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  // Set auth token
  void setAuthToken(String token) {
    _storage.write(CacheKeys.userToken, token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear auth token
  void clearAuthToken() {
    _storage.remove(CacheKeys.userToken);
    _dio.options.headers.remove('Authorization');
  }

  // Get current auth token
  String? get authToken => _storage.read<String>(CacheKeys.userToken);

  // Check if user is authenticated
  bool get isAuthenticated => authToken != null;
}