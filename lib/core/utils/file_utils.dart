import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class FileUtils {
  /// Get file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = filePath.split('/').last;
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }
    return fileName;
  }

  /// Get file name from path
  static String getFileName(String filePath) {
    return filePath.split('/').last;
  }

  /// Format file size in Uzbek
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if file is image
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return AppConstants.supportedImageTypes.contains(extension);
  }

  /// Check if file is document
  static bool isDocumentFile(String filePath) {
    final extension = getFileExtension(filePath);
    return AppConstants.supportedDocumentTypes.contains(extension);
  }

  /// Get file icon emoji
  static String getFileIcon(String filePath) {
    final extension = getFileExtension(filePath);

    switch (extension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📈';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'txt':
        return '📋';
      case 'zip':
        return '🗜️';
      default:
        return '📁';
    }
  }

  /// Get file type in Uzbek
  static String getFileTypeUz(String filePath) {
    final extension = getFileExtension(filePath);

    switch (extension) {
      case 'pdf':
        return 'PDF hujjat';
      case 'doc':
      case 'docx':
        return 'Word hujjat';
      case 'xls':
      case 'xlsx':
        return 'Excel jadval';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint taqdimot';
      case 'jpg':
      case 'jpeg':
        return 'JPEG rasm';
      case 'png':
        return 'PNG rasm';
      case 'gif':
        return 'GIF rasm';
      case 'txt':
        return 'Matn fayli';
      case 'zip':
        return 'Arxiv fayli';
      default:
        return 'Fayl';
    }
  }

  /// Get MIME type
  static String getMimeType(String filePath) {
    final extension = getFileExtension(filePath);

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  /// Validate file size
  static bool isValidFileSize(File file, int maxSize) {
    try {
      return file.lengthSync() <= maxSize;
    } catch (e) {
      print('FileUtils: Error checking file size: $e');
      return false;
    }
  }

  /// Validate file type
  static bool isValidFileType(String filePath, List<String> allowedTypes) {
    final extension = getFileExtension(filePath);
    return allowedTypes.contains(extension);
  }

  /// Get file size validation error in Uzbek
  static String? getFileSizeError(File file, int maxSize) {
    try {
      final size = file.lengthSync();
      if (size > maxSize) {
        final maxSizeMB = maxSize / (1024 * 1024);
        return 'Fayl hajmi ${maxSizeMB.toStringAsFixed(1)}MB dan oshmasligi kerak';
      }
      return null;
    } catch (e) {
      print('FileUtils: Error checking file size: $e');
      return 'Fayl hajmini tekshirishda xatolik';
    }
  }

  /// Get file type validation error in Uzbek
  static String? getFileTypeError(String filePath, List<String> allowedTypes) {
    final extension = getFileExtension(filePath);
    if (!allowedTypes.contains(extension)) {
      return 'Ruxsat etilgan formatlar: ${allowedTypes.join(', ')}';
    }
    return null;
  }

  /// Generate unique file name
  static String generateUniqueFileName(String originalName) {
    final extension = getFileExtension(originalName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return '${timestamp}_$random.$extension';
  }

  /// Get app documents directory
  static Future<Directory> getAppDocumentsDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      print('FileUtils: Error getting documents directory: $e');
      rethrow;
    }
  }

  /// Get app cache directory
  static Future<Directory> getAppCacheDirectory() async {
    try {
      return await getTemporaryDirectory();
    } catch (e) {
      print('FileUtils: Error getting cache directory: $e');
      rethrow;
    }
  }

  /// Create directory if not exists
  static Future<Directory> createDirectoryIfNotExists(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        print('FileUtils: Created directory: $path');
      }
      return directory;
    } catch (e) {
      print('FileUtils: Error creating directory: $e');
      rethrow;
    }
  }

  /// Delete file safely
  static Future<bool> deleteFileSafely(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        print('FileUtils: File deleted: ${file.path}');
        return true;
      }
      print('FileUtils: File not found: ${file.path}');
      return false;
    } catch (e) {
      print('FileUtils: Error deleting file: $e');
      return false;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('FileUtils: Error checking file existence: $e');
      return false;
    }
  }

  /// Get file info
  static Future<Map<String, dynamic>?> getFileInfo(File file) async {
    try {
      if (!await file.exists()) {
        print('FileUtils: File does not exist: ${file.path}');
        return null;
      }

      final stat = await file.stat();
      return {
        'path': file.path,
        'name': getFileName(file.path),
        'nameWithoutExtension': getFileNameWithoutExtension(file.path),
        'extension': getFileExtension(file.path),
        'size': stat.size,
        'formattedSize': formatFileSize(stat.size),
        'modified': stat.modified,
        'accessed': stat.accessed,
        'exists': true,
        'isImage': isImageFile(file.path),
        'isDocument': isDocumentFile(file.path),
        'mimeType': getMimeType(file.path),
        'icon': getFileIcon(file.path),
        'typeUz': getFileTypeUz(file.path),
      };
    } catch (e) {
      print('FileUtils: Error getting file info: $e');
      return null;
    }
  }

  /// Copy file to new location
  static Future<File?> copyFile(File sourceFile, String targetPath) async {
    try {
      if (!await sourceFile.exists()) {
        print('FileUtils: Source file does not exist: ${sourceFile.path}');
        return null;
      }

      final targetFile = File(targetPath);
      final targetDir = targetFile.parent;

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final copiedFile = await sourceFile.copy(targetPath);
      print('FileUtils: File copied from ${sourceFile.path} to $targetPath');
      return copiedFile;
    } catch (e) {
      print('FileUtils: Error copying file: $e');
      return null;
    }
  }

  /// Move file to new location
  static Future<File?> moveFile(File sourceFile, String targetPath) async {
    try {
      if (!await sourceFile.exists()) {
        print('FileUtils: Source file does not exist: ${sourceFile.path}');
        return null;
      }

      final targetFile = File(targetPath);
      final targetDir = targetFile.parent;

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final movedFile = await sourceFile.rename(targetPath);
      print('FileUtils: File moved from ${sourceFile.path} to $targetPath');
      return movedFile;
    } catch (e) {
      print('FileUtils: Error moving file: $e');
      return null;
    }
  }

  /// Get directory size
  static Future<int> getDirectorySize(Directory directory) async {
    try {
      int totalSize = 0;

      if (!await directory.exists()) {
        return 0;
      }

      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      print('FileUtils: Error calculating directory size: $e');
      return 0;
    }
  }

  /// Clean up old files in directory
  static Future<int> cleanupOldFiles(Directory directory, Duration maxAge) async {
    try {
      int deletedCount = 0;
      final cutoffTime = DateTime.now().subtract(maxAge);

      if (!await directory.exists()) {
        return 0;
      }

      await for (final entity in directory.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await entity.delete();
            deletedCount++;
            print('FileUtils: Deleted old file: ${entity.path}');
          }
        }
      }

      print('FileUtils: Cleaned up $deletedCount old files');
      return deletedCount;
    } catch (e) {
      print('FileUtils: Error cleaning up old files: $e');
      return 0;
    }
  }

  /// Get available storage space (simplified)
  static Future<int> getAvailableSpace(String path) async {
    try {
      // This is a simplified version - in real app you might want to use
      // platform-specific code to get actual available space
      final directory = Directory(path);
      if (await directory.exists()) {
        // Return a reasonable default - this would be better implemented
        // with platform channels for actual disk space
        return 1024 * 1024 * 1024; // 1GB as placeholder
      }
      return 0;
    } catch (e) {
      print('FileUtils: Error getting available space: $e');
      return 0;
    }
  }
}