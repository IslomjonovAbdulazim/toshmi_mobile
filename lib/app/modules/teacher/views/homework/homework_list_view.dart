// lib/app/modules/teacher/views/homework/homework_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../controllers/homework_controller.dart';

class HomeworkListView extends GetView<HomeworkController> {
  const HomeworkListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Uy vazifalar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadHomeworkList,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
              }

              if (controller.hasError.value) {
                return _buildErrorState();
              }

              if (controller.homeworkList.isEmpty) {
                return _buildEmptyState();
              }

              return _buildHomeworkList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/teacher/homework/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedStatus.value.isEmpty ? null : controller.selectedStatus.value,
              items: const [
                DropdownMenuItem(value: '', child: Text('Barchasi')),
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
              decoration: InputDecoration(
                labelText: 'Guruh-Fan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: controller.selectedGroupSubjectId.value == 0 ? null : controller.selectedGroupSubjectId.value,
              items: [
                const DropdownMenuItem(value: 0, child: Text('Barchasi')),
                ...controller.groupSubjects.map((gs) => DropdownMenuItem<int>(
                  value: gs['id'] as int,
                  child: Text('${gs['group_name']} • ${gs['subject_name']}', style: const TextStyle(fontSize: 13)),
                )),
              ],
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
            ElevatedButton(
              onPressed: controller.loadHomeworkList,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Qayta urinish'),
            ),
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
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Uy vazifalar yo\'q', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Birinchi uy vazifangizni yarating', style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/teacher/homework/create'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Uy vazifa yaratish'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkList() {
    return RefreshIndicator(
      onRefresh: controller.loadHomeworkList,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredHomework.length,
        itemBuilder: (context, index) {
          final homework = controller.filteredHomework[index];
          return _buildHomeworkCard(homework);
        },
      ),
    );
  }

  Widget _buildHomeworkCard(Map<String, dynamic> homework) {
    final dueDate = DateTime.parse(homework['due_date']);
    final isOverdue = dueDate.isBefore(DateTime.now());
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed('/teacher/homework/detail', arguments: {'homework_id': homework['id']}),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      homework['title'] ?? 'Noma\'lum',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _buildStatusChip(homework['status']),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${homework['group_name']} • ${homework['subject_name']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              if (homework['description'] != null && homework['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  homework['description'],
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: isOverdue ? AppColors.error : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Muddat: ${_formatDate(dueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? AppColors.error : Colors.grey[600],
                      fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (homework['max_points'] != null) ...[
                    Icon(Icons.grade, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${homework['max_points']} ball',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              if (daysUntilDue <= 3 && !isOverdue) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    daysUntilDue == 0 ? 'Bugun tugaydi' : '${daysUntilDue} kun qoldi',
                    style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton('Ko\'rish', Icons.visibility, () => _viewHomework(homework)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton('Tahrirlash', Icons.edit, () => _editHomework(homework)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton('Baholash', Icons.grade, () => _gradeHomework(homework)),
                  ),
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
        case 'active': return AppColors.success;
        case 'completed': return AppColors.warning;
        case 'graded': return AppColors.info;
        default: return Colors.grey;
      }
    }

    String getStatusText() {
      switch (status) {
        case 'active': return 'Faol';
        case 'completed': return 'Tugagan';
        case 'graded': return 'Baholangan';
        default: return 'Noma\'lum';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getStatusColor().withOpacity(0.3)),
      ),
      child: Text(
        getStatusText(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: getStatusColor(),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _viewHomework(Map<String, dynamic> homework) {
    Get.toNamed('/teacher/homework/detail', arguments: {'homework_id': homework['id']});
  }

  void _editHomework(Map<String, dynamic> homework) {
    Get.toNamed('/teacher/homework/edit', arguments: homework);
  }

  void _gradeHomework(Map<String, dynamic> homework) {
    Get.toNamed('/teacher/grading', arguments: {'type': 'homework', 'assignment_id': homework['id']});
  }

  String _formatDate(DateTime date) {
    const months = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun', 'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}