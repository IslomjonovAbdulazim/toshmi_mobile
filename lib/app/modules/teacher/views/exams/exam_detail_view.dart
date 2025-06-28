// lib/app/modules/teacher/views/exams/exam_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/exam_controller.dart';
import '../../../../utils/constants/app_colors.dart';

class ExamDetailView extends GetView<ExamController> {
  const ExamDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Imtihon tafsilotlari',
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
              const PopupMenuItem(value: 'results', child: Text('Natijalar')),
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
              onPressed: controller.loadExamDetail,
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
          _buildSchedule(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 16),
          _buildSettings(),
          const SizedBox(height: 16),
          _buildMaterials(),
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
      final exam = controller.currentExam;
      if (exam.isEmpty) return const SizedBox.shrink();

      final examDate = DateTime.parse(exam['exam_date']);
      final isUpcoming = examDate.isAfter(DateTime.now());
      final daysUntilExam = examDate.difference(DateTime.now()).inDays;

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
                      Icons.quiz,
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
                          exam['title']?.toString() ?? 'Noma\'lum',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exam['group_name']} • ${exam['subject_name']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(exam['status']),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Sana va vaqt',
                      '${_formatDate(examDate)} ${_formatTime(examDate)}',
                      Icons.schedule,
                      isUpcoming ? AppColors.info : AppColors.warning,
                    ),
                  ),
                  if (exam['max_points'] != null)
                    Expanded(
                      child: _buildInfoItem(
                        'Maksimal ball',
                        '${exam['max_points']}',
                        Icons.grade,
                        AppColors.success,
                      ),
                    ),
                ],
              ),
              if (daysUntilExam <= 7 && isUpcoming) ...[
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
                      Icon(Icons.notification_important, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        daysUntilExam == 0
                            ? 'Bugun imtihon'
                            : daysUntilExam == 1
                            ? 'Ertaga imtihon'
                            : '${daysUntilExam} kun qoldi',
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

  Widget _buildSchedule() {
    return Obx(() {
      final exam = controller.currentExam;

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
              _buildScheduleRow('Sana', _formatDate(DateTime.parse(exam['exam_date']))),
              _buildScheduleRow('Boshlanish vaqti', exam['start_time']?.toString() ?? 'Belgilanmagan'),
              _buildScheduleRow('Tugash vaqti', exam['end_time']?.toString() ?? 'Belgilanmagan'),
              _buildScheduleRow('Davomiyligi', exam['duration'] != null ? '${exam['duration']} daqiqa' : 'Belgilanmagan'),
              _buildScheduleRow('Joy', exam['location']?.toString() ?? 'Belgilanmagan'),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildScheduleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildDescription() {
    return Obx(() {
      final exam = controller.currentExam;
      final description = exam['description']?.toString();
      final instructions = exam['instructions']?.toString();

      if ((description == null || description.isEmpty) &&
          (instructions == null || instructions.isEmpty)) {
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
                    'Tavsif va ko\'rsatmalar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Tavsif:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
              if (instructions != null && instructions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Ko\'rsatmalar:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  instructions,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSettings() {
    return Obx(() {
      final exam = controller.currentExam;

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
              _buildSettingRow('Turi', _getExamType(exam['type'])),
              _buildSettingRow('O\'tish balli', exam['passing_score']?.toString() ?? 'Belgilanmagan'),
              _buildSettingRow('Urinishlar soni', exam['attempts']?.toString() ?? '1'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildSettingChip('Ochiq kitob', exam['is_open_book'] == true, AppColors.info),
                  _buildSettingChip('Kalkulyator', exam['allow_calculator'] == true, AppColors.success),
                  _buildSettingChip('Onlayn', exam['is_online'] == true, AppColors.warning),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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

  Widget _buildSettingChip(String label, bool isEnabled, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEnabled ? Icons.check : Icons.close,
            size: 14,
            color: isEnabled ? color : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isEnabled ? color : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterials() {
    return Obx(() {
      final exam = controller.currentExam;
      final links = exam['external_links'] as List<dynamic>? ?? [];

      if (links.isEmpty) return const SizedBox.shrink();

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
                ],
              ),
              const SizedBox(height: 16),
              ...links.map((link) => _buildLinkItem(link as Map<String, dynamic>)),
            ],
          ),
        ),
      );
    });
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
                  link['title'] as String? ?? 'Noma\'lum',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  link['url'] as String? ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openLink(link['url'] as String?),
            icon: Icon(Icons.open_in_new, color: AppColors.primary),
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
              final stats = controller.examStatistics;
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
                      'Ishtirok etganlar',
                      '${stats['participated'] ?? 0}',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              final stats = controller.examStatistics;
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

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _editExam,
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
            onPressed: _gradeExam,
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

  String _getExamType(String? type) {
    switch (type) {
      case 'midterm': return 'Oraliq nazorat';
      case 'final': return 'Yakuniy imtihon';
      case 'quiz': return 'Qisqa test';
      case 'practical': return 'Amaliy ish';
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

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editExam();
        break;
      case 'grade':
        _gradeExam();
        break;
      case 'results':
        _viewResults();
        break;
      case 'duplicate':
        _duplicateExam();
        break;
      case 'delete':
        _deleteExam();
        break;
    }
  }

  void _editExam() {
    final exam = controller.currentExam;
    Get.toNamed('/teacher/exam/edit', arguments: exam);
  }

  void _gradeExam() {
    final exam = controller.currentExam;
    Get.toNamed('/teacher/grading', arguments: {
      'type': 'exam',
      'assignment_id': exam['id'],
    });
  }

  void _viewResults() {
    final exam = controller.currentExam;
    Get.toNamed('/teacher/exam/results', arguments: {'exam_id': exam['id']});
  }

  void _duplicateExam() {
    controller.duplicateExam();
  }

  void _deleteExam() {
    Get.dialog(
      AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Imtihonni o\'chirishni xohlaysizmi? Bu amalni qaytarib bo\'lmaydi.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteExam();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  void _openLink(String? url) {
    if (url == null || url.isEmpty) return;

    // Implementation for opening links
    Get.snackbar(
      'Havola',
      'Havola ochilmoqda...',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}