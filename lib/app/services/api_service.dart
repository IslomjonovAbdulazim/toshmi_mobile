// lib/app/services/api_service.dart
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../utils/constants/api_constants.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  late AuthService _authService;

  @override
  Future<void> onInit() async {
    super.onInit();
    _authService = Get.find<AuthService>();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _authService.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Auth token added to ${options.path}');
        } else {
          print('⚠️ No auth token available for ${options.path}');
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('❌ API Error: ${error.response?.statusCode} - ${error.message}');

        // Handle 401 Unauthorized - but don't logout during login attempts
        if (error.response?.statusCode == 401) {
          _handle401Error(error);
        }

        handler.next(error);
      },
    ));

    // Add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }
  }

  // FIXED: Handle 401 errors properly
  void _handle401Error(DioException error) {
    final isLoginRequest = error.requestOptions.path.contains('/auth/login');

    if (isLoginRequest) {
      print('🔐 Login failed with 401 - invalid credentials');
      // Don't logout on login failure - let the UI handle it
      return;
    }

    print('🚪 Token expired (401) - logging out user');
    // Token is invalid/expired for other requests - logout
    _authService.logout();
  }

  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      print('📤 GET: $endpoint');
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      print('📤 POST: $endpoint');
      final response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      print('📤 PUT: $endpoint');
      final response = await _dio.put(endpoint, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      print('📤 DELETE: $endpoint');
      final response = await _dio.delete(endpoint, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      print('📤 PATCH: $endpoint');
      final response = await _dio.patch(endpoint, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // File upload
  Future<Response> uploadFile(String endpoint, String filePath, {Map<String, dynamic>? data}) async {
    try {
      print('📤 UPLOAD: $endpoint');
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post(endpoint, data: formData);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  Future<Response> downloadFile(String url, String savePath, {ProgressCallback? onReceiveProgress}) async {
    try {
      print('📤 DOWNLOAD: $url');
      final response = await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // FIXED: Better error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      print('🔍 Handling DioException: ${error.type}');

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Ulanish vaqti tugadi');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _getErrorMessage(error.response);
          print('❌ Bad response: $statusCode - $message');
          return Exception(message);

        case DioExceptionType.cancel:
          return Exception('So\'rov bekor qilindi');

        case DioExceptionType.connectionError:
          return Exception('Internet aloqasi yo\'q');

        case DioExceptionType.badCertificate:
          return Exception('SSL sertifikat xatoligi');

        case DioExceptionType.unknown:
        default:
          return Exception('Tarmoq xatoligi yuz berdi');
      }
    }

    print('❌ Unknown error: $error');
    return Exception('Noma\'lum xatolik yuz berdi: $error');
  }

  String _getErrorMessage(Response? response) {
    try {
      if (response?.data is Map) {
        final data = response!.data as Map<String, dynamic>;
        return data['detail'] ?? data['message'] ?? 'So\'rov muvaffaqiyatsiz';
      } else if (response?.data is String) {
        return response!.data;
      }
    } catch (e) {
      print('⚠️ Error parsing error message: $e');
    }

    final statusCode = response?.statusCode;
    switch (statusCode) {
      case 400:
        return 'Noto\'g\'ri so\'rov';
      case 401:
        return 'Avtorizatsiya xatoligi';
      case 403:
        return 'Ruxsat yo\'q';
      case 404:
        return 'Ma\'lumot topilmadi';
      case 422:
        return 'Ma\'lumotlar xato';
      case 500:
        return 'Server xatoligi';
      default:
        return 'So\'rov muvaffaqiyatsiz ($statusCode)';
    }
  }

  // Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    print('🔧 Base URL updated to: $newBaseUrl');
  }

  // Get current Dio instance
  Dio get dio => _dio;

  // Check if request is authenticated
  bool get isAuthenticated => _authService.isLoggedIn;

  // Get auth headers
  Map<String, String> get authHeaders {
    final token = _authService.token;
    if (token != null) {
      return {'Authorization': 'Bearer $token'};
    }
    return {};
  }
}