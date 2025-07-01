// lib/app/modules/teacher/controllers/grading_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';

class GradingController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final gradingData = <String, dynamic>{}.obs;
  final grades = <int, Map<String, dynamic>>{}.obs; // student_id -> {points, comment}

  @override
  void onInit() {
    super.onInit();
    // Initialize grades map when grading data changes
    ever(gradingData, (data) {
      if (data.isNotEmpty && data['students'] != null) {
        grades.clear();
        for (var student in data['students']) {
          grades[student['student_id']] = {
            'points': student['grade']['points'],
            'comment': student['grade']['comment'] ?? '',
          };
        }
      }
    });
  }

  // Load homework grading table
  Future<void> loadHomeworkGradingTable(int homeworkId) async {
    try {
      isLoading.value = true;
      final data = await _teacherRepository.getHomeworkGradingTable(homeworkId);
      gradingData.value = data;
    } catch (e) {
      Get.snackbar('Xato', 'Baholash jadvalini yuklashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load exam grading table
  Future<void> loadExamGradingTable(int examId) async {
    try {
      isLoading.value = true;
      final data = await _teacherRepository.getExamGradingTable(examId);
      gradingData.value = data;
    } catch (e) {
      Get.snackbar('Xato', 'Baholash jadvalini yuklashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update grade for a student
  void updateGrade(int studentId, {int? points, String? comment}) {
    final currentGrade = grades[studentId] ?? {'points': null, 'comment': ''};
    grades[studentId] = {
      'points': points ?? currentGrade['points'],
      'comment': comment ?? currentGrade['comment'],
    };
  }

  // Get grade for a student
  Map<String, dynamic>? getGrade(int studentId) {
    return grades[studentId];
  }

  // Check if all grades are valid
  bool validateGrades() {
    final maxPoints = gradingData['homework']?['max_points'] ??
        gradingData['exam']?['max_points'] ?? 100;

    for (var studentGrade in grades.values) {
      final points = studentGrade['points'];
      if (points != null && (points < 0 || points > maxPoints)) {
        return false;
      }
    }
    return true;
  }

  // Get grades that have been modified
  List<Map<String, dynamic>> getModifiedGrades() {
    final modifiedGrades = <Map<String, dynamic>>[];

    for (var entry in grades.entries) {
      final studentId = entry.key;
      final grade = entry.value;

      // Only include grades that have points set
      if (grade['points'] != null) {
        modifiedGrades.add({
          'student_id': studentId,
          'points': grade['points'],
          'comment': grade['comment'] ?? '',
        });
      }
    }

    return modifiedGrades;
  }

  // Submit homework grades
  Future<void> submitHomeworkGrades(int homeworkId) async {
    if (!validateGrades()) {
      Get.snackbar('Xato', 'Noto\'g\'ri balllar kiritilgan');
      return;
    }

    final modifiedGrades = getModifiedGrades();
    if (modifiedGrades.isEmpty) {
      Get.snackbar('Ogohlantirish', 'Hech qanday ball kiritilmagan');
      return;
    }

    try {
      isSaving.value = true;
      await _teacherRepository.submitHomeworkGrades(
        homeworkId: homeworkId,
        grades: modifiedGrades,
      );
      Get.snackbar(
        'Muvaffaqiyat',
        'Balllar muvaffaqiyatli saqlandi',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      Get.back(result: 'refresh');
    } catch (e) {
      Get.snackbar('Xato', 'Balllarni saqlashda xatolik: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Submit exam grades
  Future<void> submitExamGrades(int examId) async {
    if (!validateGrades()) {
      Get.snackbar('Xato', 'Noto\'g\'ri balllar kiritilgan');
      return;
    }

    final modifiedGrades = getModifiedGrades();
    if (modifiedGrades.isEmpty) {
      Get.snackbar('Ogohlantirish', 'Hech qanday ball kiritilmagan');
      return;
    }

    try {
      isSaving.value = true;
      await _teacherRepository.submitExamGrades(
        examId: examId,
        grades: modifiedGrades,
      );
      Get.snackbar(
        'Muvaffaqiyat',
        'Balllar muvaffaqiyatli saqlandi',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      Get.back(result: 'refresh');
    } catch (e) {
      Get.snackbar('Xato', 'Balllarni saqlashda xatolik: $e');
    } finally {
      isSaving.value = false;
    }
  }

  // Clear all data
  void clearData() {
    gradingData.clear();
    grades.clear();
  }
}