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
        title: 'Uy vazifalari',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshHomework(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.homeworkList.isEmpty) {
            return const EmptyState(
              title: 'Hali uy vazifalari yo\'q',
              message: 'Birinchi uy vazifangizni yaratish uchun boshlang.',
              icon: Icons.assignment_outlined,
              actionText: 'Uy vazifasi yaratish',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.homeworkList.length,
            itemBuilder: (context, index) {
              final homework = controller.homeworkList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HomeworkCard(
                  homework: homework,
                  onTap: () => _viewHomework(homework),
                  onEdit: () => _editHomework(homework),
                  onDelete: () => _deleteHomework(homework),
                  onGrade: () => _gradeHomework(homework),
                ),
              );
            },
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

  void _viewHomework(Map<String, dynamic> homework) {
    // Show homework details in a bottom sheet or new page
    _showHomeworkDetails(homework);
  }

  void _editHomework(Map<String, dynamic> homework) {
    Get.to(() => HomeworkFormView(homework: homework));
  }

  void _deleteHomework(Map<String, dynamic> homework) {
    Get.dialog(
      AlertDialog(
        title: const Text('Uy vazifasini o\'chirish'),
        content: Text('Bu uy vazifasini o\'chirishga ishonchingiz komilmi?\n\n"${homework['title']}"'),
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
    // Navigate to grading view
    Get.snackbar(
      'Ma\'lumot',
      'Baholash imkoniyati tez orada qo\'shiladi',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showHomeworkDetails(Map<String, dynamic> homework) {
    final theme = Get.theme;
    final dueDate = DateTime.parse(homework['due_date']);
    final externalLinks = homework['external_links'] as List<dynamic>? ?? [];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              homework['title'] ?? 'Uy vazifasi',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subject and Group
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${homework['subject']} • ${homework['group']}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            if (homework['description'] != null && homework['description'].toString().isNotEmpty) ...[
              Text(
                'Tavsif',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  homework['description'],
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Due date and points
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    theme,
                    icon: Icons.schedule,
                    title: 'Muddati',
                    value: '${dueDate.day}/${dueDate.month}/${dueDate.year}\n${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    theme,
                    icon: Icons.star,
                    title: 'Maksimal ball',
                    value: '${homework['max_points']} ball',
                  ),
                ),
              ],
            ),

            // External links
            if (externalLinks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tashqi havolalar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...externalLinks.take(3).map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $link',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )),
              if (externalLinks.length > 3)
                Text(
                  '• +${externalLinks.length - 3} yana havolalar',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _editHomework(homework);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Tahrirlash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Get.back();
                      _gradeHomework(homework);
                    },
                    icon: const Icon(Icons.grade),
                    label: const Text('Baholash'),
                  ),
                ),
              ],
            ),

            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildInfoCard(ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}