import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/custom_text_field.dart';
import '../../../../utils/widgets/common/custom_button.dart';
import '../../../../utils/extensions/datetime_extensions.dart';
import '../../controllers/homework_controller.dart';

class HomeworkFormView extends GetView<HomeworkController> {
  final bool isEditing;
  final int? homeworkId;

  const HomeworkFormView({
    super.key,
    this.isEditing = false,
    this.homeworkId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Vazifani tahrirlash' : 'Yangi vazifa yaratish',
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
                label: 'Vazifa nomi *',
                controller: controller.titleController,
                validator: controller.validateTitle,
                hint: 'Masalan: Algebra darsligi 5-mashq',
                prefixIcon: const Icon(Icons.assignment),
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
                hint: 'Vazifa haqida batafsil ma\'lumot...',
                prefixIcon: const Icon(Icons.description),
              ),

              const SizedBox(height: 20),

              // Due date and time
              Row(
                children: [
                  Expanded(child: _buildDueDateSelector()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDueTimeSelector()),
                ],
              ),

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
        Obx(() => Container(
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
        )),
        if (controller.selectedGroupSubjectId.value == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Guruh va fan tanlanishi shart',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDueDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Muddat sanasi *',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => InkWell(
          onTap: () => _selectDueDate(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.selectedDueDate.value == null
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
                    controller.selectedDueDate.value?.formatDate ?? 'Sanani tanlang',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: controller.selectedDueDate.value == null
                          ? Get.theme.colorScheme.onSurfaceVariant
                          : Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
        if (controller.selectedDueDate.value == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Sana tanlanishi shart',
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDueTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Muddat vaqti',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDueTime(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Get.theme.colorScheme.outline),
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
                    '23:59', // Default time
                    style: Get.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Links list
        Obx(() => controller.externalLinks.isNotEmpty
            ? Column(
          children: [
            ...controller.externalLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final link = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
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
                      onPressed: () => controller.removeExternalLink(index),
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
            color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
        )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Obx(() => CustomButton(
          text: isEditing ? 'Yangilash' : 'Yaratish',
          onPressed: () => _submitForm(),
          isLoading: isEditing
              ? controller.isUpdating.value
              : controller.isCreating.value,
          backgroundColor: AppColors.primaryBlue,
        )),

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

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDueDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      controller.setDueDate(date);
    }
  }

  Future<void> _selectDueTime() async {
    final time = await showTimePicker(
      context: Get.context!,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );

    if (time != null && controller.selectedDueDate.value != null) {
      final newDate = DateTime(
        controller.selectedDueDate.value!.year,
        controller.selectedDueDate.value!.month,
        controller.selectedDueDate.value!.day,
        time.hour,
        time.minute,
      );
      controller.setDueDate(newDate);
    }
  }

  void _submitForm() {
    if (isEditing && homeworkId != null) {
      controller.updateHomework(homeworkId!);
    } else {
      controller.createHomework();
    }
  }

  void _showCancelConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bekor qilish'),
        content: const Text('Barcha o\'zgarishlar yo\'qoladi. Davom etasizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Yo\'q'),
          ),
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
    if (!isEditing || homeworkId == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Vazifani o\'chirish'),
        content: const Text(
          'Bu vazifani butunlay o\'chirib tashlamoqchimisiz? '
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
              controller.deleteHomework(
                homeworkId!,
                controller.titleController.text,
              );
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