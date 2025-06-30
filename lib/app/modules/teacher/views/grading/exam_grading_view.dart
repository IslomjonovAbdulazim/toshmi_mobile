// lib/app/modules/teacher/views/grading/exam_grading_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/grading_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import 'widgets/grading_table.dart';

class ExamGradingView extends GetView<GradingController> {
  final int examId;

  const ExamGradingView({super.key, required this.examId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grades = <int, Map<String, dynamic>>{}.obs;

    // Load grading table when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadExamGradingTable(examId);
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'Grade Exam',
        actions: [
          TextButton(
            onPressed: () => _saveGrades(grades),
            child: const Text('Save Grades'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.gradingData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load grading data',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GradingTable(
            gradingData: controller.gradingData,
            grades: grades,
            onGradeChanged: (studentId, points, comment) {
              grades[studentId] = {
                'points': points,
                'comment': comment,
              };
            },
          ),
        );
      }),
      floatingActionButton: Obx(() {
        final hasUnsavedGrades = grades.isNotEmpty;

        return hasUnsavedGrades
            ? FloatingActionButton.extended(
          onPressed: () => _saveGrades(grades),
          icon: const Icon(Icons.save),
          label: const Text('Save Grades'),
          backgroundColor: theme.colorScheme.primary,
        )
            : const SizedBox.shrink();
      }),
    );
  }

  void _saveGrades(Map<int, Map<String, dynamic>> grades) {
    if (grades.isEmpty) {
      Get.snackbar('Info', 'No grades to save');
      return;
    }

    // Convert grades to the format expected by the API
    final gradesList = grades.entries
        .where((entry) => entry.value['points'] != null)
        .map((entry) => {
      'student_id': entry.key,
      'points': entry.value['points'],
      'comment': entry.value['comment'] ?? '',
    })
        .toList();

    if (gradesList.isEmpty) {
      Get.snackbar('Info', 'No valid grades to save');
      return;
    }

    controller.submitExamGrades(
      examId: examId,
      grades: gradesList,
    ).then((_) {
      grades.clear();
      Get.snackbar('Success', 'Grades saved successfully');
    });
  }
}