import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/models/news_model.dart';
import '../../../services/api_service.dart';

class NewsController extends BaseController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<News> newsList = <News>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNews();
  }

  // Load news list
  Future<void> loadNews({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      newsList.clear();
    }

    if (!hasMoreData.value) return;

    try {
      setLoading(currentPage.value == 1);
      clearError();

      final response = await _apiService.get('/news', queryParameters: {
        'page': currentPage.value,
        'limit': 10,
      });

      final newsData = (response.data as List<dynamic>)
          .map((json) => News.fromJson(json))
          .toList();

      if (refresh) {
        newsList.assignAll(newsData);
      } else {
        newsList.addAll(newsData);
      }

      if (newsData.length < 10) {
        hasMoreData.value = false;
      } else {
        currentPage.value++;
      }
    } catch (e) {
      setError('Yangiliklar yuklanmadi: $e');
    } finally {
      setLoading(false);
      isLoadingMore.value = false;
    }
  }

  // Load more news
  Future<void> loadMoreNews() async {
    if (!hasMoreData.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    await loadNews();
  }

  // Get news by ID
  News? getNewsById(int id) {
    try {
      return newsList.firstWhere((news) => news.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search news
  List<News> searchNews(String query) {
    if (query.isEmpty) return newsList;

    return newsList.where((news) =>
    news.title.toLowerCase().contains(query.toLowerCase()) ||
        news.content.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get recent news
  List<News> getRecentNews({int limit = 5}) {
    final sortedNews = List<News>.from(newsList)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedNews.take(limit).toList();
  }

  @override
  Future<void> refreshData() async {
    await loadNews(refresh: true);
  }
}