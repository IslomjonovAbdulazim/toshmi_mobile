import 'dart:io';

class FileUtils {
  /// Get file extension
  static String getExtension(String path) {
    final parts = path.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : '';
  }

  /// Get file name without extension
  static String getFileNameWithoutExtension(String path) {
    final fileName = path.split('/').last;
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }
    return fileName;
  }

  /// Format file size
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if file is image
  static bool isImage(String path) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(getExtension(path));
  }

  /// Check if file is document
  static bool isDocument(String path) {
    const docExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    return docExtensions.contains(getExtension(path));
  }

  /// Validate file size
  static bool isValidSize(File file, int maxSize) {
    try {
      return file.lengthSync() <= maxSize;
    } catch (e) {
      return false;
    }
  }

  /// Create directory if it doesn't exist
  static Future<Directory> ensureDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Delete file safely
  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Copy file to new location
  static Future<File?> copyFile(File sourceFile, String targetPath) async {
    try {
      if (!await sourceFile.exists()) return null;

      final targetFile = File(targetPath);
      await ensureDirectory(targetFile.parent.path);

      return await sourceFile.copy(targetPath);
    } catch (e) {
      print('Error copying file: $e');
      return null;
    }
  }

  /// Get directory size
  static Future<int> getDirectorySize(Directory directory) async {
    try {
      int totalSize = 0;
      if (!await directory.exists()) return 0;

      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      print('Error calculating directory size: $e');
      return 0;
    }
  }

  /// Clean up old files
  static Future<int> cleanupOldFiles(Directory directory, Duration maxAge) async {
    try {
      int deletedCount = 0;
      final cutoffTime = DateTime.now().subtract(maxAge);

      if (!await directory.exists()) return 0;

      await for (final entity in directory.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }
      return deletedCount;
    } catch (e) {
      print('Error cleaning up old files: $e');
      return 0;
    }
  }

  /// Get file icon based on extension
  static String getFileIcon(String path) {
    final extension = getExtension(path);
    return switch (extension) {
      'pdf' => '📄',
      'doc' || 'docx' => '📝',
      'xls' || 'xlsx' => '📊',
      'ppt' || 'pptx' => '📈',
      'txt' => '📋',
      'jpg' || 'jpeg' || 'png' || 'gif' => '🖼️',
      'zip' || 'rar' => '📦',
      _ => '📁',
    };
  }
}