import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/loading_widget.dart';
import '../../../../utils/widgets/common/error_widget.dart';
import '../../../../utils/widgets/common/empty_state_widget.dart';
import '../../../../utils/widgets/common/custom_text_field.dart';
import '../../controllers/grading_controller.dart';

class GradingView extends GetView<GradingController> {
  const GradingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Baholash',
        actions: [
          // Bulk grading toggle
          Obx(() => IconButton(
            onPressed: controller.toggleBulkGrading,
            icon: Icon(
              controller.isBulkGrading.value ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            tooltip: controller.isBulkGrading.value ? 'Yakka baholash' : 'Ko\'p baholash',
            color: controller.isBulkGrading.value ? AppColors.primaryBlue : null,
          )),

          // Save button
          Obx(() => controller.hasUnsavedChanges.value
              ? IconButton(
            onPressed: controller.saveAllGrades,
            icon: const Icon(Icons.save),
            tooltip: 'Saqlash',
            color: AppColors.success,
          )
              : IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yangilash',
          )),
        ],
      ),
      body: Column(
        children: [
          // Assignment info header
          _buildAssignmentHeader(),

          // Statistics section
          _buildStatisticsSection(),

          // Bulk grading controls
          Obx(() => controller.isBulkGrading.value
              ? _buildBulkGradingControls()
              : const SizedBox.shrink()),

          // Students list
          Expanded(
            child: _buildStudentsList(),
          ),

          // Bottom action bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildAssignmentHeader() {
    return Obx(() {
      if (controller.currentAssignment.isEmpty) {
        return const SizedBox.shrink();
      }

      final assignment = controller.currentAssignment;
      final assignmentType = controller.assignmentType.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  assignmentType == 'homework' ? Icons.assignment : Icons.quiz,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    assignment['title'] ?? 'Noma\'lum vazifa',
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Maksimal ball: ${assignment['max_points'] ?? 100}',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatisticsSection() {
    return Obx(() {
      if (controller.students.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Jami o\'quvchi',
                    controller.totalStudents.value.toString(),
                    Icons.group,
                    AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Baholangan',
                    controller.totalGraded.value.toString(),
                    Icons.grade,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'O\'rtacha ball',
                    controller.averageGrade.value.toStringAsFixed(1),
                    Icons.trending_up,
                    AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Grade distribution
            _buildGradeDistribution(),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Get.textTheme.bodySmall?.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDistribution() {
    return Obx(() {
      final distribution = controller.gradeDistribution;
      final total = distribution.values.fold(0, (sum, count) => sum + count);

      if (total == 0) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Baholar taqsimoti',
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: distribution.entries.map((entry) {
              final percentage = (entry.value / total * 100).round();
              final color = _getGradeDistributionColor(entry.key);

              return Expanded(
                flex: entry.value == 0 ? 1 : entry.value,
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: entry.value == 0 ? Colors.grey.shade300 : color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: distribution.entries.map((entry) {
              final color = _getGradeDistributionColor(entry.key);
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Color _getGradeDistributionColor(String grade) {
    switch (grade) {
      case 'A\'lo':
        return AppColors.gradeExcellent;
      case 'Yaxshi':
        return AppColors.gradeGood;
      case 'Qoniqarli':
        return AppColors.gradeAverage;
      case 'Qoniqarsiz':
        return AppColors.gradePoor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBulkGradingControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Ko\'p baholash rejimi',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Selection controls
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.selectAllStudents,
                  icon: const Icon(Icons.select_all, size: 16),
                  label: const Text('Hammasini tanlash'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.deselectAllStudents,
                  icon: const Icon(Icons.deselect, size: 16),
                  label: const Text('Tanlovni bekor qilish'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bulk grade inputs
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'Ball',
                  controller: controller.bulkPointsController,
                  keyboardType: TextInputType.number,
                  hint: 'Masalan: 85',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: CustomTextField(
                  label: 'Izoh (ixtiyoriy)',
                  controller: controller.bulkCommentController,
                  hint: 'Umumiy izoh...',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Apply button
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.selectedStudents.isNotEmpty
                  ? controller.applyBulkGrade
                  : null,
              icon: const Icon(Icons.check),
              label: Text('${controller.selectedStudents.length} ta o\'quvchiga qo\'llash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(message: 'Ma\'lumotlar yuklanmoqda...');
      }

      if (controller.hasError.value) {
        return CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        );
      }

      if (controller.students.isEmpty) {
        return const EmptyStateWidget(
          title: 'O\'quvchilar yo\'q',
          message: 'Bu vazifa uchun o\'quvchilar topilmadi',
          icon: Icons.person_outline,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.students.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final student = controller.students[index];
          return _buildStudentCard(student);
        },
      );
    });
  }

  Widget _buildStudentCard(dynamic student) {
    final studentId = student['student_id'] as int;
    final studentName = student['name'] as String;

    return Obx(() {
      final hasGrade = controller.hasGrade(studentId);
      final grade = controller.getGrade(studentId);
      final isSelected = controller.isBulkGrading.value &&
          controller.selectedStudents.contains(studentId);

      return Card(
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : null,
        child: InkWell(
          onTap: controller.isBulkGrading.value
              ? () => controller.toggleStudentSelection(studentId)
              : () => controller.showGradingDialog(studentId, studentName),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Selection checkbox in bulk mode
                    if (controller.isBulkGrading.value) ...[
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) => controller.toggleStudentSelection(studentId),
                        activeColor: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Student avatar
                    CircleAvatar(
                      backgroundColor: hasGrade
                          ? controller.getGradeColor(studentId).withOpacity(0.2)
                          : AppColors.primaryBlue.withOpacity(0.1),
                      child: hasGrade
                          ? Icon(
                        Icons.grade,
                        color: controller.getGradeColor(studentId),
                      )
                          : Text(
                        studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Student info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studentName,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'ID: $studentId',
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grade display
                    if (hasGrade) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: controller.getGradeColor(studentId).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${grade!['points']}/${controller.currentAssignment['max_points']}',
                              style: TextStyle(
                                color: controller.getGradeColor(studentId),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.getGradeLabel(studentId),
                            style: TextStyle(
                              color: controller.getGradeColor(studentId),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Baholanmagan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Grade comment
                if (hasGrade && grade!['comment'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.comment,
                              size: 16,
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Izoh:',
                              style: Get.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          grade!['comment'].toString(),
                          style: Get.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons (not in bulk mode)
                if (!controller.isBulkGrading.value) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.showGradingDialog(studentId, studentName),
                          icon: Icon(hasGrade ? Icons.edit : Icons.grade, size: 16),
                          label: Text(hasGrade ? 'Tahrirlash' : 'Baholash'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasGrade ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ),
                      if (hasGrade) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => controller.removeGrade(studentId),
                          icon: const Icon(Icons.delete),
                          color: AppColors.error,
                          tooltip: 'Bahoni o\'chirish',
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Obx(() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.grades.isNotEmpty && !controller.isSavingGrades.value
              ? controller.saveAllGrades
              : null,
          icon: controller.isSavingGrades.value
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.save),
          label: Text(
            controller.isSavingGrades.value
                ? 'Saqlanmoqda...'
                : 'Balllarni saqlash (${controller.grades.length})',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      )),
    );
  }
}