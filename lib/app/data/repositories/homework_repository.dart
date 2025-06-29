// lib/app/data/repositories/homework_repository.dart
import 'dart:io';
import '../../../core/base/base_repository.dart';
import '../models/homework_model.dart';
import '../../utils/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

class HomeworkRepository extends BaseRepository {
  final AuthService _authService = Get.find<AuthService>();

  // Get homework (role-based endpoint selection)
  Future<List<dynamic>> getHomework() async {
    try {
      String endpoint;
      switch (_authService.userRole?.toLowerCase()) {
        case 'teacher':
          endpoint = ApiConstants.teacherHomework;
          break;
        case 'student':
          endpoint = ApiConstants.studentHomework;
          break;
        default:
          throw Exception('Invalid role for homework access');
      }

      final response = await get(endpoint);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load homework: $e');
    }
  }

  // Create homework (teacher only)
  Future<Map<String, dynamic>> createHomework({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      final response = await post(ApiConstants.teacherHomework, {
        'group_subject_id': groupSubjectId,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'max_points': maxPoints,
        'external_links': externalLinks,
      });

      // CRITICAL FIX: Backend returns {"message": "Homework created", "id": homework.id}
      // No endpoint exists to fetch full homework by ID, so return the response data
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create homework: $e');
    }
  }

  // Update homework (teacher only)
  Future<void> updateHomework({
    required int homeworkId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      await put('${ApiConstants.teacherHomework}/$homeworkId', {
        'group_subject_id': groupSubjectId,
        'title': title,
        'description': description,
        'due_date': dueDate.toIso8601String(),
        'max_points': maxPoints,
        'external_links': externalLinks,
      });
    } catch (e) {
      throw Exception('Failed to update homework: $e');
    }
  }

  // Delete homework (teacher only)
  Future<void> deleteHomework(int homeworkId) async {
    try {
      await delete('${ApiConstants.teacherHomework}/$homeworkId');
    } catch (e) {
      throw Exception('Failed to delete homework: $e');
    }
  }

  // CRITICAL FIX: Backend GET /teacher/homework returns simplified format
  // Cannot create full Homework objects, only simplified data
  Future<Map<String, dynamic>?> findHomeworkById(int homeworkId) async {
    try {
      final homeworkList = await getHomework();
      return homeworkList.firstWhereOrNull(
            (h) => h['id'] == homeworkId,
      );
    } catch (e) {
      throw Exception('Failed to find homework: $e');
    }
  }

  // Get child homework (parent)
  Future<List<dynamic>> getChildHomework(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildren}/$childId/homework');
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load child homework: $e');
    }
  }

  // Upload homework document
  Future<void> uploadHomeworkDocument(int homeworkId, File file) async {
    try {
      await uploadFile('${ApiConstants.filesHomework}/$homeworkId/upload', file);
    } catch (e) {
      throw Exception('Failed to upload homework document: $e');
    }
  }

  @override
  void clearCache() {
    // Clear cached homework data
  }
}