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
        title: 'Uy vazifalari',
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              controller.selectedFilter.value = value;
              controller.filterHomework();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'near_deadline', child: Text('Yaqin muddatlar')),
              const PopupMenuItem(value: 'old_deadline', child: Text('O\'tgan muddatlar')),
              const PopupMenuItem(value: 'graded', child: Text('Baholangan')),
              const PopupMenuItem(value: 'not_graded', child: Text('Baholanmagan')),
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
              // Filter indicator
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
                      '${controller.filteredHomeworkList.length} ta',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // List
              if (controller.filteredHomeworkList.isEmpty)
                const Expanded(
                  child: EmptyState(
                    title: 'Hali uy vazifalari yo\'q',
                    message: 'Birinchi uy vazifangizni yaratish uchun pastdagi tugmani bosing.',
                    icon: Icons.assignment_outlined,
                    actionText: 'Uy vazifasi yaratish',
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
        label: const Text('Yangi uy vazifasi'),
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
        title: const Text('Uy vazifasini o\'chirish'),
        content: Text('Haqiqatan ham "${homework['title']}" uy vazifasini o\'chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteHomework(homework['id']);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _gradeHomework(Map<String, dynamic> homework) {
    Get.to(() => HomeworkGradingView(homework: homework));
  }
}