// FIXED: Completely rewritten to match backend FastAPI endpoints exactly
import 'dart:io';
import '../../../core/base/base_repository.dart';
import '../models/homework_model.dart';
import '../models/exam_model.dart';
import '../../utils/constants/api_constants.dart';

class TeacherRepository extends BaseRepository {

  // ============ HOMEWORK MANAGEMENT ============

  // Get teacher's homework list (matches GET /teacher/homework)
  Future<List<dynamic>> getHomeworkList() async {
    try {
      final response = await get(ApiConstants.teacherHomework);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load homework list: $e');
    }
  }

  // Create homework (matches POST /teacher/homework)
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
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create homework: $e');
    }
  }

  // Update homework (matches PUT /teacher/homework/{homework_id})
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

  // Delete homework (matches DELETE /teacher/homework/{homework_id})
  Future<void> deleteHomework(int homeworkId) async {
    try {
      await delete('${ApiConstants.teacherHomework}/$homeworkId');
    } catch (e) {
      throw Exception('Failed to delete homework: $e');
    }
  }

  // Get homework grading table (matches GET /teacher/homework/{homework_id}/grading-table)
  Future<Map<String, dynamic>> getHomeworkGradingTable(int homeworkId) async {
    try {
      final response = await get('${ApiConstants.teacherHomework}/$homeworkId/grading-table');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load homework grading table: $e');
    }
  }

  // ============ EXAM MANAGEMENT ============

  // Get teacher's exams list (matches GET /teacher/exams)
  Future<List<dynamic>> getExamsList() async {
    try {
      final response = await get(ApiConstants.teacherExams);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load exams list: $e');
    }
  }

  // Create exam (matches POST /teacher/exams)
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
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create exam: $e');
    }
  }

  // Update exam (matches PUT /teacher/exams/{exam_id})
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

  // Delete exam (matches DELETE /teacher/exams/{exam_id})
  Future<void> deleteExam(int examId) async {
    try {
      await delete('${ApiConstants.teacherExams}/$examId');
    } catch (e) {
      throw Exception('Failed to delete exam: $e');
    }
  }

  // Get exam grading table (matches GET /teacher/exams/{exam_id}/grading-table)
  Future<Map<String, dynamic>> getExamGradingTable(int examId) async {
    try {
      final response = await get('${ApiConstants.teacherExams}/$examId/grading-table');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load exam grading table: $e');
    }
  }

  // ============ GRADING ============

  // Submit bulk homework grades (matches POST /teacher/bulk-homework-grades)
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

  // Submit bulk exam grades (matches POST /teacher/bulk-exam-grades)
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

  // ============ ATTENDANCE ============

  // Get attendance table (matches GET /teacher/attendance-table)
  Future<Map<String, dynamic>> getAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = buildQuery({
        'group_subject_id': groupSubjectId,
        'start_date': startDate,
        'end_date': endDate,
      });

      final response = await get(ApiConstants.teacherAttendanceTable, query: query);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load attendance table: $e');
    }
  }

  // Submit bulk attendance (matches POST /teacher/bulk-attendance)
  Future<void> submitBulkAttendance({
    required int groupSubjectId,
    required DateTime date,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      await post(ApiConstants.teacherBulkAttendance, {
        'group_subject_id': groupSubjectId,
        'date': date.toIso8601String().split('T')[0], // Date only format
        'records': records,
      });
    } catch (e) {
      throw Exception('Failed to submit attendance: $e');
    }
  }

  // ============ STUDENTS ============

  // Get students in a group (matches GET /teacher/groups/{group_id}/students)
  Future<List<dynamic>> getGroupStudents(int groupId) async {
    try {
      final response = await get('${ApiConstants.teacherGroups}/$groupId/students');
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load group students: $e');
    }
  }

  // ============ DASHBOARD DATA ============

  // Get teacher dashboard data (aggregated from multiple endpoints)
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // Get recent homework and exams in parallel
      final homeworkFuture = getHomeworkList();
      final examsFuture = getExamsList();

      final results = await Future.wait([homeworkFuture, examsFuture]);
      final homeworkList = results[0] as List<dynamic>;
      final examsList = results[1] as List<dynamic>;

      // Process upcoming assignments
      final now = DateTime.now();
      final upcomingHomework = homeworkList.where((h) {
        final dueDate = DateTime.parse(h['due_date']);
        return dueDate.isAfter(now);
      }).take(3).toList();

      final upcomingExams = examsList.where((e) {
        final examDate = DateTime.parse(e['exam_date']);
        return examDate.isAfter(now);
      }).take(3).toList();

      return {
        'total_homework': homeworkList.length,
        'total_exams': examsList.length,
        'upcoming_homework': upcomingHomework,
        'upcoming_exams': upcomingExams,
        'recent_homework': homeworkList.take(5).toList(),
        'recent_exams': examsList.take(5).toList(),
      };
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await put(ApiConstants.changePassword, {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  void clearCache() {
    // Clear teacher-specific cached data
  }
}