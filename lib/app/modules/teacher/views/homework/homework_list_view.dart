import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/loading_widget.dart';
import '../../../../utils/widgets/common/error_widget.dart';
import '../../../../utils/widgets/common/empty_state_widget.dart';
import '../../../../utils/widgets/common/custom_text_field.dart';
import '../../../../utils/extensions/datetime_extensions.dart';
import '../../controllers/homework_controller.dart';

class HomeworkListView extends GetView<HomeworkController> {
  const HomeworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Uy vazifalari',
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => controller.setFilter(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Barchasi'),
              ),
              const PopupMenuItem(
                value: 'upcoming',
                child: Text('Kelayotgan'),
              ),
              const PopupMenuItem(
                value: 'overdue',
                child: Text('Muddati o\'tgan'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Bajarilgan'),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Column(
              children: [
                // Search field
                CustomSearchField(
                  hint: 'Vazifa, fan yoki guruh bo\'yicha qidiring...',
                  controller: controller.searchController,
                  onChanged: (value) => controller.filterHomework(),
                ),
                const SizedBox(height: 12),

                // Filter chips
                Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Barchasi', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Kelayotgan', 'upcoming'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Muddati o\'tgan', 'overdue'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Bajarilgan', 'completed'),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // Homework list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Vazifalar yuklanmoqda...');
              }

              if (controller.hasError.value) {
                return CustomErrorWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshData,
                );
              }

              if (controller.filteredHomeworkList.isEmpty) {
                return EmptyStateWidget(
                  title: controller.searchQuery.value.isNotEmpty
                      ? 'Qidiruv natijalari yo\'q'
                      : 'Vazifalar yo\'q',
                  message: controller.searchQuery.value.isNotEmpty
                      ? 'Boshqa kalit so\'z bilan qidiring'
                      : 'Hozircha hech qanday vazifa yo\'q',
                  icon: Icons.assignment_outlined,
                  onRetry: controller.refreshData,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredHomeworkList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final homework = controller.filteredHomeworkList[index];
                    return _buildHomeworkCard(homework, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateHomeworkDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yangi vazifa'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => controller.setFilter(value),
        selectedColor: AppColors.primaryBlue.withOpacity(0.2),
        checkmarkColor: AppColors.primaryBlue,
      );
    });
  }

  Widget _buildHomeworkCard(dynamic homework, BuildContext context) {
    final dueDate = DateTime.parse(homework['due_date']);
    final statusText = controller.getStatusText(homework);
    final statusColor = controller.getStatusColor(homework);
    final isOverdue = dueDate.isBefore(DateTime.now());
    final isDueSoon = dueDate.difference(DateTime.now()).inDays <= 1 && !isOverdue;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showHomeworkDetails(homework),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue
                  ? AppColors.error.withOpacity(0.3)
                  : isDueSoon
                  ? AppColors.warning.withOpacity(0.3)
                  : Colors.transparent,
              width: isOverdue || isDueSoon ? 1 : 0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      homework['title'] ?? 'Noma\'lum vazifa',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Subject and group info
              Row(
                children: [
                  Icon(
                    Icons.book,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${homework['subject'] ?? 'Noma\'lum fan'} • ${homework['group'] ?? 'Noma\'lum guruh'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Due date and points
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isOverdue
                        ? AppColors.error
                        : isDueSoon
                        ? AppColors.warning
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Muddat: ${dueDate.formatDate} ${dueDate.formatTime}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverdue
                          ? AppColors.error
                          : isDueSoon
                          ? AppColors.warning
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${homework['max_points'] ?? 100} ball',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Relative time
              Text(
                dueDate.relativeTime,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isOverdue
                      ? AppColors.error
                      : isDueSoon
                      ? AppColors.warning
                      : AppColors.info,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.navigateToGrading(
                        homework['id'],
                        homework['title'] ?? '',
                      ),
                      icon: Icon(Icons.grade, size: 16),
                      label: const Text('Baholash'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showEditHomeworkDialog(homework),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Tahrirlash',
                    color: AppColors.primaryBlue,
                  ),
                  IconButton(
                    onPressed: () => controller.deleteHomework(
                      homework['id'],
                      homework['title'] ?? '',
                    ),
                    icon: const Icon(Icons.delete),
                    tooltip: 'O\'chirish',
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateHomeworkDialog() {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Yangi vazifa yaratish',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vazifa yaratish uchun alohida sahifaga o\'tasiz',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Bekor qilish'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed('/teacher/homework/create');
                    },
                    child: const Text('Davom etish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditHomeworkDialog(dynamic homework) {
    controller.loadHomeworkForEdit(homework);
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          constraints: BoxConstraints(maxHeight: Get.height * 0.8),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vazifani tahrirlash',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '"${homework['title']}" vazifasini tahrirlash uchun alohida sahifaga o\'tasiz',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Bekor qilish'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed('/teacher/homework/edit/${homework['id']}');
                    },
                    child: const Text('Tahrirlash'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHomeworkDetails(dynamic homework) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    homework['title'] ?? 'Noma\'lum vazifa',
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Details
            _buildDetailRow('Fan', homework['subject'] ?? 'Noma\'lum'),
            _buildDetailRow('Guruh', homework['group'] ?? 'Noma\'lum'),
            _buildDetailRow('Muddat', DateTime.parse(homework['due_date']).formatDateTime),
            _buildDetailRow('Maksimal ball', '${homework['max_points'] ?? 100}'),

            const SizedBox(height: 24),

            // Description
            Text(
              'Tavsif:',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              homework['description'] ?? 'Tavsif kiritilmagan',
              style: Get.textTheme.bodyMedium,
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.navigateToGrading(
                        homework['id'],
                        homework['title'] ?? '',
                      );
                    },
                    icon: const Icon(Icons.grade),
                    label: const Text('Baholash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showEditHomeworkDialog(homework);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Tahrirlash'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}