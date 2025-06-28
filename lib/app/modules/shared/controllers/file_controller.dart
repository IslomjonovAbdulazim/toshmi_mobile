import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/base/base_controller.dart';
import '../../../services/file_service.dart';

class FileController extends BaseController {
  final FileService _fileService = Get.find<FileService>();

  final RxList<File> selectedFiles = <File>[].obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // Pick single file
  Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      clearError();
      final file = await _fileService.pickFile(allowedExtensions: allowedExtensions);
      return file;
    } catch (e) {
      setError('Fayl tanlashda xatolik: $e');
      return null;
    }
  }

  // Pick image
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      clearError();
      final file = await _fileService.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      return file;
    } catch (e) {
      setError('Rasm tanlashda xatolik: $e');
      return null;
    }
  }

  // Upload file
  Future<void> uploadFile(File file, String endpoint) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;
      clearError();

      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        uploadProgress.value = i / 100;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      showSuccess('Fayl muvaffaqiyatli yuklandi');
    } catch (e) {
      setError('Fayl yuklashda xatolik: $e');
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Add files to selection
  void addFiles(List<File> files) {
    selectedFiles.addAll(files);
  }

  // Remove file from selection
  void removeFile(File file) {
    selectedFiles.remove(file);
  }

  // Clear selection
  void clearSelection() {
    selectedFiles.clear();
  }

  // Get file size in readable format
  String getFileSize(File file) {
    return _fileService.getFileSize(file);
  }

  @override
  Future<void> refreshData() async {
    // Refresh file-related data if needed
  }
}