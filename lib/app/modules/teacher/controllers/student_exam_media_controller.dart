import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../utils/constants/api_constants.dart';

class StudentExamMediaController extends GetxController {
  final TeacherRepository _repository = Get.find<TeacherRepository>();
  
  final isLoading = false.obs;
  final examImages = <Map<String, dynamic>>[].obs;
  
  late Map<String, dynamic> arguments;
  int get examId => arguments['exam_id'] ?? 0;
  int get studentId => arguments['student_id'] ?? 0;
  String get studentName => arguments['student_name'] ?? 'Student';
  String get examTitle => arguments['exam_title'] ?? 'Exam';

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments from navigation
    if (Get.arguments != null) {
      arguments = Get.arguments as Map<String, dynamic>;
      loadStudentExamImages();
    }
  }

  Future<void> loadStudentExamImages() async {
    try {
      isLoading.value = true;
      
      print('📤 Loading images for student $studentName (ID: $studentId) in exam $examId');
      
      // Use the real API endpoint: GET /teacher/exams/{exam_id}/students/{student_user_id}/images
      final response = await _repository.get('/teacher/exams/$examId/students/$studentId/images');
      final data = response.body as Map<String, dynamic>;
      
      examImages.value = List<Map<String, dynamic>>.from(data['images'] ?? []);
      
      print('📸 Successfully loaded ${examImages.length} images for student $studentName');
      print('📊 Total images: ${data['total_images']}, Remaining slots: ${data['remaining_slots']}');
      
      // Log student info from API response
      if (data['student_name'] != null) {
        print('👤 Student: ${data['student_name']} (${data['student_phone'] ?? 'No phone'})');
      }
    } catch (e) {
      print('❌ Failed to load student exam images: $e');
      Get.snackbar(
        'error'.tr, 
        'Failed to load student images: ${e.toString().replaceAll('Exception: ', '')}',
      );
      
      // Clear images on error
      examImages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshImages() async {
    await loadStudentExamImages();
  }

  void viewImage(Map<String, dynamic> image) {
    final imageUrl = '${ApiConstants.baseUrl}${image['image_url']}';
    
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          title: Text('view_image'.tr),
        ),
        body: GestureDetector(
          onTap: () => Get.back(),
          child: Center(
            child: Hero(
              tag: 'student_image_${image['id']}',
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String formatUploadDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;
      
      if (diff == 0) return 'today'.tr;
      if (diff == 1) return 'yesterday'.tr;
      if (diff < 7) return '$diff ${'days_ago'.tr}';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}