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
    if (selectedFilter.value == 'all') return exams;

    final now = DateTime.now();
    return exams.where((exam) {
      final examDate = DateTime.parse(exam['exam_date']);
      final hasGrade = exam['grade'] != null;

      switch (selectedFilter.value) {
        case 'upcoming':
          return examDate.isAfter(now);
        case 'completed':
          return hasGrade;
        case 'past':
          return examDate.isBefore(now) && !hasGrade;
        default:
          return true;
      }
    }).toList();
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
      padding: const EdgeInsets.all(16),
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Barchasi', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Kelayotgan', 'upcoming'),
            const SizedBox(width: 8),
            _buildFilterChip('Topshirilgan', 'completed'),
            const SizedBox(width: 8),
            _buildFilterChip('O\'tgan', 'past'),
          ],
        ),
      )),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => selectedFilter.value = value,
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam) {
    final examDate = DateTime.parse(exam['exam_date']);
    final hasGrade = exam['grade'] != null;
    final isPast = examDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    ),
                    child: const Text(
                      'Kutilmoqda',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
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