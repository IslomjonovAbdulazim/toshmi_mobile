// lib/app/modules/student/views/student_news_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class StudentNewsView extends StatefulWidget {
  const StudentNewsView({super.key});

  @override
  State<StudentNewsView> createState() => _StudentNewsViewState();
}

class _StudentNewsViewState extends State<StudentNewsView> {
  final isLoading = false.obs;
  final news = <Map<String, dynamic>>[].obs;

  @override
  void initInit() {
    super.initState();
    loadNews();
  }

  Future<void> loadNews() async {
    try {
      isLoading.value = true;
      // TODO: Replace with actual news repository call
      // final data = await newsRepository.getNews();

      // Mock data for now
      await Future.delayed(const Duration(seconds: 1));
      news.value = [
        {
          'id': 1,
          'title': 'Yangi o\'quv yili boshlanishi',
          'content': 'Hurmatli o\'quvchilar! Yangi o\'quv yili 1-sentabrdan boshlanadi. Barcha o\'quvchilar soat 8:00 da maktabda bo\'lishlari kerak.',
          'author': 'Maktab ma\'muriyati',
          'created_at': '2024-08-25T10:00:00',
          'is_important': true,
        },
        {
          'id': 2,
          'title': 'Sport musobaqalari',
          'content': 'Maktabimizda futbol musobaqalari o\'tkaziladi. Ishtirok etmoqchi bo\'lganlar sport o\'qituvchisiga murojaat qilsinlar.',
          'author': 'Sport o\'qituvchisi',
          'created_at': '2024-08-24T14:30:00',
          'is_important': false,
        },
        {
          'id': 3,
          'title': 'Kitobxona yangi kitoblar',
          'content': 'Maktab kitobxonasida yangi kitoblar keldi. O\'quvchilar ulardan foydalanishlari mumkin.',
          'author': 'Kutubxonachi',
          'created_at': '2024-08-23T11:15:00',
          'is_important': false,
        },
      ];
    } catch (e) {
      Get.snackbar('Xato', 'Yangiliklarni yuklashda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Yangiliklar',
        showBackButton: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (news.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: loadNews,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: news.length,
            itemBuilder: (context, index) => _buildNewsCard(news[index]),
          ),
        );
      }),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> newsItem) {
    final isImportant = newsItem['is_important'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isImportant ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isImportant ? Border.all(color: Colors.orange, width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isImportant) ...[
                    Icon(Icons.priority_high, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      newsItem['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                newsItem['content'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    newsItem['author'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(newsItem['created_at']),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Hozircha yangiliklar yo\'q',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: loadNews,
            child: const Text('Qayta yuklash'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;

      if (diff == 0) return 'Bugun';
      if (diff == 1) return 'Kecha';
      if (diff < 7) return '$diff kun oldin';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}