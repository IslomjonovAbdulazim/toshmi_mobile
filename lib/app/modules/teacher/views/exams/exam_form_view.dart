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

    final selectedDate = (isEditing
        ? DateTime.parse(exam!['exam_date'])
        : DateTime.now().add(const Duration(days: 7))).obs;

    final selectedTime = TimeOfDay.fromDateTime(selectedDate.value).obs;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: isEditing ? 'Edit Exam' : 'New Exam',
        actions: [
          TextButton(
            onPressed: () => _saveExam(
              titleController,
              descriptionController,
              maxPointsController,
              selectedDate.value,
              selectedTime.value,
            ),
            child: const Text('Save'),
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
              label: 'Title',
              hint: 'Enter exam title',
              icon: Icons.quiz,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: descriptionController,
              label: 'Description',
              hint: 'Enter exam description',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: maxPointsController,
                    label: 'Max Points',
                    hint: '100',
                    icon: Icons.star,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGroupSubjectSelector(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Exam Date & Time',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildDateTimeCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Date',
                    value: _formatDate(selectedDate.value),
                    onTap: () => _selectDate(context, selectedDate),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildDateTimeCard(
                    context,
                    icon: Icons.access_time,
                    title: 'Time',
                    value: selectedTime.value.format(context),
                    onTap: () => _selectTime(context, selectedTime),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildExamDetailsCard(theme),
            const SizedBox(height: 32),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  Widget _buildGroupSubjectSelector() {
    // This would connect to actual group-subject data
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: 'Class',
        prefixIcon: const Icon(Icons.class_),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text('Math - Grade 10A')),
        DropdownMenuItem(value: 2, child: Text('Physics - Grade 11B')),
      ],
      onChanged: (value) {},
      hint: const Text('Select class'),
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
              Text(
                title,
                style: theme.textTheme.labelSmall,
              ),
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

  Widget _buildExamDetailsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.timer_outlined,
                    title: 'Duration',
                    value: '2 hours',
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.location_on_outlined,
                    title: 'Room',
                    value: 'A-101',
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context, Rx<DateTime> selectedDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> _selectTime(BuildContext context, Rx<TimeOfDay> selectedTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
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
      Get.snackbar('Error', 'Please enter a title');
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
      // Edit existing exam
      controller.updateExam(
        examId: exam!['id'],
        groupSubjectId: 1, // This should come from the selector
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        examDate: examDateTime,
        maxPoints: int.tryParse(maxPointsController.text) ?? 100,
      );
    } else {
      // Create new exam
      controller.createExam(
        groupSubjectId: 1, // This should come from the selector
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        examDate: examDateTime,
        maxPoints: int.tryParse(maxPointsController.text) ?? 100,
      );
    }

    Get.back();
  }
}