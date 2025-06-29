import '../../../core/base/base_repository.dart';
import '../models/exam_model.dart';
import '../../utils/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

class ExamRepository extends BaseRepository {
  final AuthService _authService = Get.find<AuthService>();

  // Get exams (role-based endpoint selection)
  Future<List<Exam>> getExams() async {
    try {
      String endpoint;
      switch (_authService.userRole?.toLowerCase()) {
        case 'teacher':
          endpoint = ApiConstants.teacherExams;
          break;
        case 'student':
          endpoint = ApiConstants.studentExams;
          break;
        default:
          throw Exception('Invalid role for exam access');
      }

      final response = await get(endpoint);
      return parseList(response.body, Exam.fromJson);
    } catch (e) {
      throw Exception('Failed to load exams: $e');
    }
  }

  // Create exam (teacher only)
  Future<Map<String, dynamic>> createExam({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      final response = await post(ApiConstants.teacherExams, {
        'group_subject_id': groupSubjectId,
        'title': title,
        'description': description,
        'exam_date': examDate.toIso8601String(),
        'max_points': maxPoints,
        'external_links': externalLinks,
      });

      // CRITICAL FIX: Backend returns {"message": "Exam created", "id": exam.id}
      // No endpoint exists to fetch exam by ID, so return the response data
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create exam: $e');
    }
  }

  // Update exam (teacher only)
  Future<void> updateExam({
    required int examId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      await put('${ApiConstants.teacherExams}/$examId', {
        'group_subject_id': groupSubjectId,
        'title': title,
        'description': description,
        'exam_date': examDate.toIso8601String(),
        'max_points': maxPoints,
        'external_links': externalLinks,
      });
    } catch (e) {
      throw Exception('Failed to update exam: $e');
    }
  }

  // Delete exam (teacher only)
  Future<void> deleteExam(int examId) async {
    try {
      await delete('${ApiConstants.teacherExams}/$examId');
    } catch (e) {
      throw Exception('Failed to delete exam: $e');
    }
  }

  // CRITICAL FIX: Remove getExamById - no such endpoint exists in backend
  // Get exam by ID from cached list
  Future<Exam?> findExamById(int examId) async {
    try {
      final exams = await getExams();
      return exams.firstWhereOrNull((e) => e.id == examId);
    } catch (e) {
      throw Exception('Failed to find exam: $e');
    }
  }

  // Get upcoming exams
  Future<List<Exam>> getUpcomingExams({int limit = 5}) async {
    try {
      final exams = await getExams();
      final now = DateTime.now();

      final upcomingExams = exams
          .where((exam) => exam.examDate.isAfter(now))
          .toList()
        ..sort((a, b) => a.examDate.compareTo(b.examDate));

      return upcomingExams.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to load upcoming exams: $e');
    }
  }

  // Get past exams
  Future<List<Exam>> getPastExams({int limit = 10}) async {
    try {
      final exams = await getExams();
      final now = DateTime.now();

      final pastExams = exams
          .where((exam) => exam.examDate.isBefore(now))
          .toList()
        ..sort((a, b) => b.examDate.compareTo(a.examDate));

      return pastExams.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to load past exams: $e');
    }
  }

  // Get child exams (parent)
  Future<List<dynamic>> getChildExams(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildren}/$childId/exams');
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load child exams: $e');
    }
  }

  // Get exams by subject
  Future<List<Exam>> getExamsBySubject(String subjectName) async {
    try {
      final exams = await getExams();
      return exams; // Filter by subject would require additional API data
    } catch (e) {
      throw Exception('Failed to load exams by subject: $e');
    }
  }

  // Get exams by date range
  Future<List<Exam>> getExamsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final exams = await getExams();

      return exams.where((exam) {
        if (startDate != null && exam.examDate.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && exam.examDate.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load exams by date range: $e');
    }
  }

  @override
  void clearCache() {
    // Clear cached exam data
  }
}