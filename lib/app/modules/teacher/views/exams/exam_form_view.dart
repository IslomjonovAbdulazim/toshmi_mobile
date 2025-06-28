import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/extensions/datetime_extensions.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/custom_button.dart';
import '../../../../utils/widgets/common/custom_text_field.dart';
import '../../controllers/exam_controller.dart';

class ExamFormView extends GetView<ExamController> {
  final bool isEditing;
  final int? examId;

  const ExamFormView({super.key, this.isEditing = false, this.examId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Imtihonni tahrirlash' : 'Yangi imtihon yaratish',
        actions: [
          if (isEditing)
            IconButton(
              onPressed: () => _showDeleteConfirmation(),
              icon: const Icon(Icons.delete),
              tooltip: 'O\'chirish',
              color: AppColors.error,
            ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              CustomTextField(
                label: 'Imtihon nomi *',
                controller: controller.titleController,
                validator: controller.validateTitle,
                hint: 'Masalan: Algebra yakuniy imtihoni',
                prefixIcon: const Icon(Icons.quiz),
              ),

              const SizedBox(height: 20),

              // Group and Subject selection
              _buildGroupSubjectSelector(),

              const SizedBox(height: 20),

              // Description field
              CustomTextField(
                label: 'Tavsif *',
                controller: controller.descriptionController,
                validator: controller.validateDescription,
                maxLines: 4,
                hint: 'Imtihon haqida batafsil ma\'lumot...',
                prefixIcon: const Icon(Icons.description),
              ),

              const SizedBox(height: 20),

              // Exam date and time
              Row(
                children: [
                  Expanded(child: _buildExamDateSelector()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildExamTimeSelector()),
                ],
              ),

              const SizedBox(height: 20),

              // Duration info
              _buildDurationInfo(),

              const SizedBox(height: 20),

              // Max points field
              CustomTextField(
                label: 'Maksimal ball *',
                controller: controller.maxPointsController,
                validator: controller.validateMaxPoints,
                keyboardType: TextInputType.number,
                hint: '100',
                prefixIcon: const Icon(Icons.star),
              ),

              const SizedBox(height: 20),

              // External links section
              _buildExternalLinksSection(),

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guruh va fan *',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.selectedGroupSubjectId.value == 0
                    ? AppColors.error.withOpacity(0.5)
                    : Get.theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: controller.selectedGroupSubjectId.value == 0
                  ? null
                  : controller.selectedGroupSubjectId.value,
              hint: const Text('Guruh va fanni tanlang'),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [
                // Mock data - this should come from API
                const DropdownMenuItem(
                  value: 1,
                  child: Text('10-A • Matematika'),
                ),
                const DropdownMenuItem(
                  value: 2,
                  child: Text('10-B • Matematika'),
                ),
                const DropdownMenuItem(
                  value: 3,
                  child: Text('11-A • Matematika'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setGroupSubject(value);
                }
              },
            ),
          ),
        ),
        if (controller.selectedGroupSubjectId.value == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Guruh va fan tanlanishi shart',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildExamDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imtihon sanasi *',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => InkWell(
            onTap: () => _selectExamDate(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.selectedExamDate.value == null
                      ? AppColors.error.withOpacity(0.5)
                      : Get.theme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.selectedExamDate.value?.formatDate ??
                          'Sanani tanlang',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: controller.selectedExamDate.value == null
                            ? Get.theme.colorScheme.onSurfaceVariant
                            : Get.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (controller.selectedExamDate.value == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Sana tanlanishi shart',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildExamTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imtihon vaqti *',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => InkWell(
            onTap: () => _selectExamTime(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.selectedExamTime.value == null
                      ? AppColors.error.withOpacity(0.5)
                      : Get.theme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.selectedExamTime.value?.format(Get.context!) ??
                          'Vaqtni tanlang',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: controller.selectedExamTime.value == null
                            ? Get.theme.colorScheme.onSurfaceVariant
                            : Get.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (controller.selectedExamTime.value == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vaqt tanlanishi shart',
              style: Get.textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildDurationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Imtihon davomiyligi',
                style: Get.textTheme.titleSmall?.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Imtihon davomiyligi avtomatik ravishda 90 daqiqa (1.5 soat) deb belgilanadi. '
            'Agar boshqa davomiylik kerak bo\'lsa, imtihon yaratilgandan keyin uni tahrirlashingiz mumkin.',
            style: Get.textTheme.bodySmall?.copyWith(color: AppColors.info),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tashqi havolalar',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Add link field
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Havola URL',
                controller: controller.externalLinksController,
                hint: 'https://example.com',
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: controller.addExternalLink,
              icon: const Icon(Icons.add),
              tooltip: 'Havola qo\'shish',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondaryOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Links list
        Obx(
          () => controller.externalLinks.isNotEmpty
              ? Column(
                  children: [
                    ...controller.externalLinks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final link = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.surfaceVariant
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 16,
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                link,
                                style: Get.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  controller.removeExternalLink(index),
                              icon: const Icon(Icons.close),
                              iconSize: 18,
                              color: AppColors.error,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceVariant.withOpacity(
                      0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Get.theme.colorScheme.outline.withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Text(
                    'Hech qanday havola qo\'shilmagan',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Obx(
          () => CustomButton(
            text: isEditing ? 'Yangilash' : 'Yaratish',
            onPressed: () => _submitForm(),
            isLoading: isEditing
                ? controller.isUpdating.value
                : controller.isCreating.value,
            backgroundColor: AppColors.secondaryOrange,
          ),
        ),

        const SizedBox(height: 12),

        CustomOutlinedButton(
          text: 'Bekor qilish',
          onPressed: () => _showCancelConfirmation(),
          borderColor: AppColors.error,
          textColor: AppColors.error,
        ),

        if (isEditing) ...[
          const SizedBox(height: 12),
          CustomButton(
            text: 'O\'chirish',
            onPressed: () => _showDeleteConfirmation(),
            backgroundColor: AppColors.error,
          ),
        ],
      ],
    );
  }

  Future<void> _selectExamDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate:
          controller.selectedExamDate.value ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      controller.setExamDate(date);
    }
  }

  Future<void> _selectExamTime() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime:
          controller.selectedExamTime.value ??
          const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      controller.setExamTime(time);
    }
  }

  void _submitForm() {
    if (isEditing && examId != null) {
      controller.updateExam(examId!);
    } else {
      controller.createExam();
    }
  }

  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bekor qilish'),
        content: const Text('Barcha o\'zgarishlar yo\'qoladi. Davom etasizmi?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Yo\'q')),
          TextButton(
            onPressed: () {
              controller.clearForm();
              Get.back(); // Close dialog
              Get.back(); // Close form
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Ha, bekor qilish'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    if (!isEditing || examId == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Imtihonni o\'chirish'),
        content: const Text(
          'Bu imtihonni butunlay o\'chirib tashlamoqchimisiz? '
          'Bu amalni bekor qilib bo\'lmaydi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.deleteExam(examId!, controller.titleController.text);
              Get.back(); // Close form
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
