import 'dart:io';
import 'package:get/get.dart';

import '../../services/api_service.dart';

class ApiProvider extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    final response = await _apiService.get(endpoint, queryParameters: query);
    return Response(
      body: response.data,
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );
  }

  // POST request
  Future<Response> post(String endpoint, dynamic body, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    final response = await _apiService.post(endpoint, data: body, queryParameters: query);
    return Response(
      body: response.data,
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );
  }

  // PUT request
  Future<Response> put(String endpoint, dynamic body, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    final response = await _apiService.put(endpoint, data: body, queryParameters: query);
    return Response(
      body: response.data,
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );
  }

  // DELETE request
  Future<Response> delete(String endpoint, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    final response = await _apiService.delete(endpoint, queryParameters: query);
    return Response(
      body: response.data,
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );
  }

  // PATCH request
  Future<Response> patch(String endpoint, dynamic body, {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    final response = await _apiService.patch(endpoint, data: body, queryParameters: query);
    return Response(
      body: response.data,
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );
  }

  // File upload
  Future<Response> uploadFile(String endpoint, File file, {Map<String, dynamic>? fields, Map<String, String>? headers}) async {
    final response = await _apiService.uploadFile(endpoint, file.path, data: fields);
    return Response(
      body: response.data,
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );
  }

  // Download file
  Future<Response> downloadFile(String endpoint, String savePath, {void Function(int, int)? onProgress}) async {
    final response = await _apiService.downloadFile(endpoint, savePath, onReceiveProgress: onProgress);
    return Response(
      body: response.data,
      statusCode: response.statusCode,
      statusText: response.statusMessage,
    );
  }
}