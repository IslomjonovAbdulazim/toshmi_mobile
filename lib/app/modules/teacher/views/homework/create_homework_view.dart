// lib/app/modules/teacher/views/homework/create_homework_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/homework_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class CreateHomeworkView extends GetView<HomeworkController> {
  const CreateHomeworkView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(controller.isEditing.value ? 'Uy vazifani tahrirlash' : 'Yangi uy vazifa',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
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
              _buildDescription(),
              const SizedBox(height: 24),
              _buildSettings(),
              const SizedBox(height: 24),
              _buildFiles(),
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
                const Text('Asosiy ma\'lumotlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.titleController,
              decoration: InputDecoration(
                labelText: 'Sarlavha *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              validator: (value) => value?.isEmpty == true ? 'Sarlavha kiritish majburiy' : null,
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Guruh-Fan *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              value: controller.selectedGroupSubjectId.value == 0 ? null : controller.selectedGroupSubjectId.value,
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
                    decoration: InputDecoration(
                      labelText: 'Muddat *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDueDate(context),
                    controller: TextEditingController(
                      text: controller.selectedDueDate.value != null ? _formatDate(controller.selectedDueDate.value!) : '',
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Muddat tanlash majburiy' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Vaqt *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _selectDueTime(context),
                    controller: TextEditingController(
                      text: controller.selectedDueTime.value != null ? controller.selectedDueTime.value!.format(context) : '',
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Vaqt tanlash majburiy' : null,
                  ),
                ),
              ],
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
                const Text('Tavsif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Uy vazifa tavsifi',
                hintText: 'Talabalar uchun batafsil ko\'rsatmalar yozing...',
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
                const Text('Sozlamalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.maxPointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Maksimal ball',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return null;
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
                    value: controller.selectedType.value.isEmpty ? null : controller.selectedType.value,
                    items: const [
                      DropdownMenuItem(value: 'individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'group', child: Text('Guruh')),
                      DropdownMenuItem(value: 'project', child: Text('Loyiha')),
                    ],
                    onChanged: (value) => controller.selectedType.value = value ?? '',
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => CheckboxListTile(
                    title: const Text('Fayl yuklashga ruxsat', style: TextStyle(fontSize: 14)),
                    value: controller.allowFileUpload.value,
                    onChanged: (value) => controller.allowFileUpload.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  )),
                ),
                Expanded(
                  child: Obx(() => CheckboxListTile(
                    title: const Text('Kech topshirishga ruxsat', style: TextStyle(fontSize: 14)),
                    value: controller.allowLateSubmission.value,
                    onChanged: (value) => controller.allowLateSubmission.value = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiles() {
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
                Icon(Icons.attach_file, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text('Fayllar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton.icon(
                  onPressed: controller.addFile,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Fayl qo\'shish'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.attachedFiles.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      Text('Fayl yuklanmagan', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text('Ma\'lumotlar, rasmlar yoki boshqa fayllarni yuklang', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                );
              }

              return Column(
                children: controller.attachedFiles.map((file) => _buildFileItem(file)).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file) {
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
          Icon(_getFileIcon(file['name'] as String), color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('${file['size']} KB', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.removeFile(file),
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
            onPressed: controller.isSaving.value ? null : controller.saveHomework,
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
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            )
                : Text(controller.isEditing.value ? 'Yangilash' : 'Yaratish'),
          )),
        ),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'xls': case 'xlsx': return Icons.table_chart;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'jpg': case 'jpeg': case 'png': case 'gif': return Icons.image;
      case 'mp4': case 'avi': case 'mov': return Icons.video_file;
      case 'mp3': case 'wav': return Icons.audio_file;
      default: return Icons.insert_drive_file;
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDueDate.value ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.selectedDueDate.value = selectedDate;
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: controller.selectedDueTime.value ?? const TimeOfDay(hour: 23, minute: 59),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      controller.selectedDueTime.value = selectedTime;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}