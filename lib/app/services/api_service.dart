import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../utils/constants/api_constants.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final AuthService _authService = Get.find<AuthService>();

  @override
  Future<void> onInit() async {
    super.onInit();
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
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // FIXED: Only logout on 401 if NOT a login attempt
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('/auth/login')) {
          _authService.logout();
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

  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(endpoint, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(endpoint, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.patch(endpoint, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // File upload
  Future<Response> uploadFile(String endpoint, String filePath, {Map<String, dynamic>? data}) async {
    try {
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
      final response = await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Ulanish vaqti tugadi');
        case DioExceptionType.badResponse:
          return Exception(_getErrorMessage(error.response));
        case DioExceptionType.cancel:
          return Exception('So\'rov bekor qilindi');
        case DioExceptionType.connectionError:
          return Exception('Internet aloqasi yo\'q');
        default:
          return Exception('Tarmoq xatoligi yuz berdi');
      }
    }
    return Exception('Noma\'lum xatolik yuz berdi');
  }

  String _getErrorMessage(Response? response) {
    try {
      if (response?.data is Map) {
        final data = response!.data as Map<String, dynamic>;
        return data['detail'] ?? data['message'] ?? 'So\'rov muvaffaqiyatsiz';
      }
    } catch (_) {}
    return 'So\'rov muvaffaqiyatsiz';
  }

  // Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Get current Dio instance
  Dio get dio => _dio;
}