// lib/app/data/repositories/news_repository.dart
import '../../../core/base/base_repository.dart';
import '../../utils/constants/api_constants.dart';

class NewsRepository extends BaseRepository {

  // Get all published news
  Future<List<dynamic>> getNews() async {
    try {
      final response = await get(ApiConstants.news);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  // Get news by ID
  Future<Map<String, dynamic>> getNewsById(int newsId) async {
    try {
      final response = await get('${ApiConstants.news}/$newsId');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  // Get file URL for images
  String getFileUrl(int fileId) {
    return '${ApiConstants.baseUrl}${ApiConstants.files}/$fileId';
  }

  @override
  void clearCache() {
    // Clear news cache if needed
  }
}