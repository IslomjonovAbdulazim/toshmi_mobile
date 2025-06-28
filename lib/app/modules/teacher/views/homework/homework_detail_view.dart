// lib/app/modules/teacher/views/homework/homework_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/homework_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class HomeworkDetailView extends GetView<HomeworkController> {
  const HomeworkDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Uy vazifa tafsilotlari',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Tahrirlash')),
              const PopupMenuItem(value: 'grade', child: Text('Baholash')),
              const PopupMenuItem(value: 'duplicate', child: Text('Nusxa olish')),
              const PopupMenuItem(value: 'delete', child: Text('O\'chirish')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (controller.hasError.value) {
          return _buildErrorState();
        }

        return _buildContent();
      }),
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
            Text(
              'Xatolik yuz berdi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.loadHomeworkDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 16),
          _buildDetails(),
          const SizedBox(height: 16),
          _buildFiles(),
          const SizedBox(height: 16),
          _buildStatistics(),
          const SizedBox(height: 16),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final homework = controller.currentHomework;
      if (homework.isEmpty) return const SizedBox.shrink();

      final dueDate = DateTime.parse(homework['due_date']);
      final isOverdue = dueDate.isBefore(DateTime.now());
      final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homework['title']?.toString() ?? 'Noma\'lum',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${homework['group_name']} • ${homework['subject_name']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(homework['status']),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Muddat',
                      _formatDate(dueDate),
                      Icons.calendar_today,
                      isOverdue ? AppColors.error : AppColors.info,
                    ),
                  ),
                  if (homework['max_points'] != null)
                    Expanded(
                      child: _buildInfoItem(
                        'Maksimal ball',
                        '${homework['max_points']}',
                        Icons.grade,
                        AppColors.success,
                      ),
                    ),
                ],
              ),
              if (daysUntilDue <= 3 && !isOverdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        daysUntilDue == 0
                            ? 'Bugun tugaydi'
                            : '${daysUntilDue} kun qoldi',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Obx(() {
      final homework = controller.currentHomework;
      final description = homework['description']?.toString();

      if (description == null || description.isEmpty) {
        return const SizedBox.shrink();
      }

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
                    'Tavsif',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetails() {
    return Obx(() {
      final homework = controller.currentHomework;

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
                    'Tafsilotlar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Yaratilgan sana', _formatDate(DateTime.parse(homework['created_at'] ?? DateTime.now().toIso8601String()))),
              _buildDetailRow('Turi', _getHomeworkType(homework['type'])),
              _buildDetailRow('Fayl yuklashga ruxsat', homework['allow_file_upload'] == true ? 'Ha' : 'Yo\'q'),
              _buildDetailRow('Kech topshirishga ruxsat', homework['allow_late_submission'] == true ? 'Ha' : 'Yo\'q'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiles() {
    return Obx(() {
      final homework = controller.currentHomework;
      final files = homework['files'] as List<dynamic>? ?? [];

      if (files.isEmpty) return const SizedBox.shrink();

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
                  const Text(
                    'Biriktirilan fayllar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...files.map((file) => _buildFileItem(file as Map<String, dynamic>)),
            ],
          ),
        ),
      );
    });
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
                Text(
                  file['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (file['size'] != null)
                  Text(
                    '${file['size']} KB',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _downloadFile(file),
            icon: Icon(Icons.download, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
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
                Icon(Icons.analytics_outlined, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Statistika',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final stats = controller.homeworkStatistics;
              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Jami talabalar',
                      '${stats['total_students'] ?? 0}',
                      Icons.people,
                      AppColors.info,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Topshirganlar',
                      '${stats['submitted'] ?? 0}',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              final stats = controller.homeworkStatistics;
              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Baholanganlar',
                      '${stats['graded'] ?? 0}',
                      Icons.grade,
                      AppColors.warning,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'O\'rtacha ball',
                      '${stats['average_grade']?.toStringAsFixed(1) ?? '0.0'}',
                      Icons.trending_up,
                      AppColors.primary,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editHomework,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Tahrirlash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _gradeHomework,
            icon: const Icon(Icons.grade, size: 18),
            label: const Text('Baholash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
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

  String _getHomeworkType(String? type) {
    switch (type) {
      case 'individual': return 'Individual';
      case 'group': return 'Guruh';
      case 'project': return 'Loyiha';
      default: return 'Noma\'lum';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyun',
      'Iyul', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editHomework();
        break;
      case 'grade':
        _gradeHomework();
        break;
      case 'duplicate':
        _duplicateHomework();
        break;
      case 'delete':
        _deleteHomework();
        break;
    }
  }

  void _editHomework() {
    final homework = controller.currentHomework;
    Get.toNamed('/teacher/homework/edit', arguments: homework);
  }

  void _gradeHomework() {
    final homework = controller.currentHomework;
    Get.toNamed('/teacher/grading', arguments: {
      'type': 'homework',
      'assignment_id': homework['id'],
    });
  }

  void _duplicateHomework() {
    controller.duplicateHomework();
  }

  void _deleteHomework() {
    Get.dialog(
      AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Uy vazifani o\'chirishni xohlaysizmi? Bu amalni qaytarib bo\'lmaydi.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteHomework();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _downloadFile(Map<String, dynamic> file) {
    // Implementation for file download
    Get.snackbar(
      'Yuklab olish',
      'Fayl yuklab olinmoqda...',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}