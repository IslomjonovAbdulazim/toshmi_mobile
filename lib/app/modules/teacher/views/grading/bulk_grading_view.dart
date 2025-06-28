// lib/app/modules/teacher/views/grading/bulk_grading_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/grading_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class BulkGradingView extends GetView<GradingController> {
  const BulkGradingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ommaviy baholash',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.selectedStudents.isNotEmpty
              ? TextButton(
            onPressed: controller.applyBulkGrade,
            child: Text(
              'Qo\'llash (${controller.selectedStudents.length})',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          _buildGradingForm(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (controller.students.isEmpty) {
                return _buildEmptyState();
              }

              return _buildStudentsList();
            }),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildGradingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group_work_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Ommaviy baholash',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: controller.bulkPointsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Ball *',
                    hintText: 'Masalan: 85',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    suffixText: Obx(() {
                      final maxPoints = controller.currentAssignment['max_points'];
                      return maxPoints != null ? '/ $maxPoints' : null;
                    }),
                  ),
                  onChanged: (value) => _validatePoints(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: controller.bulkCommentController,
                  decoration: InputDecoration(
                    labelText: 'Izoh',
                    hintText: 'Umumiy izoh yozing...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickScoreChip('A\'lo (90-100)', 95),
              _buildQuickScoreChip('Yaxshi (80-89)', 85),
              _buildQuickScoreChip('Qoniqarli (70-79)', 75),
              _buildQuickScoreChip('Qoniqarsiz (0-69)', 60),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.selectAllStudents,
                  icon: const Icon(Icons.select_all, size: 18),
                  label: const Text('Hammasini tanlash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.clearSelection,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Tanlovni tozalash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScoreChip(String label, int score) {
    return InkWell(
      onTap: () => controller.bulkPointsController.text = score.toString(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getScoreColor(score).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getScoreColor(score).withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _getScoreColor(score),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Talabalar ro\'yxati bo\'sh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Baholash uchun talabalar topilmadi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.students.length,
      itemBuilder: (context, index) {
        final student = controller.students[index];
        final studentId = student['student_id'] as int;
        return _buildStudentCard(student, studentId);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int studentId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.toggleStudentSelection(studentId),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Obx(() => Checkbox(
                value: controller.selectedStudents.contains(studentId),
                onChanged: (value) => controller.toggleStudentSelection(studentId),
                activeColor: AppColors.primary,
              )),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  _getInitials(student['name'] as String? ?? ''),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] as String? ?? 'Noma\'lum',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ID: $studentId',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(() {
                    final grade = controller.grades[studentId];
                    if (grade != null && grade['points'] != null) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getScoreColor(grade['points'] as int).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getScoreColor(grade['points'] as int).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${grade['points']} ball',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(grade['points'] as int),
                          ),
                        ),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Baholanmagan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Obx(() {
                    final grade = controller.grades[studentId];
                    if (grade != null && grade['comment']?.toString().isNotEmpty == true) {
                      return Icon(
                        Icons.comment,
                        size: 16,
                        color: AppColors.info,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final selectedCount = controller.selectedStudents.length;
            final totalStudents = controller.students.length;

            return Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tanlangan: $selectedCount/$totalStudents talaba',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                if (selectedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Orqaga'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.selectedStudents.isEmpty ||
                      controller.bulkPointsController.text.isEmpty ||
                      controller.isSavingGrades.value
                      ? null
                      : _applyBulkGrades,
                  icon: controller.isSavingGrades.value
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.check_circle, size: 18),
                  label: Text(
                    controller.isSavingGrades.value
                        ? 'Saqlanmoqda...'
                        : 'Baholash (${controller.selectedStudents.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 80) return AppColors.info;
    if (score >= 70) return AppColors.warning;
    return AppColors.error;
  }

  void _validatePoints(String value) {
    if (value.isEmpty) return;

    final points = double.tryParse(value);
    if (points == null) {
      Get.snackbar(
        'Xatolik',
        'Iltimos, to\'g\'ri raqam kiriting',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final maxPoints = controller.currentAssignment['max_points'] as int? ?? 100;
    if (points < 0 || points > maxPoints) {
      Get.snackbar(
        'Xatolik',
        'Ball 0 dan $maxPoints gacha bo\'lishi kerak',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _applyBulkGrades() {
    final points = double.tryParse(controller.bulkPointsController.text);
    final maxPoints = controller.currentAssignment['max_points'] as int? ?? 100;

    if (points == null || points < 0 || points > maxPoints) {
      Get.snackbar(
        'Xatolik',
        'To\'g\'ri ball kiriting (0-$maxPoints)',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Tasdiqlash'),
        content: Text(
          '${controller.selectedStudents.length} ta talabani '
              '${points.toInt()} ball bilan baholashni xohlaysizmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.applyBulkGrade();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}