// lib/app/modules/teacher/views/exams/create_exam_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exam_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class CreateExamView extends GetView<ExamController> {
  const CreateExamView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          controller.isEditing.value ? 'Imtihonni tahrirlash' : 'Yangi imtihon',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildSchedule(),
              const SizedBox(height: 24),
              _buildDescription(),
              const SizedBox(height: 24),
              _buildSettings(),
              const SizedBox(height: 24),
              _buildMaterials(),
              const SizedBox(height: 32),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Asosiy ma\'lumotlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.titleController,
              decoration: InputDecoration(
                labelText: 'Imtihon nomi *',
                hintText: 'Masalan: Matematika oraliq nazorati',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              validator: (value) => value?.isEmpty == true ? 'Imtihon nomi kiritish majburiy' : null,
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Guruh-Fan *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              value: controller.selectedGroupSubjectId.value == 0
                  ? null
                  : controller.selectedGroupSubjectId.value,
              items: controller.groupSubjects.map((gs) => DropdownMenuItem<int>(
                value: gs['id'] as int,
                child: Text('${gs['group_name']} • ${gs['subject_name']}'),
              )).toList(),
              onChanged: (value) => controller.selectedGroupSubjectId.value = value ?? 0,
              validator: (value) => value == null ? 'Guruh-Fan tanlash majburiy' : null,
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.maxPointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Maksimal ball *',
                      hintText: '100',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Ball kiritish majburiy';
                      final points = int.tryParse(value!);
                      return points == null || points <= 0 ? 'Musbat son kiriting' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Turi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    value: controller.selectedType.value.isEmpty
                        ? null
                        : controller.selectedType.value,
                    items: const [
                      DropdownMenuItem(value: 'midterm', child: Text('Oraliq nazorat')),
                      DropdownMenuItem(value: 'final', child: Text('Yakuniy imtihon')),
                      DropdownMenuItem(value: 'quiz', child: Text('Qisqa test')),
                      DropdownMenuItem(value: 'practical', child: Text('Amaliy ish')),
                    ],
                    onChanged: (value) => controller.selectedType.value = value ?? '',
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_outlined, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Vaqt jadvali',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Imtihon sanasi *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectExamDate(context),
                    controller: TextEditingController(
                      text: controller.selectedExamDate.value != null
                          ? _formatDate(controller.selectedExamDate.value!)
                          : '',
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Sana tanlash majburiy' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Boshlanish vaqti *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _selectStartTime(context),
                    controller: TextEditingController(
                      text: controller.selectedStartTime.value != null
                          ? controller.selectedStartTime.value!.format(context)
                          : '',
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Vaqt tanlash majburiy' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tugash vaqti',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _selectEndTime(context),
                    controller: TextEditingController(
                      text: controller.selectedEndTime.value != null
                          ? controller.selectedEndTime.value!.format(context)
                          : '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controller.durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Davomiyligi (daqiqa)',
                      hintText: '90',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return null;
                      final duration = int.tryParse(value!);
                      return duration == null || duration <= 0 ? 'Musbat son kiriting' : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.locationController,
              decoration: InputDecoration(
                labelText: 'Joy',
                hintText: 'Masalan: 201-xona, Informatika auditoriyasi',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Tavsif va ko\'rsatmalar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Imtihon tavsifi',
                hintText: 'Imtihon mavzulari, format va talablar haqida ma\'lumot bering...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(16),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.instructionsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Talabalar uchun ko\'rsatmalar',
                hintText: 'Kerakli materiallar, qoidalar va eslatmalar...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(16),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Sozlamalar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => CheckboxListTile(
                    title: const Text('Ochiq kitob imtihoni', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Talabalar materiallardan foydalanishi mumkin', style: TextStyle(fontSize: 12)),
                    value: controller.isOpenBook.value,
                    onChanged: (value) => controller.isOpenBook.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  )),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Obx(() => CheckboxListTile(
                    title: const Text('Kalkulyator ruxsat', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Talabalar kalkulyator ishlatishi mumkin', style: TextStyle(fontSize: 12)),
                    value: controller.allowCalculator.value,
                    onChanged: (value) => controller.allowCalculator.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  )),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Obx(() => CheckboxListTile(
                    title: const Text('Onlayn imtihon', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Imtihon onlayn tarzda olinadi', style: TextStyle(fontSize: 12)),
                    value: controller.isOnline.value,
                    onChanged: (value) => controller.isOnline.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.passingScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'O\'tish balli',
                      hintText: '60',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return null;
                      final score = int.tryParse(value!);
                      return score == null || score < 0 ? 'Musbat son kiriting' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controller.attemptsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Urinishlar soni',
                      hintText: '1',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return null;
                      final attempts = int.tryParse(value!);
                      return attempts == null || attempts <= 0 ? 'Musbat son kiriting' : null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterials() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.library_books_outlined, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Materiallar va havolalar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.addExternalLink,
                  icon: const Icon(Icons.add_link, size: 16),
                  label: const Text('Havola qo\'shish'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.externalLinks.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.link_outlined, size: 48, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      Text('Tashqi havolalar yo\'q', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(
                        'O\'quv materiallari, video darslar yoki boshqa resurslar havolalarini qo\'shing',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: controller.externalLinks.map((link) => _buildLinkItem(link)).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(Map<String, dynamic> link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  link['url'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.removeExternalLink(link),
            icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Bekor qilish'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveExam,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: controller.isSaving.value
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(controller.isEditing.value ? 'Yangilash' : 'Yaratish'),
          )),
        ),
      ],
    );
  }

  Future<void> _selectExamDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedExamDate.value ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.selectedExamDate.value = selectedDate;
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: controller.selectedStartTime.value ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      controller.selectedStartTime.value = selectedTime;
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: controller.selectedEndTime.value ?? const TimeOfDay(hour: 11, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      controller.selectedEndTime.value = selectedTime;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
      'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}