// lib/app/modules/teacher/controllers/grading_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';

class GradingController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;
  final gradingData = <String, dynamic>{}.obs;

  Future<void> loadHomeworkGradingTable(int homeworkId) async {
    try {
      isLoading.value = true;
      final data = await _teacherRepository.getHomeworkGradingTable(homeworkId);
      gradingData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load grading table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadExamGradingTable(int examId) async {
    try {
      isLoading.value = true;
      final data = await _teacherRepository.getExamGradingTable(examId);
      gradingData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load grading table: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitHomeworkGrades({
    required int homeworkId,
    required List<Map<String, dynamic>> grades,
  }) async {
    try {
      isLoading.value = true;
      await _teacherRepository.submitHomeworkGrades(
        homeworkId: homeworkId,
        grades: grades,
      );
      Get.snackbar('Success', 'Homework grades submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit grades: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitExamGrades({
    required int examId,
    required List<Map<String, dynamic>> grades,
  }) async {
    try {
      isLoading.value = true;
      await _teacherRepository.submitExamGrades(
        examId: examId,
        grades: grades,
      );
      Get.snackbar('Success', 'Exam grades submitted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit grades: $e');
    } finally {
      isLoading.value = false;
    }
  }
}