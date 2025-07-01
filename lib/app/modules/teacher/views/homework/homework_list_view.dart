// lib/app/modules/teacher/views/homework/homework_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/homework_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import 'widgets/homework_card.dart';
import 'homework_form_view.dart';
import '../grading/homework_grading_view.dart';

class HomeworkListView extends GetView<HomeworkController> {
  const HomeworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'homework_title'.tr,
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.selectedFilter.value = value;
              controller.filterHomework();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'near_deadline', child: Text('near_deadline'.tr)),
              PopupMenuItem(value: 'old_deadline', child: Text('old_deadline'.tr)),
              PopupMenuItem(value: 'graded', child: Text('graded'.tr)),
              PopupMenuItem(value: 'not_graded', child: Text('not_graded'.tr)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshHomework,
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
                      '${controller.filteredHomeworkList.length} ${'total_items'.tr}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (controller.filteredHomeworkList.isEmpty)
                Expanded(
                  child: EmptyState(
                    title: 'no_homework_yet'.tr,
                    message: 'create_first_homework'.tr,
                    icon: Icons.assignment_outlined,
                    actionText: 'create_homework'.tr,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
                    itemCount: controller.filteredHomeworkList.length,
                    itemBuilder: (context, index) {
                      final homework = controller.filteredHomeworkList[index];
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
                ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createHomework,
        icon: const Icon(Icons.add),
        label: Text('new_homework'.tr),
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
        title: Text('delete_homework'.tr),
        content: Text('${'delete_homework_confirmation'.tr}\n"${homework['title']}"'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteHomework(homework['id']);
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

  void _gradeHomework(Map<String, dynamic> homework) {
    Get.to(() => HomeworkGradingView(homework: homework));
  }
}