// lib/app/modules/teacher/views/exams/exam_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exam_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import 'widgets/exam_card.dart';
import 'exam_form_view.dart';
import '../grading/exam_grading_view.dart';

class ExamListView extends GetView<ExamController> {
  const ExamListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'exam_title'.tr,
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.selectedFilter.value = value;
              controller.filterExams();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'near_deadline', child: Text('near_dates'.tr)),
              PopupMenuItem(value: 'old_deadline', child: Text('old_dates'.tr)),
              PopupMenuItem(value: 'graded', child: Text('graded'.tr)),
              PopupMenuItem(value: 'not_graded', child: Text('not_graded'.tr)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshExams,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.getFilterDisplayText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${controller.filteredExamsList.length} ${'total_items'.tr}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (controller.filteredExamsList.isEmpty)
                Expanded(
                  child: EmptyState(
                    title: 'no_exams_yet'.tr,
                    message: 'create_first_exam'.tr,
                    icon: Icons.quiz_outlined,
                    actionText: 'create_exam'.tr,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
                    itemCount: controller.filteredExamsList.length,
                    itemBuilder: (context, index) {
                      final exam = controller.filteredExamsList[index];
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
                  ),
                ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createExam,
        icon: const Icon(Icons.add),
        label: Text('new_exam'.tr),
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
        title: Text('delete_exam'.tr),
        content: Text('${'delete_exam_confirmation'.tr}\n"${exam['title']}"'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteExam(exam['id']);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  void _gradeExam(Map<String, dynamic> exam) {
    Get.to(() => ExamGradingView(exam: exam));
  }
}