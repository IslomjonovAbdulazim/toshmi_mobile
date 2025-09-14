import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/widgets/cards/news_card.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/empty_state_widget.dart';
import '../../../utils/widgets/common/error_widget.dart';
import '../../../utils/widgets/common/loading_widget.dart';
import '../controllers/news_controller.dart';

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Yangiliklar',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.newsList.isEmpty) {
          return const LoadingWidget(message: 'Yangiliklar yuklanmoqda...');
        }

        if (controller.hasError.value) {
          return CustomErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshData,
          );
        }

        if (controller.newsList.isEmpty) {
          return const EmptyStateWidget(
            title: 'Yangiliklar yo\'q',
            message: 'Hozircha hech qanday yangilik yo\'q',
            icon: Icons.article_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.newsList.length +
                (controller.hasMoreData.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.newsList.length) {
                return _buildLoadMoreWidget();
              }

              final news = controller.newsList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NewsCard(
                  news: news,
                  onTap: () => _showNewsDetails(news),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadMoreWidget() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return GestureDetector(
        onTap: controller.loadMoreNews,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Get.theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, color: Get.theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Ko\'proq yuklash',
                style: TextStyle(color: Get.theme.primaryColor),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showNewsDetails(news) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    news.title,
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Get.theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: NewsCard(
                  news: news,
                  showFullContent: true,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}