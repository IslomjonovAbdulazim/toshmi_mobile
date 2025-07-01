// lib/app/modules/teacher/views/exams/exam_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exam_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import 'widgets/exam_card.dart';
import 'exam_form_view.dart';

class ExamListView extends GetView<ExamController> {
  const ExamListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: const TeacherAppBar(
        title: 'Exams',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.examsList.isEmpty) {
          return const EmptyState(
            title: 'No Exams Yet',
            message: 'Create your first exam to get started.',
            icon: Icons.quiz_outlined,
            actionText: 'Create Exam',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.examsList.length,
          itemBuilder: (context, index) {
            final exam = controller.examsList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExamCard(
                exam: exam,
                onEdit: () => _editExam(exam),
                onDelete: () => _deleteExam(exam),
                onGrade: () => _gradeExam(exam),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createExam,
        icon: const Icon(Icons.add),
        label: const Text('New Exam'),
      ),
    );
  }

  void _createExam() {
    Get.to(() => const ExamFormView());
  }

  void _editExam(Map<String, dynamic> exam) {
    Get.to(() => ExamFormView(exam: exam));
  }

  void _deleteExam(Map<String, dynamic> exam) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Are you sure you want to delete "${exam['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteExam(exam['id']);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _gradeExam(Map<String, dynamic> exam) {
    // Navigate to grading view
    Get.snackbar('Info', 'Grade exam feature coming soon');
  }
}