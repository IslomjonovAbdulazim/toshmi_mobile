// lib/app/modules/teacher/controllers/grading_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../utils/helpers/validation_helper.dart';

class GradingController extends BaseController {
  final TeacherRepository _repository = Get.find<TeacherRepository>();

  // Current assignment being graded
  final RxMap<String, dynamic> currentAssignment = <String, dynamic>{}.obs;
  final RxList<dynamic> students = <dynamic>[].obs;
  final RxString assignmentType = ''.obs; // 'homework' or 'exam'
  final RxInt assignmentId = 0.obs;

  // Grading data
  final RxMap<int, Map<String, dynamic>> grades = <int, Map<String, dynamic>>{}.obs;
  final RxBool isSavingGrades = false.obs;
  final RxBool hasUnsavedChanges = false.obs;

  // Bulk grading
  final RxBool isBulkGrading = false.obs;
  final bulkPointsController = TextEditingController();
  final bulkCommentController = TextEditingController();
  final RxList<int> selectedStudents = <int>[].obs;

  // Individual grading dialog
  final individualPointsController = TextEditingController();
  final individualCommentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Statistics
  final RxDouble averageGrade = 0.0.obs;
  final RxInt totalGraded = 0.obs;
  final RxInt totalStudents = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      assignmentType.value = args['type'] ?? '';
      assignmentId.value = args['assignment_id'] ?? 0;
      loadGradingTable();
    }
  }

  @override
  void onClose() {
    bulkPointsController.dispose();
    bulkCommentController.dispose();
    individualPointsController.dispose();
    individualCommentController.dispose();
    super.onClose();
  }

  // Load grading table data
  Future<void> loadGradingTable() async {
    try {
      setLoading(true);
      clearError();

      Map<String, dynamic> data;

      if (assignmentType.value == 'homework') {
        data = await _repository.getHomeworkGradingTable(assignmentId.value);
      } else {
        data = await _repository.getExamGradingTable(assignmentId.value);
      }

      currentAssignment.value = data[assignmentType.value] ?? {};
      students.assignAll(data['students'] ?? []);

      // Initialize grades map
      grades.clear();
      for (var student in students) {
        final studentId = student['student_id'] as int;
        final grade = student['grade'] as Map<String, dynamic>?;

        if (grade != null && grade['points'] != null) {
          grades[studentId] = {
            'points': grade['points'],
            'comment': grade['comment'] ?? '',
            'isNew': false,
          };
        }
      }

      _calculateStatistics();
      hasUnsavedChanges.value = false;

      print('✅ Loaded grading table - Assignment: ${currentAssignment['title']}, Students: ${students.length}');
    } catch (e) {
      setError('Baholash jadvali yuklanmadi: $e');
    } finally {
      setLoading(false);
    }
  }

  // Set grade for a student
  void setGrade(int studentId, int points, String comment) {
    final maxPoints = currentAssignment['max_points'] ?? 100;

    if (points < 0 || points > maxPoints) {
      showError('Ball 0 dan $maxPoints gacha bo\'lishi kerak');
      return;
    }

    grades[studentId] = {
      'points': points,
      'comment': comment.trim(),
      'isNew': true,
    };

    hasUnsavedChanges.value = true;
    _calculateStatistics();
  }

  // Remove grade for a student
  void removeGrade(int studentId) {
    grades.remove(studentId);
    hasUnsavedChanges.value = true;
    _calculateStatistics();
  }

  // Show individual grading dialog
  void showGradingDialog(int studentId, String studentName) {
    final existingGrade = grades[studentId];

    individualPointsController.text = existingGrade?['points']?.toString() ?? '';
    individualCommentController.text = existingGrade?['comment'] ?? '';

    Get.dialog(
      AlertDialog(
        title: Text('${studentName}ni baholash'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Assignment info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentAssignment['title'] ?? '',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('Maksimal ball: ${currentAssignment['max_points'] ?? 100}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Points input
                TextFormField(
                  controller: individualPointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ball',
                    hintText: 'Olingan ballni kiriting',
                  ),
                  validator: (value) => _validatePoints(value),
                ),
                const SizedBox(height: 16),

                // Comment input
                TextFormField(
                  controller: individualCommentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Izoh (ixtiyoriy)',
                    hintText: 'O\'qituvchi izohi...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (existingGrade != null)
            TextButton(
              onPressed: () {
                removeGrade(studentId);
                Get.back();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('O\'chirish'),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => _saveIndividualGrade(studentId),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _saveIndividualGrade(int studentId) {
    if (!formKey.currentState!.validate()) return;

    final points = int.parse(individualPointsController.text);
    final comment = individualCommentController.text.trim();

    setGrade(studentId, points, comment);
    Get.back();
    showSuccess('Ball saqlandi');
  }

  // Bulk grading
  void toggleBulkGrading() {
    isBulkGrading.value = !isBulkGrading.value;
    if (!isBulkGrading.value) {
      selectedStudents.clear();
      bulkPointsController.clear();
      bulkCommentController.clear();
    }
  }

  void toggleStudentSelection(int studentId) {
    if (selectedStudents.contains(studentId)) {
      selectedStudents.remove(studentId);
    } else {
      selectedStudents.add(studentId);
    }
  }

  void selectAllStudents() {
    selectedStudents.clear();
    selectedStudents.addAll(students.map((s) => s['student_id'] as int));
  }

  void deselectAllStudents() {
    selectedStudents.clear();
  }

  void applyBulkGrade() {
    if (selectedStudents.isEmpty) {
      showError('Kamida bitta o\'quvchini tanlang');
      return;
    }

    final pointsText = bulkPointsController.text.trim();
    if (pointsText.isEmpty) {
      showError('Ball kiriting');
      return;
    }

    final points = int.tryParse(pointsText);
    if (points == null) {
      showError('Ball raqam bo\'lishi kerak');
      return;
    }

    final maxPoints = currentAssignment['max_points'] ?? 100;
    if (points < 0 || points > maxPoints) {
      showError('Ball 0 dan $maxPoints gacha bo\'lishi kerak');
      return;
    }

    final comment = bulkCommentController.text.trim();

    for (final studentId in selectedStudents) {
      setGrade(studentId, points, comment);
    }

    showSuccess('${selectedStudents.length} ta o\'quvchi baholandi');
    toggleBulkGrading();
  }

  // Save all grades
  Future<void> saveAllGrades() async {
    if (grades.isEmpty) {
      showError('Hech qanday ball kiritilmagan');
      return;
    }

    try {
      isSavingGrades.value = true;

      final gradesList = grades.entries.map((entry) => {
        'student_id': entry.key,
        'points': entry.value['points'],
        'comment': entry.value['comment'],
      }).toList();

      if (assignmentType.value == 'homework') {
        await _repository.submitHomeworkGrades(
          homeworkId: assignmentId.value,
          grades: gradesList,
        );
      } else {
        await _repository.submitExamGrades(
          examId: assignmentId.value,
          grades: gradesList,
        );
      }

      hasUnsavedChanges.value = false;
      showSuccess('Balllar muvaffaqiyatli saqlandi');

      // Reload to get updated data
      await loadGradingTable();
    } catch (e) {
      showError('Balllarni saqlashda xatolik: $e');
    } finally {
      isSavingGrades.value = false;
    }
  }

  // Calculate statistics
  void _calculateStatistics() {
    if (grades.isEmpty) {
      averageGrade.value = 0.0;
      totalGraded.value = 0;
      totalStudents.value = students.length;
      return;
    }

    final points = grades.values.map((g) => g['points'] as int).toList();
    final sum = points.fold<int>(0, (a, b) => a + b);

    averageGrade.value = sum / points.length;
    totalGraded.value = points.length;
    totalStudents.value = students.length;
  }

  // Validation
  String? _validatePoints(String? value) {
    if (ValidationHelper.required(value, fieldName: 'Ball') != null) {
      return ValidationHelper.required(value, fieldName: 'Ball');
    }

    final points = int.tryParse(value!);
    if (points == null) {
      return 'Ball raqam bo\'lishi kerak';
    }

    final maxPoints = currentAssignment['max_points'] ?? 100;
    if (points < 0 || points > maxPoints) {
      return 'Ball 0 dan $maxPoints gacha bo\'lishi kerak';
    }

    return null;
  }

  // Helper methods
  bool hasGrade(int studentId) {
    return grades.containsKey(studentId);
  }

  Map<String, dynamic>? getGrade(int studentId) {
    return grades[studentId];
  }

  double getGradePercentage(int studentId) {
    final grade = getGrade(studentId);
    if (grade == null) return 0.0;

    final points = grade['points'] as int;
    final maxPoints = currentAssignment['max_points'] ?? 100;

    return (points / maxPoints) * 100;
  }

  String getGradeLabel(int studentId) {
    final percentage = getGradePercentage(studentId);

    if (percentage >= 90) return 'A\'lo';
    if (percentage >= 75) return 'Yaxshi';
    if (percentage >= 60) return 'Qoniqarli';
    return 'Qoniqarsiz';
  }

  Color getGradeColor(int studentId) {
    final percentage = getGradePercentage(studentId);

    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.lightGreen;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  // Grade distribution
  Map<String, int> get gradeDistribution {
    final distribution = <String, int>{
      'A\'lo': 0,
      'Yaxshi': 0,
      'Qoniqarli': 0,
      'Qoniqarsiz': 0,
    };

    for (final studentId in grades.keys) {
      final label = getGradeLabel(studentId);
      distribution[label] = (distribution[label] ?? 0) + 1;
    }

    return distribution;
  }

  @override
  Future<void> refreshData() async {
    await loadGradingTable();
  }
}