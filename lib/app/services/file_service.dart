import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';

class FileService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _imagePicker = ImagePicker();

  // File picker
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      throw Exception('Fayl tanlashda xatolik: $e');
    }
    return null;
  }

  // Image picker
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      throw Exception('Rasm tanlashda xatolik: $e');
    }
    return null;
  }

  // Upload profile picture (legacy method for backward compatibility)
  Future<Map<String, dynamic>> uploadProfilePicture(File file) async {
    try {
      final response = await _apiService.uploadFile('/files/profile-picture', file.path);
      return response.data;
    } catch (e) {
      throw Exception('Profil rasmini yuklashda xatolik: $e');
    }
  }

  // Upload user avatar (new persistent storage method)
  Future<Map<String, dynamic>> uploadUserAvatar(File file) async {
    try {
      print('📁 Starting avatar upload - File path: ${file.path}');
      print('📁 File size: ${getFileSize(file)}');
      
      // Validate file size (3MB max)
      if (!isValidFileSize(file, 3)) {
        print('❌ File too large: ${getFileSize(file)}');
        throw Exception('File size should not exceed 3MB');
      }

      // Validate image format
      if (!isValidImageFormat(file)) {
        print('❌ Invalid image format: ${file.path.split('.').last}');
        throw Exception('Only JPG, JPEG, PNG image formats are accepted');
      }

      print('✅ File validation passed, uploading to /files/user-avatar');
      final response = await _apiService.uploadFile('/files/user-avatar', file.path);
      
      print('📤 Upload response received: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ Avatar upload failed: $e');
      throw Exception('Avatar rasmini yuklashda xatolik: $e');
    }
  }

  // Upload homework file
  Future<Map<String, dynamic>> uploadHomeworkFile(int homeworkId, File file) async {
    try {
      final response = await _apiService.uploadFile('/files/homework/$homeworkId/upload', file.path);
      return response.data;
    } catch (e) {
      throw Exception('Vazifa faylini yuklashda xatolik: $e');
    }
  }

  // Upload exam file
  Future<Map<String, dynamic>> uploadExamFile(int examId, File file) async {
    try {
      final response = await _apiService.uploadFile('/files/exam/$examId/upload', file.path);
      return response.data;
    } catch (e) {
      throw Exception('Imtihon faylini yuklashda xatolik: $e');
    }
  }

  // Upload news image
  Future<Map<String, dynamic>> uploadNewsImage(int newsId, File file) async {
    try {
      final response = await _apiService.uploadFile('/files/news/$newsId/upload-image', file.path);
      return response.data;
    } catch (e) {
      throw Exception('Yangilik rasmini yuklashda xatolik: $e');
    }
  }

  // Download file
  Future<String> downloadFile(int fileId, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';

      await _apiService.downloadFile('/files/$fileId', savePath);
      return savePath;
    } catch (e) {
      throw Exception('Faylni yuklashda xatolik: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(int fileId) async {
    try {
      await _apiService.delete('/files/$fileId');
    } catch (e) {
      throw Exception('Faylni o\'chirishda xatolik: $e');
    }
  }

  // Check permissions
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // File validation
  bool isValidFileSize(File file, int maxSizeInMB) {
    final sizeInBytes = file.lengthSync();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxSizeInMB;
  }

  bool isValidImageFormat(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif'].contains(extension);
  }

  bool isValidDocumentFormat(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'].contains(extension);
  }

  // Get file size in readable format
  String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}