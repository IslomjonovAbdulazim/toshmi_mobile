// lib/app/modules/teacher/views/exams/exam_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/exam_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';

class ExamFormView extends GetView<ExamController> {
  final Map<String, dynamic>? exam;

  const ExamFormView({super.key, this.exam});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = exam != null;

    final titleController = TextEditingController(
      text: isEditing ? exam!['title'] : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? exam!['description'] : '',
    );
    final maxPointsController = TextEditingController(
      text: isEditing ? exam!['max_points'].toString() : '100',
    );
    final linkController = TextEditingController();

    final selectedDate =
        (isEditing
            ? DateTime.parse(exam!['exam_date'])
            : DateTime.now().add(const Duration(days: 7)))
            .obs;

    final selectedTime = TimeOfDay.fromDateTime(selectedDate.value).obs;

    if (isEditing && exam!['external_links'] != null) {
      controller.initializeExternalLinks(
        List<String>.from(exam!['external_links']),
      );
    } else {
      controller.clearExternalLinks();
    }

    if (isEditing && exam!['group_subject_id'] != null) {
      final groupSubjectId = exam!['group_subject_id'];
      final matchingSubject = controller.groupSubjects.firstWhereOrNull(
            (gs) => gs.id == groupSubjectId,
      );
      if (matchingSubject != null) {
        controller.selectGroupSubject(matchingSubject);
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: isEditing ? 'edit_exam'.tr : 'new_exam'.tr,
        actions: [
          TextButton(
            onPressed: () => _saveExam(
              titleController,
              descriptionController,
              maxPointsController,
              selectedDate.value,
              selectedTime.value,
            ),
            child: Text('save'.tr),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: titleController,
              label: 'title'.tr,
              hint: 'enter_exam_title'.tr,
              icon: Icons.quiz,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: descriptionController,
              label: 'description'.tr,
              hint: 'enter_exam_description'.tr,
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildGroupSubjectSelector(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: maxPointsController,
              label: 'max_points'.tr,
              hint: '100',
              icon: Icons.star,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildDateTimeSection(context, selectedDate, selectedTime),
            const SizedBox(height: 16),
            _buildExternalLinksSection(linkController, context),
            SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }

  Widget _buildGroupSubjectSelector() {
    return Obx(
          () => DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'class_and_subject'.tr,
          prefixIcon: const Icon(Icons.class_),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        value: controller.selectedGroupSubject.value?.id,
        items: controller.groupSubjects.map((groupSubject) {
          return DropdownMenuItem<int>(
            value: groupSubject.id,
            child: Text(controller.getGroupSubjectDisplayName(groupSubject)),
          );
        }).toList(),
        onChanged: (value) {
          final selected = controller.groupSubjects.firstWhereOrNull(
                (gs) => gs.id == value,
          );
          if (selected != null) {
            controller.selectGroupSubject(selected);
          }
        },
        hint: Text('select_class_subject'.tr),
        validator: (value) => value == null ? 'select_class_subject'.tr : null,
      ),
    );
  }

  Widget _buildDateTimeSection(
      BuildContext context,
      Rx<DateTime> selectedDate,
      Rx<TimeOfDay> selectedTime,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'exam_date_time'.tr,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                    () => _buildDateTimeCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'date'.tr,
                  value: _formatDate(selectedDate.value),
                  onTap: () => _selectDate(context, selectedDate),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                    () => _buildDateTimeCard(
                  context,
                  icon: Icons.access_time,
                  title: 'time'.tr,
                  value: selectedTime.value.format(context),
                  onTap: () => _selectTime(context, selectedTime),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: theme.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExternalLinksSection(
      TextEditingController linkController,
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'external_links'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'external_links_description'.tr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: 'link_url'.tr,
                  hintText: 'https://example.com',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                keyboardType: TextInputType.url,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _addExternalLink(linkController),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
              () => controller.externalLinks.isEmpty
              ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'no_external_links_added'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
              : Column(
            children: controller.externalLinks
                .asMap()
                .entries
                .map(
                  (entry) => _buildLinkItem(
                theme,
                entry.value,
                entry.key,
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkItem(
      ThemeData theme,
      String link,
      int index,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          _isValidUrl(link) ? Icons.link : Icons.link_off,
          color: _isValidUrl(link)
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
        ),
        title: Text(
          link,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _isValidUrl(link)
                ? theme.colorScheme.onSurface
                : theme.colorScheme.error,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _isValidUrl(link)
            ? null
            : Text(
          'invalid_url_format'.tr,
          style: TextStyle(color: theme.colorScheme.error),
        ),
        trailing: IconButton(
          onPressed: () => controller.removeExternalLink(index),
          icon: const Icon(Icons.delete_outline),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  bool _isValidUrl(String url) {
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlPattern.hasMatch(url.trim());
  }

  String _sanitizeUrl(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return '';
    if (!trimmedUrl.startsWith('http://') &&
        !trimmedUrl.startsWith('https://')) {
      return 'https://$trimmedUrl';
    }
    return trimmedUrl;
  }

  void _addExternalLink(TextEditingController linkController) {
    final link = _sanitizeUrl(linkController.text);

    if (link.isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_link'.tr);
      return;
    }

    if (!_isValidUrl(link)) {
      Get.snackbar('error'.tr, 'please_enter_valid_url'.tr);
      return;
    }

    if (controller.externalLinks.contains(link)) {
      Get.snackbar('error'.tr, 'link_already_added'.tr);
      return;
    }

    controller.addExternalLink(link);
    linkController.clear();
    Get.snackbar(
      'success'.tr,
      'link_added_successfully'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _selectDate(
      BuildContext context,
      Rx<DateTime> selectedDate,
      ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'select_due_date'.tr,
      confirmText: 'select'.tr,
      cancelText: 'cancel'.tr,
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> _selectTime(
      BuildContext context,
      Rx<TimeOfDay> selectedTime,
      ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
      helpText: 'select_due_time'.tr,
      confirmText: 'select'.tr,
      cancelText: 'cancel'.tr,
    );
    if (time != null) {
      selectedTime.value = time;
    }
  }

  void _saveExam(
      TextEditingController titleController,
      TextEditingController descriptionController,
      TextEditingController maxPointsController,
      DateTime selectedDate,
      TimeOfDay selectedTime,
      ) {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_exam_title'.tr);
      return;
    }

    if (controller.selectedGroupSubject.value == null) {
      Get.snackbar('error'.tr, 'please_select_class_subject'.tr);
      return;
    }

    final examDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (exam != null) {
      controller.updateExam(
        examId: exam!['id'],
        groupSubjectId: controller.selectedGroupSubject.value!.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        examDate: examDateTime,
        maxPoints: int.tryParse(maxPointsController.text) ?? 100,
        externalLinks: controller.externalLinks.toList(),
      );
    } else {
      controller.createExam(
        groupSubjectId: controller.selectedGroupSubject.value!.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        examDate: examDateTime,
        maxPoints: int.tryParse(maxPointsController.text) ?? 100,
        externalLinks: controller.externalLinks.toList(),
      );
    }

    Get.back();
  }
}