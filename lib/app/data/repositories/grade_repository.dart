import '../../../core/base/base_repository.dart';
import '../models/grade_model.dart';
import '../../utils/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

class GradeRepository extends BaseRepository {
  final AuthService _authService = Get.find<AuthService>();

  // Get grades (student)
  Future<Map<String, dynamic>> getGrades() async {
    try {
      final response = await get(ApiConstants.studentGrades);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load grades: $e');
    }
  }

  // Get homework grading table (teacher)
  Future<Map<String, dynamic>> getHomeworkGradingTable(int homeworkId) async {
    try {
      final response = await get('${ApiConstants.teacherHomework}/$homeworkId/grading-table');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load homework grading table: $e');
    }
  }

  // Get exam grading table (teacher)
  Future<Map<String, dynamic>> getExamGradingTable(int examId) async {
    try {
      final response = await get('${ApiConstants.teacherExams}/$examId/grading-table');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load exam grading table: $e');
    }
  }

  // Submit bulk homework grades (teacher) - FIXED
  Future<void> submitHomeworkGrades({
    required int homeworkId,
    required List<Map<String, dynamic>> grades,
  }) async {
    try {
      await post(ApiConstants.teacherBulkHomeworkGrades, {
        'homework_id': homeworkId,
        'grades': grades,
      });
    } catch (e) {
      throw Exception('Failed to submit homework grades: $e');
    }
  }

  // Submit bulk exam grades (teacher) - FIXED
  Future<void> submitExamGrades({
    required int examId,
    required List<Map<String, dynamic>> grades,
  }) async {
    try {
      await post(ApiConstants.teacherBulkExamGrades, {
        'exam_id': examId,
        'grades': grades,
      });
    } catch (e) {
      throw Exception('Failed to submit exam grades: $e');
    }
  }

  // Submit single grade (teacher)
  Future<void> submitSingleGrade({
    required String type, // 'homework' or 'exam'
    required int assignmentId,
    required int studentId,
    required int points,
    String comment = '',
  }) async {
    try {
      if (type == 'homework') {
        await submitHomeworkGrades(
          homeworkId: assignmentId,
          grades: [{
            'student_id': studentId,
            'points': points,
            'comment': comment,
          }],
        );
      } else {
        await submitExamGrades(
          examId: assignmentId,
          grades: [{
            'student_id': studentId,
            'points': points,
            'comment': comment,
          }],
        );
      }
    } catch (e) {
      throw Exception('Failed to submit grade: $e');
    }
  }

  // Get child grades (parent)
  Future<Map<String, dynamic>> getChildGrades(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildren}/$childId/grades');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load child grades: $e');
    }
  }

  // Get grade statistics
  Future<Map<String, dynamic>> getGradeStatistics() async {
    try {
      final gradesData = await getGrades();
      final homeworkGrades = gradesData['homework_grades'] as List<dynamic>;
      final examGrades = gradesData['exam_grades'] as List<dynamic>;

      double homeworkAverage = 0;
      double examAverage = 0;
      double overallAverage = 0;

      if (homeworkGrades.isNotEmpty) {
        final homeworkPercentages = homeworkGrades.map((g) => g['percentage'] as double).toList();
        homeworkAverage = homeworkPercentages.reduce((a, b) => a + b) / homeworkPercentages.length;
      }

      if (examGrades.isNotEmpty) {
        final examPercentages = examGrades.map((g) => g['percentage'] as double).toList();
        examAverage = examPercentages.reduce((a, b) => a + b) / examPercentages.length;
      }

      final allGrades = [...homeworkGrades, ...examGrades];
      if (allGrades.isNotEmpty) {
        final allPercentages = allGrades.map((g) => g['percentage'] as double).toList();
        overallAverage = allPercentages.reduce((a, b) => a + b) / allPercentages.length;
      }

      return {
        'homework_average': homeworkAverage,
        'exam_average': examAverage,
        'overall_average': overallAverage,
        'total_assignments': allGrades.length,
        'homework_count': homeworkGrades.length,
        'exam_count': examGrades.length,
      };
    } catch (e) {
      throw Exception('Failed to calculate grade statistics: $e');
    }
  }

  // Get recent grades
  Future<List<dynamic>> getRecentGrades({int limit = 5}) async {
    try {
      final gradesData = await getGrades();
      final homeworkGrades = gradesData['homework_grades'] as List<dynamic>;
      final examGrades = gradesData['exam_grades'] as List<dynamic>;

      final allGrades = [...homeworkGrades, ...examGrades];
      allGrades.sort((a, b) {
        final aDate = DateTime.parse(a['graded_at']);
        final bDate = DateTime.parse(b['graded_at']);
        return bDate.compareTo(aDate);
      });

      return allGrades.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to load recent grades: $e');
    }
  }

  // Get grades by subject
  Future<Map<String, List<dynamic>>> getGradesBySubject() async {
    try {
      final gradesData = await getGrades();
      final homeworkGrades = gradesData['homework_grades'] as List<dynamic>;
      final examGrades = gradesData['exam_grades'] as List<dynamic>;

      final gradesBySubject = <String, List<dynamic>>{};

      for (final grade in homeworkGrades) {
        final subject = grade['subject'] as String;
        gradesBySubject[subject] ??= [];
        gradesBySubject[subject]!.add({...grade, 'type': 'homework'});
      }

      for (final grade in examGrades) {
        final subject = grade['subject'] as String;
        gradesBySubject[subject] ??= [];
        gradesBySubject[subject]!.add({...grade, 'type': 'exam'});
      }

      return gradesBySubject;
    } catch (e) {
      throw Exception('Failed to group grades by subject: $e');
    }
  }

  @override
  void clearCache() {
    // Clear cached grade data
  }
}