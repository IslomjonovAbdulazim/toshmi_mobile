// lib/app/modules/student/views/student_exams_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class StudentExamsView extends StatefulWidget {
  const StudentExamsView({super.key});

  @override
  State<StudentExamsView> createState() => _StudentExamsViewState();
}

class _StudentExamsViewState extends State<StudentExamsView> {
  final StudentRepository repository = StudentRepository();
  final isLoading = false.obs;
  final exams = <dynamic>[].obs;
  final selectedFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    loadExams();
  }

  Future<void> loadExams() async {
    try {
      isLoading.value = true;
      final data = await repository.getExams();
      exams.value = data;
    } catch (e) {
      Get.snackbar('Xato', 'Imtihonlarni yuklashda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic> get filteredExams {
    List filtered = exams;

    if (selectedFilter.value != 'all') {
      filtered = exams.where((exam) {
        final hasGrade = exam['grade'] != null && exam['grade']['points'] != null;

        switch (selectedFilter.value) {
          case 'not_graded':
            return !hasGrade;
          case 'graded':
            return hasGrade;
          default:
            return true;
        }
      }).toList();
    }

    // Sort by exam_date - newest first
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['exam_date']);
      final dateB = DateTime.parse(b['exam_date']);
      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Imtihonlar',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filtered = filteredExams;
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: loadExams,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildExamCard(filtered[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Obx(() => Row(
        children: [
          _buildFilterChip('Barchasi', 'all'),
          _buildFilterChip('Baholanmagan', 'not_graded'),
          _buildFilterChip('Baholangan', 'graded'),
        ],
      )),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter.value == value;
    Color chipColor;
    switch (value) {
      case 'upcoming':
        chipColor = Colors.orange;
        break;
      case 'completed':
        chipColor = Colors.green;
        break;
      case 'past':
        chipColor = Colors.grey;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => selectedFilter.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
                color: chipColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    final examDate = DateTime.parse(exam['exam_date']);
    final hasGrade = exam['grade'] != null;
    final isPast = examDate.isBefore(DateTime.now());
    final externalLinks = exam['external_links'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    exam['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (hasGrade)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${exam['grade']['points']}/${exam['max_points']}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Baholanmagan',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Kelayotgan',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              exam['subject'] ?? '',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (exam['description'] != null && exam['description'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                exam['description'],
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            if (externalLinks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 6),
                        Text(
                          'Tayyorgarlik materiallar:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...externalLinks.map((link) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: GestureDetector(
                        onTap: () => _launchURL(link),
                        child: Text(
                          link,
                          style: TextStyle(
                            color: Colors.orange[700],
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(examDate),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  '${exam['max_points']} ball',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    // You can implement URL launching here
    Get.snackbar('Havola', 'Havola ochilmoqda: $url');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Imtihonlar topilmadi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = dateTime.difference(now).inDays;

    if (diff == 0) return 'Bugun ${_formatTime(dateTime)}';
    if (diff == 1) return 'Ertaga ${_formatTime(dateTime)}';
    if (diff == -1) return 'Kecha ${_formatTime(dateTime)}';
    if (diff < 0) return '${-diff} kun oldin';
    if (diff < 7) return '${diff} kun keyin';
    return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}