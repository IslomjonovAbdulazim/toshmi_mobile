// lib/app/modules/teacher/views/homework/homework_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/homework_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../../../../data/models/group_subject_model.dart';

class HomeworkFormView extends GetView<HomeworkController> {
  final Map<String, dynamic>? homework;

  const HomeworkFormView({super.key, this.homework});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = homework != null;

    final titleController = TextEditingController(
      text: isEditing ? homework!['title'] : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? homework!['description'] : '',
    );
    final maxPointsController = TextEditingController(
      text: isEditing ? homework!['max_points'].toString() : '100',
    );

    final selectedDate = (isEditing
        ? DateTime.parse(homework!['due_date'])
        : DateTime.now().add(const Duration(days: 7))).obs;

    final selectedTime = TimeOfDay.fromDateTime(selectedDate.value).obs;

    // External links management
    final externalLinks = <String>[].obs;
    final linkController = TextEditingController();

    // Initialize with existing links if editing
    if (isEditing && homework!['external_links'] != null) {
      externalLinks.addAll(List<String>.from(homework!['external_links']));
    }

    // Initialize selected group subject if editing
    if (isEditing && homework!['group_subject_id'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final groupSubject = controller.groupSubjects.firstWhereOrNull(
              (gs) => gs.id == homework!['group_subject_id'],
        );
        if (groupSubject != null) {
          controller.selectGroupSubject(groupSubject);
        }
      });
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: isEditing ? 'Uy vazifasini tahrirlash' : 'Yangi uy vazifasi',
        actions: [
          TextButton(
            onPressed: () => _saveHomework(
              titleController,
              descriptionController,
              maxPointsController,
              selectedDate.value,
              selectedTime.value,
              externalLinks.toList(),
            ),
            child: const Text('Saqlash'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            _buildTextField(
              controller: titleController,
              label: 'Sarlavha',
              hint: 'Uy vazifasi sarlavhasini kiriting',
              icon: Icons.title,
              validator: (value) => value?.trim().isEmpty == true ? 'Sarlavha kiritish majburiy' : null,
            ),
            const SizedBox(height: 16),

            // Description Field
            _buildTextField(
              controller: descriptionController,
              label: 'Tavsif',
              hint: 'Uy vazifasi tavsifini kiriting (ixtiyoriy)',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Group Subject and Max Points Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildGroupSubjectSelector(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: maxPointsController,
                    label: 'Maksimal ball',
                    hint: '100',
                    icon: Icons.star,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final points = int.tryParse(value ?? '');
                      if (points == null || points <= 0) {
                        return 'To\'g\'ri ball kiriting';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Due Date & Time Section
            Text(
              'Topshirish sanasi va vaqti',
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
                    title: 'Sana',
                    value: _formatDate(selectedDate.value),
                    onTap: () => _selectDate(context, selectedDate),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _buildDateTimeCard(
                    context,
                    icon: Icons.access_time,
                    title: 'Vaqt',
                    value: selectedTime.value.format(context),
                    onTap: () => _selectTime(context, selectedTime),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // External Links Section
            _buildExternalLinksSection(
              theme,
              linkController,
              externalLinks,
            ),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
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
    return Obx(() {
      if (controller.groupSubjects.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Sinflar yuklanmoqda...',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return DropdownButtonFormField<GroupSubject>(
        decoration: InputDecoration(
          labelText: 'Sinf',
          prefixIcon: const Icon(Icons.class_),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        value: controller.selectedGroupSubject.value,
        items: controller.groupSubjects.map((groupSubject) {
          return DropdownMenuItem<GroupSubject>(
            value: groupSubject,
            child: Text(
              controller.getGroupSubjectDisplayName(groupSubject),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (GroupSubject? value) {
          if (value != null) {
            controller.selectGroupSubject(value);
          }
        },
        hint: const Text('Sinfni tanlang'),
        validator: (value) => value == null ? 'Iltimos sinfni tanlang' : null,
      );
    });
  }

  Widget _buildExternalLinksSection(
      ThemeData theme,
      TextEditingController linkController,
      RxList<String> externalLinks,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tashqi havolalar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'O\'quvchilar uchun foydali havolalar qo\'shing (videolar, hujjatlar, manbalar)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Add Link Field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: 'Havola URL',
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
              onPressed: () => _addExternalLink(linkController, externalLinks),
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

        // Links List
        Obx(() {
          if (externalLinks.isEmpty) {
            return Container(
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
                    'Hali tashqi havolalar qo\'shilmagan',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: externalLinks.asMap().entries.map((entry) {
              final index = entry.key;
              final link = entry.value;
              return _buildLinkItem(theme, link, index, externalLinks);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildLinkItem(
      ThemeData theme,
      String link,
      int index,
      RxList<String> externalLinks,
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
          'Noto\'g\'ri URL formati',
          style: TextStyle(color: theme.colorScheme.error),
        ),
        trailing: IconButton(
          onPressed: () => externalLinks.removeAt(index),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

    // If it doesn't start with protocol, add https://
    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      return 'https://$trimmedUrl';
    }

    return trimmedUrl;
  }

  void _addExternalLink(
      TextEditingController linkController,
      RxList<String> externalLinks,
      ) {
    final link = _sanitizeUrl(linkController.text);

    if (link.isEmpty) {
      Get.snackbar('Xato', 'Iltimos havola kiriting');
      return;
    }

    if (!_isValidUrl(link)) {
      Get.snackbar('Xato', 'Iltimos to\'g\'ri URL kiriting (http:// yoki https:// bilan boshlanuvchi)');
      return;
    }

    if (externalLinks.contains(link)) {
      Get.snackbar('Xato', 'Bu havola allaqachon qo\'shilgan');
      return;
    }

    externalLinks.add(link);
    linkController.clear();
    Get.snackbar('Muvaffaqiyat', 'Havola muvaffaqiyatli qo\'shildi', duration: const Duration(seconds: 2));
  }

  Future<void> _selectDate(BuildContext context, Rx<DateTime> selectedDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Topshirish sanasini tanlang',
      confirmText: 'Tanlash',
      cancelText: 'Bekor qilish',
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> _selectTime(BuildContext context, Rx<TimeOfDay> selectedTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
      helpText: 'Topshirish vaqtini tanlang',
      confirmText: 'Tanlash',
      cancelText: 'Bekor qilish',
    );
    if (time != null) {
      selectedTime.value = time;
    }
  }

  void _saveHomework(
      TextEditingController titleController,
      TextEditingController descriptionController,
      TextEditingController maxPointsController,
      DateTime selectedDate,
      TimeOfDay selectedTime,
      List<String> externalLinks,
      ) {
    // Get values and trim
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final maxPointsText = maxPointsController.text.trim();

    // Debug prints
    print('🔄 Saving homework...');
    print('📝 Title: "$title"');
    print('📝 Description: "$description"');
    print('📝 Max Points Text: "$maxPointsText"');
    print('🔗 External Links: $externalLinks');

    // Validation
    if (title.isEmpty) {
      Get.snackbar('Xato', 'Iltimos sarlavha kiriting');
      return;
    }

    if (controller.selectedGroupSubject.value == null) {
      Get.snackbar('Xato', 'Iltimos sinfni tanlang');
      return;
    }

    // Check for invalid URLs
    final invalidLinks = externalLinks.where((link) => !_isValidUrl(link)).toList();
    if (invalidLinks.isNotEmpty) {
      Get.snackbar('Xato', 'Saqlashdan oldin noto\'g\'ri havolalarni tuzating');
      return;
    }

    final dueDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final maxPoints = int.tryParse(maxPointsText) ?? 100;

    print('✅ Validation passed. Calling controller...');
    print('📅 Due DateTime: $dueDateTime');
    print('⭐ Max Points (parsed): $maxPoints');

    if (homework != null) {
      // Edit existing homework
      print('🔄 Editing existing homework with ID: ${homework!['id']}');
      controller.updateHomework(
        homeworkId: homework!['id'],
        groupSubjectId: controller.selectedGroupSubject.value!.id,
        title: title,
        description: description,
        dueDate: dueDateTime,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
    } else {
      // Create new homework
      print('🔄 Creating new homework');
      controller.createHomework(
        groupSubjectId: controller.selectedGroupSubject.value!.id,
        title: title,
        description: description,
        dueDate: dueDateTime,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
    }

    Get.back();
  }
}