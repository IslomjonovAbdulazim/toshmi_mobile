// lib/app/modules/teacher/views/homework/homework_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/homework_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import 'widgets/homework_card.dart';
import 'homework_form_view.dart';

class HomeworkListView extends GetView<HomeworkController> {
  const HomeworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: const TeacherAppBar(
        title: 'Homework',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.homeworkList.isEmpty) {
          return const EmptyState(
            title: 'No Homework Yet',
            message: 'Create your first homework assignment to get started.',
            icon: Icons.assignment_outlined,
            actionText: 'Create Homework',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshHomework(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.homeworkList.length,
            itemBuilder: (context, index) {
              final homework = controller.homeworkList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HomeworkCard(
                  homework: homework,
                  onEdit: () => _editHomework(homework),
                  onDelete: () => _deleteHomework(homework),
                  onGrade: () => _gradeHomework(homework),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createHomework,
        icon: const Icon(Icons.add),
        label: const Text('New Homework'),
      ),
    );
  }

  void _createHomework() {
    Get.to(() => const HomeworkFormView());
  }

  void _editHomework(Map<String, dynamic> homework) {
    Get.to(() => HomeworkFormView(homework: homework));
  }

  void _deleteHomework(Map<String, dynamic> homework) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Homework'),
        content: Text('Are you sure you want to delete "${homework['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteHomework(homework['id']);
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

  void _gradeHomework(Map<String, dynamic> homework) {
    // Navigate to grading view
    Get.snackbar('Info', 'Grade homework feature coming soon');
  }
}