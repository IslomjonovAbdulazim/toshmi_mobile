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
    List filtered = homework;

    if (selectedFilter.value != 'all') {
      filtered = homework.where((hw) {
        final hasGrade = hw['grade'] != null && hw['grade']['points'] != null;

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

    // Sort by due_date - newest first
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['due_date']);
      final dateB = DateTime.parse(b['due_date']);
      return dateB.compareTo(dateA);
    });

    return filtered;
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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(30),
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
      case 'not_graded':
        chipColor = Colors.orange;
        break;
      case 'graded':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.blue;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => selectedFilter.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? chipColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(Map<String, dynamic> hw) {
    final hasGrade = hw['grade'] != null && hw['grade']['points'] != null;
    final dueDate = DateTime.parse(hw['due_date']);
    final isOverdue = dueDate.isBefore(DateTime.now()) && !hasGrade;
    final externalLinks = hw['external_links'] as List? ?? [];

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
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Kechikkan',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
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
            if (hw['description'] != null && hw['description'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                hw['description'],
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
                        Icon(Icons.link, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Foydali havolalar:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.primary,
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

  void _launchURL(String url) async {
    // You can implement URL launching here
    Get.snackbar('Havola', 'Havola ochilmoqda: $url');
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