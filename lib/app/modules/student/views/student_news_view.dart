import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toshmi_mobile/app/services/auth_service.dart';
import '../../../data/repositories/news_repository.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class StudentNewsView extends StatefulWidget {
  const StudentNewsView({super.key});

  @override
  State<StudentNewsView> createState() => _StudentNewsViewState();
}

class _StudentNewsViewState extends State<StudentNewsView> {
  final NewsRepository newsRepository = NewsRepository();
  final isLoading = false.obs;
  final news = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  Future<void> loadNews() async {
    try {
      isLoading.value = true;
      final data = await newsRepository.getNews();
      news.value = data.cast<Map<String, dynamic>>();
    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'news'.tr, showBackButton: true),
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
    final imageIds = newsItem['image_ids'] as List? ?? [];
    final externalLinks = newsItem['external_links'] as List? ?? [];
    final firstImageId = imageIds.isNotEmpty ? imageIds.first : null;
    final showImage = firstImageId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                newsRepository.getFileUrl(firstImageId),
                width: double.infinity,
                headers: {
                  'Authorization': 'Bearer ${AuthService().token}',
                },
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return SizedBox();
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsItem['title'] ?? '',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  newsItem['content'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                if (externalLinks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'useful_links'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...externalLinks
                            .map(
                              (link) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: GestureDetector(
                              onTap: () => _launchURL(link.toString()),
                              child: Text(
                                link.toString(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'admin'.tr,
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
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('error'.tr, 'Could not launch $url');
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'link_opening'.tr);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'no_news_yet'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: loadNews, child: Text('retry'.tr)),
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

      if (diff == 0) return 'today'.tr;
      if (diff == 1) return 'yesterday'.tr;
      if (diff < 7) return '$diff ${'days_ago'.tr}';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}