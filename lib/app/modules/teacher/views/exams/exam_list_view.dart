import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/loading_widget.dart';
import '../../../../utils/widgets/common/error_widget.dart';
import '../../../../utils/widgets/common/empty_state_widget.dart';
import '../../../../utils/widgets/common/custom_text_field.dart';
import '../../../../utils/extensions/datetime_extensions.dart';
import '../../controllers/exam_controller.dart';

class ExamListView extends GetView<ExamController> {
  const ExamListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Imtihonlar',
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
                value: 'today',
                child: Text('Bugun'),
              ),
              const PopupMenuItem(
                value: 'upcoming',
                child: Text('Kelayotgan'),
              ),
              const PopupMenuItem(
                value: 'past',
                child: Text('O\'tgan'),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Today's exams highlight
          Obx(() => controller.todayExams.isNotEmpty
              ? _buildTodayExamsSection()
              : const SizedBox.shrink()),

          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Column(
              children: [
                // Search field
                CustomSearchField(
                  hint: 'Imtihon, fan yoki guruh bo\'yicha qidiring...',
                  controller: controller.searchController,
                  onChanged: (value) => controller.filterExams(),
                ),
                const SizedBox(height: 12),

                // Filter chips
                Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Barchasi', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Bugun', 'today'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Kelayotgan', 'upcoming'),
                      const SizedBox(width: 8),
                      _buildFilterChip('O\'tgan', 'past'),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // Exams list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const LoadingWidget(message: 'Imtihonlar yuklanmoqda...');
              }

              if (controller.hasError.value) {
                return CustomErrorWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshData,
                );
              }

              if (controller.filteredExamsList.isEmpty) {
                return EmptyStateWidget(
                  title: controller.searchQuery.value.isNotEmpty
                      ? 'Qidiruv natijalari yo\'q'
                      : 'Imtihonlar yo\'q',
                  message: controller.searchQuery.value.isNotEmpty
                      ? 'Boshqa kalit so\'z bilan qidiring'
                      : 'Hozircha hech qanday imtihon yo\'q',
                  icon: Icons.quiz_outlined,
                  onRetry: controller.refreshData,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredExamsList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exam = controller.filteredExamsList[index];
                    return _buildExamCard(exam, context);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateExamDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Yangi imtihon'),
        backgroundColor: AppColors.secondaryOrange,
      ),
    );
  }

  Widget _buildTodayExamsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error,
            AppColors.error.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.today,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bugungi imtihonlar',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Text(
                  '${controller.todayExams.length} ta',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
            children: controller.todayExams.take(3).map((exam) {
              final examTime = DateTime.parse(exam['exam_date']);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam['title'] ?? 'Noma\'lum imtihon',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${exam['subject']} • ${exam['group']}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      examTime.formatTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
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
        selectedColor: AppColors.secondaryOrange.withOpacity(0.2),
        checkmarkColor: AppColors.secondaryOrange,
      );
    });
  }

  Widget _buildExamCard(dynamic exam, BuildContext context) {
    final examDate = DateTime.parse(exam['exam_date']);
    final statusText = controller.getStatusText(exam);
    final statusColor = controller.getStatusColor(exam);
    final timeUntil = controller.getTimeUntilExam(exam);
    final isToday = examDate.isToday;
    final isPast = examDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showExamDetails(exam),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday
                  ? AppColors.error.withOpacity(0.5)
                  : Colors.transparent,
              width: isToday ? 2 : 0,
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
                      exam['title'] ?? 'Noma\'lum imtihon',
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
                    '${exam['subject'] ?? 'Noma\'lum fan'} • ${exam['group'] ?? 'Noma\'lum guruh'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Exam date and time
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isToday
                        ? AppColors.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${examDate.formatDate} ${examDate.formatTime}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isToday
                          ? AppColors.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: AppColors.secondaryOrange,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${exam['max_points'] ?? 100} ball',
                          style: TextStyle(
                            color: AppColors.secondaryOrange,
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

              // Time until exam
              if (!isPast) ...[
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: isToday ? AppColors.error : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeUntil,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isToday ? AppColors.error : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.navigateToGrading(
                        exam['id'],
                        exam['title'] ?? '',
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
                    onPressed: () => _showEditExamDialog(exam),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Tahrirlash',
                    color: AppColors.secondaryOrange,
                  ),
                  IconButton(
                    onPressed: () => controller.deleteExam(
                      exam['id'],
                      exam['title'] ?? '',
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

  void _showCreateExamDialog() {
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
                'Yangi imtihon yaratish',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Imtihon yaratish uchun alohida sahifaga o\'tasiz',
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
                      Get.toNamed('/teacher/exam/create');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryOrange,
                    ),
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

  void _showEditExamDialog(dynamic exam) {
    controller.loadExamForEdit(exam);
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
                'Imtihonni tahrirlash',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '"${exam['title']}" imtihonini tahrirlash uchun alohida sahifaga o\'tasiz',
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
                      Get.toNamed('/teacher/exam/edit/${exam['id']}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryOrange,
                    ),
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

  void _showExamDetails(dynamic exam) {
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
                    exam['title'] ?? 'Noma\'lum imtihon',
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
            _buildDetailRow('Fan', exam['subject'] ?? 'Noma\'lum'),
            _buildDetailRow('Guruh', exam['group'] ?? 'Noma\'lum'),
            _buildDetailRow('Sana', DateTime.parse(exam['exam_date']).formatDate),
            _buildDetailRow('Vaqt', DateTime.parse(exam['exam_date']).formatTime),
            _buildDetailRow('Maksimal ball', '${exam['max_points'] ?? 100}'),
            _buildDetailRow('Holat', controller.getStatusText(exam)),

            const SizedBox(height: 16),

            // Time until exam
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: controller.getStatusColor(exam).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.getStatusColor(exam).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: controller.getStatusColor(exam),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.getTimeUntilExam(exam),
                    style: TextStyle(
                      color: controller.getStatusColor(exam),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

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
              exam['description'] ?? 'Tavsif kiritilmagan',
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
                        exam['id'],
                        exam['title'] ?? '',
                      );
                    },
                    icon: const Icon(Icons.grade),
                    label: const Text('Baholash'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _showEditExamDialog(exam);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Tahrirlash'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryOrange,
                      side: BorderSide(color: AppColors.secondaryOrange),
                    ),
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