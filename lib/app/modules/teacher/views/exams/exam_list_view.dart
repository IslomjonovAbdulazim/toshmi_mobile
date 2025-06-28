// lib/app/modules/teacher/views/exams/exam_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exam_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class ExamListView extends GetView<ExamController> {
  const ExamListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Imtihonlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: controller.loadExamList)],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: Obx(() {
            if (controller.isLoading.value) return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
            if (controller.hasError.value) return _buildErrorState();
            if (controller.examList.isEmpty) return _buildEmptyState();
            return _buildExamList();
          })),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/teacher/exam/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
              items: const [
                DropdownMenuItem(value: '', child: Text('Barchasi')),
                DropdownMenuItem(value: 'scheduled', child: Text('Rejalashtirilgan')),
                DropdownMenuItem(value: 'active', child: Text('Faol')),
                DropdownMenuItem(value: 'completed', child: Text('Tugagan')),
                DropdownMenuItem(value: 'graded', child: Text('Baholangan')),
              ],
              onChanged: controller.filterByStatus,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Guruh-Fan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              value: controller.selectedGroupSubjectId.value == 0 ? null : controller.selectedGroupSubjectId.value,
              items: [const DropdownMenuItem(value: 0, child: Text('Barchasi')), ...controller.groupSubjects.map((gs) => DropdownMenuItem<int>(value: gs['id'] as int, child: Text('${gs['group_name']} • ${gs['subject_name']}', style: const TextStyle(fontSize: 13))))],
              onChanged: controller.filterByGroupSubject,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Xatolik yuz berdi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Obx(() => Text(controller.errorMessage.value, style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: controller.loadExamList, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Qayta urinish')),
          ],
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
            Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Imtihonlar yo\'q', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Birinchi imtihoningizni yarating', style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: () => Get.toNamed('/teacher/exam/create'), icon: const Icon(Icons.add, size: 18), label: const Text('Imtihon yaratish'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildExamList() {
    return RefreshIndicator(
      onRefresh: controller.loadExamList,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredExams.length,
        itemBuilder: (context, index) => _buildExamCard(controller.filteredExams[index]),
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    final examDate = DateTime.parse(exam['exam_date']);
    final isUpcoming = examDate.isAfter(DateTime.now());
    final daysUntilExam = examDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed('/teacher/exam/detail', arguments: {'exam_id': exam['id']}),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(exam['title'] ?? 'Noma\'lum', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                  _buildStatusChip(exam['status']),
                ],
              ),
              const SizedBox(height: 8),
              Text('${exam['group_name']} • ${exam['subject_name']}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              if (exam['description'] != null && exam['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(exam['description'], style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: isUpcoming ? AppColors.info : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${_formatDate(examDate)} ${_formatTime(examDate)}', style: TextStyle(fontSize: 12, color: isUpcoming ? AppColors.info : Colors.grey[600], fontWeight: isUpcoming ? FontWeight.w500 : FontWeight.normal)),
                  const Spacer(),
                  if (exam['max_points'] != null) ...[
                    Icon(Icons.grade, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${exam['max_points']} ball', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ],
              ),
              if (daysUntilExam <= 7 && isUpcoming) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(daysUntilExam == 0 ? 'Bugun' : daysUntilExam == 1 ? 'Ertaga' : '${daysUntilExam} kun qoldi', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500)),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildActionButton('Ko\'rish', Icons.visibility, () => _viewExam(exam))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildActionButton('Tahrirlash', Icons.edit, () => _editExam(exam))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildActionButton('Baholash', Icons.grade, () => _gradeExam(exam))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color getStatusColor() {
      switch (status) {
        case 'scheduled': return AppColors.info;
        case 'active': return AppColors.success;
        case 'completed': return AppColors.warning;
        case 'graded': return AppColors.primary;
        default: return Colors.grey;
      }
    }

    String getStatusText() {
      switch (status) {
        case 'scheduled': return 'Rejalashtirilgan';
        case 'active': return 'Faol';
        case 'completed': return 'Tugagan';
        case 'graded': return 'Baholangan';
        default: return 'Noma\'lum';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: getStatusColor().withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: getStatusColor().withOpacity(0.3))),
      child: Text(getStatusText(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: getStatusColor())),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _viewExam(Map<String, dynamic> exam) => Get.toNamed('/teacher/exam/detail', arguments: {'exam_id': exam['id']});
  void _editExam(Map<String, dynamic> exam) => Get.toNamed('/teacher/exam/edit', arguments: exam);
  void _gradeExam(Map<String, dynamic> exam) => Get.toNamed('/teacher/grading', arguments: {'type': 'exam', 'assignment_id': exam['id']});

  String _formatDate(DateTime date) {
    const months = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}