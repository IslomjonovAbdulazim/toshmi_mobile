// lib/app/modules/student/views/student_homework_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class StudentHomeworkView extends StatefulWidget {
  const StudentHomeworkView({super.key});

  @override
  State<StudentHomeworkView> createState() => _StudentHomeworkViewState();
}

class _StudentHomeworkViewState extends State<StudentHomeworkView> {
  final StudentRepository repository = StudentRepository();
  final isLoading = false.obs;
  final homework = <dynamic>[].obs;
  final selectedFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    loadHomework();
  }

  Future<void> loadHomework() async {
    try {
      isLoading.value = true;
      final data = await repository.getHomework();
      homework.value = data;
    } catch (e) {
      Get.snackbar('Xato', 'Vazifalarni yuklashda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic> get filteredHomework {
    if (selectedFilter.value == 'all') return homework;

    return homework.where((hw) {
      final dueDate = DateTime.parse(hw['due_date']);
      final hasGrade = hw['grade'] != null;
      final now = DateTime.now();

      switch (selectedFilter.value) {
        case 'pending':
          return !hasGrade && dueDate.isAfter(now);
        case 'completed':
          return hasGrade;
        case 'overdue':
          return !hasGrade && dueDate.isBefore(now);
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Vazifalar',
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

              final filtered = filteredHomework;
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: loadHomework,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildHomeworkCard(filtered[index]),
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
      child: Obx(() => Row(
        children: [
          _buildFilterChip('Barchasi', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Kutilmoqda', 'pending'),
          const SizedBox(width: 8),
          _buildFilterChip('Bajarilgan', 'completed'),
          const SizedBox(width: 8),
          _buildFilterChip('Kechikkan', 'overdue'),
        ],
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

  Widget _buildHomeworkCard(Map<String, dynamic> hw) {
    final hasGrade = hw['grade'] != null;
    final dueDate = DateTime.parse(hw['due_date']);
    final isOverdue = dueDate.isBefore(DateTime.now()) && !hasGrade;

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
                    hw['title'] ?? '',
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
                      '${hw['grade']['points']}/${hw['max_points']}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Kechikkan',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hw['subject'] ?? '',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hw['description'] ?? '',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(dueDate),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  '${hw['max_points']} ball',
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
          Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Vazifalar topilmadi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return 'Bugun';
    if (diff == 1) return 'Ertaga';
    if (diff < 0) return '${-diff} kun oldin';
    if (diff < 7) return '${diff} kun keyin';
    return '${date.day}/${date.month}/${date.year}';
  }
}