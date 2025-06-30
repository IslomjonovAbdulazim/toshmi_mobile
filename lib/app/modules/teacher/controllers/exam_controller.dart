// lib/app/modules/teacher/controllers/exam_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';

class ExamController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;
  final examsList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadExams();
  }

  Future<void> loadExams() async {
    try {
      isLoading.value = true;
      final exams = await _teacherRepository.getExamsList();
      examsList.value = exams;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load exams: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createExam({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      isLoading.value = true;
      await _teacherRepository.createExam(
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        examDate: examDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
      Get.snackbar('Success', 'Exam created successfully');
      loadExams();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create exam: $e');
    } finally {
      isLoading.value = false;
    }
  }

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
      isLoading.value = true;
      await _teacherRepository.updateExam(
        examId: examId,
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        examDate: examDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
      Get.snackbar('Success', 'Exam updated successfully');
      loadExams();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update exam: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExam(int examId) async {
    try {
      isLoading.value = true;
      await _teacherRepository.deleteExam(examId);
      Get.snackbar('Success', 'Exam deleted successfully');
      loadExams();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete exam: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshExams() => loadExams();
}