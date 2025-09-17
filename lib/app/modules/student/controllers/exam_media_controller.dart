import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../services/file_service.dart';
import '../../../utils/constants/api_constants.dart';

class ExamMediaController extends GetxController {
  final StudentRepository _repository = Get.find<StudentRepository>();
  final FileService _fileService = Get.find<FileService>();
  
  final isLoading = false.obs;
  final isUploading = false.obs;
  final examImages = <Map<String, dynamic>>[].obs;
  final remainingSlots = 5.obs;
  
  late Map<String, dynamic> exam;
  int get examId => exam['id'] ?? 0;
  
  // Check if editing is allowed based on exam deadline
  bool get canEditImages {
    try {
      final examDateStr = exam['exam_date'] as String?;
      if (examDateStr == null) return true;
      
      final examDate = DateTime.parse(examDateStr);
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      
      // Allow if exam date is yesterday, today, or future
      return examDate.isAfter(yesterday) || examDate.isAtSameMomentAs(yesterday);
    } catch (e) {
      print('❌ Error checking exam date: $e');
      return true; // Default to allowing edits if date parsing fails
    }
  }

  @override
  void onInit() {
    super.onInit();
    
    // Get exam data from arguments
    if (Get.arguments != null) {
      exam = Get.arguments as Map<String, dynamic>;
      loadExamImages();
    }
  }

  Future<void> loadExamImages() async {
    try {
      isLoading.value = true;
      
      // Call API to get student's exam images
      final response = await _repository.get('/student/exams/$examId/images');
      final data = response.body as Map<String, dynamic>;
      
      examImages.value = List<Map<String, dynamic>>.from(data['images'] ?? []);
      remainingSlots.value = data['remaining_slots'] ?? 5;
      
      print('📸 Loaded ${examImages.length} exam images, ${remainingSlots.value} slots remaining');
    } catch (e) {
      print('❌ Failed to load exam images: $e');
      Get.snackbar('error'.tr, 'failed_to_load_images'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshImages() async {
    await loadExamImages();
  }

  Future<void> pickAndUploadImage() async {
    if (!canEditImages) {
      Get.snackbar('error'.tr, 'deadline_passed_cannot_edit'.tr);
      return;
    }
    
    if (remainingSlots.value <= 0) {
      Get.snackbar('error'.tr, 'max_images_reached'.tr);
      return;
    }

    // Show image source bottom sheet
    _showImageSourceBottomSheet();
  }

  void _showImageSourceBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'choose_image_source'.tr,
              style: Get.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Get.theme.colorScheme.primary),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                _pickAndUploadFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Get.theme.colorScheme.primary),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                _pickAndUploadFromSource(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFromSource(ImageSource source) async {
    try {
      isUploading.value = true;

      // Pick image directly - system will handle permissions automatically
      final imageFile = await _fileService.pickImage(source: source);
      if (imageFile == null) return;

      // Upload image to exam
      await uploadExamImage(imageFile);
    } catch (e) {
      print('❌ Image upload error: $e');
      Get.snackbar('error'.tr, e.toString().replaceAll('Exception: ', ''));
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> uploadExamImage(File imageFile) async {
    try {
      print('📤 Uploading exam image: ${imageFile.path}');
      
      // Upload image using repository
      final response = await _repository.uploadFile(
        '/student/exams/$examId/upload-image',
        imageFile,
      );
      
      final data = response.body as Map<String, dynamic>;
      
      print('✅ Image uploaded successfully: ${data['image_url']}');
      
      // Refresh the images list
      await loadExamImages();
      
      Get.snackbar(
        'success'.tr,
        'image_uploaded_successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
      );
    } catch (e) {
      print('❌ Failed to upload exam image: $e');
      throw Exception('upload_failed'.tr);
    }
  }

  Future<void> deleteImage(Map<String, dynamic> image) async {
    if (!canEditImages) {
      Get.snackbar('error'.tr, 'deadline_passed_cannot_edit'.tr);
      return;
    }
    
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('delete_image'.tr),
          content: Text('delete_image_confirmation'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              style: FilledButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.error,
              ),
              child: Text('delete'.tr),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      print('🗑️ Deleting exam image: ${image['id']}');
      
      // Delete image via API
      await _repository.delete('/student/exams/images/${image['id']}');
      
      print('✅ Image deleted successfully');
      
      // Refresh the images list
      await loadExamImages();
      
      Get.snackbar(
        'success'.tr,
        'image_deleted_successfully'.tr,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
      );
    } catch (e) {
      print('❌ Failed to delete image: $e');
      Get.snackbar('error'.tr, 'delete_failed'.tr);
    }
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
          onTap: () => Get.back(), // Close fullscreen on tap
          child: Center(
            child: Hero(
              tag: 'image_${image['id']}',
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