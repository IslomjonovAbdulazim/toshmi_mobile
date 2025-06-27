import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import '../../app/data/providers/api_provider.dart';
import '../../app/services/auth_service.dart';

abstract class BaseRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AuthService _authService = Get.find<AuthService>();

  // HTTP Methods
  Future<Response> get(String endpoint, {Map<String, dynamic>? query}) async {
    return await _handleRequest(() => _apiProvider.get(
      endpoint,
      query: query,
      headers: _getHeaders(),
    ));
  }

  Future<Response> post(String endpoint, dynamic body, {Map<String, dynamic>? query}) async {
    return await _handleRequest(() => _apiProvider.post(
      endpoint,
      body,
      query: query,
      headers: _getHeaders(),
    ));
  }

  Future<Response> put(String endpoint, dynamic body, {Map<String, dynamic>? query}) async {
    return await _handleRequest(() => _apiProvider.put(
      endpoint,
      body,
      query: query,
      headers: _getHeaders(),
    ));
  }

  Future<Response> delete(String endpoint, {Map<String, dynamic>? query}) async {
    return await _handleRequest(() => _apiProvider.delete(
      endpoint,
      query: query,
      headers: _getHeaders(),
    ));
  }

  Future<Response> patch(String endpoint, dynamic body, {Map<String, dynamic>? query}) async {
    return await _handleRequest(() => _apiProvider.patch(
      endpoint,
      body,
      query: query,
      headers: _getHeaders(),
    ));
  }

  // File upload
  Future<Response> uploadFile(String endpoint, File file, {Map<String, dynamic>? fields}) async {
    return await _handleRequest(() => _apiProvider.uploadFile(
      endpoint,
      file,
      fields: fields,
      headers: _getHeaders(),
    ));
  }

  // Common headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _authService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Request handler with error handling
  Future<Response> _handleRequest(Future<Response> Function() request) async {
    try {
      final response = await request();
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Request failed: $e');
    }
  }

  // Response handler
  Response _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        return response;
      case 400:
        throw BadRequestException(_getErrorMessage(response));
      case 401:
        _authService.logout();
        throw UnauthorizedException('Session expired');
      case 403:
        throw ForbiddenException('Access denied');
      case 404:
        throw NotFoundException('Resource not found');
      case 422:
        throw ValidationException(_getErrorMessage(response));
      case 429:
        throw TooManyRequestsException('Too many requests');
      case 500:
      case 502:
      case 503:
        throw ServerException('Server error');
      default:
        throw ApiException('Request failed with status: ${response.statusCode}');
    }
  }

  // Extract error message from response
  String _getErrorMessage(Response response) {
    try {
      if (response.body is String) {
        final data = jsonDecode(response.body);
        return data['detail'] ?? data['message'] ?? 'Request failed';
      } else if (response.body is Map) {
        final data = response.body as Map<String, dynamic>;
        return data['detail'] ?? data['message'] ?? 'Request failed';
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return 'Request failed';
  }

  // Pagination helper
  Map<String, dynamic> buildPaginationQuery({int page = 1, int limit = 20}) {
    return {
      'skip': (page - 1) * limit,
      'limit': limit,
    };
  }

  // Query parameter helpers
  Map<String, dynamic> buildQuery(Map<String, dynamic> params) {
    final query = <String, dynamic>{};
    params.forEach((key, value) {
      if (value != null) {
        if (value is DateTime) {
          query[key] = value.toIso8601String();
        } else if (value is List) {
          query[key] = value.join(',');
        } else {
          query[key] = value.toString();
        }
      }
    });
    return query;
  }

  // Data parsing helpers
  List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  T? parseObject<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is Map<String, dynamic>) {
      return fromJson(data);
    }
    return null;
  }

  // Cache management (override in child repositories if needed)
  String? getCacheKey(String endpoint, [Map<String, dynamic>? params]) {
    if (params?.isNotEmpty == true) {
      final sortedParams = Map.fromEntries(
          params!.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
      );
      return '$endpoint?${Uri(queryParameters: sortedParams.map((k, v) => MapEntry(k, v.toString()))).query}';
    }
    return endpoint;
  }

  void clearCache() {
    // Override in child repositories
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class TooManyRequestsException extends ApiException {
  TooManyRequestsException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}