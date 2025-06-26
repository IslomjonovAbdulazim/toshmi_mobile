import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/api_constants.dart';
import '../models/file_model.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class FileService extends GetxService {
  static FileService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // Progress streams
  final _uploadProgressController = StreamController<FileProgress>.broadcast();
  final _downloadProgressController = StreamController<FileProgress>.broadcast();

  Stream<FileProgress> get uploadProgress => _uploadProgressController.stream;
  Stream<FileProgress> get downloadProgress => _downloadProgressController.stream;

  // Cache keys
  static const String _cacheKey = 'downloaded_files';
  static const String _uploadQueueKey = 'failed_uploads';

  // File limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  // Supported file types
  static const List<String> imageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> documentTypes = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'];

  @override
  void onInit() {
    super.onInit();
    print('FileService: initialized');
    _createCacheDir();
    _retryFailedUploads();
  }

  @override
  void onClose() {
    _uploadProgressController.close();
    _downloadProgressController.close();
    super.onClose();
  }

  // ===================== TEACHER UPLOADS =====================

  /// Upload homework file (Teacher only)
  Future<ApiResult<FileUploadResponse>> uploadHomeworkFile(
      int homeworkId,
      File file,
      ) async {
    print('FileService: uploading homework file for homework $homeworkId');

    final validation = _validateFile(file, FileModel.homework);
    if (!validation.isValid) {
      print('FileService: homework file validation failed - ${validation.error}');
      return ApiResult.error(ApiError(
        detail: validation.error!,
        type: 'validation_error',
      ));
    }

    try {
      _uploadProgressController.add(FileProgress(
        fileId: 0,
        fileName: _getFileName(file.path),
        progress: 0.0,
        status: 'Fayl yuklanmoqda...',
      ));

      final result = await _apiService.uploadFile<FileUploadResponse>(
        FileEndpoints.homeworkUpload(homeworkId),
        file,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          _uploadProgressController.add(FileProgress(
            fileId: 0,
            fileName: _getFileName(file.path),
            progress: progress,
            status: 'Yuklanyapti... ${(progress * 100).toInt()}%',
          ));
        },
        fromJson: (data) => FileUploadResponse.fromJson(data),
      );

      if (result.isSuccess) {
        print('FileService: homework file uploaded successfully');
        _uploadProgressController.add(FileProgress(
          fileId: result.data!.fileId,
          fileName: _getFileName(file.path),
          progress: 1.0,
          status: 'Muvaffaqiyatli yuklandi',
        ));
      } else {
        print('FileService: homework file upload failed - ${result.error?.detail}');
        _uploadProgressController.add(FileProgress(
          fileId: 0,
          fileName: _getFileName(file.path),
          progress: 0.0,
          status: 'Yuklashda xatolik',
        ));

        // Queue for retry if network error
        if (result.error?.type == 'network_error') {
          _queueFailedUpload(file, FileModel.homework, homeworkId);
        }
      }

      return result;
    } catch (e) {
      print('FileService: homework file upload error - $e');
      _uploadProgressController.add(FileProgress(
        fileId: 0,
        fileName: _getFileName(file.path),
        progress: 0.0,
        status: 'Yuklashda xatolik',
      ));

      _queueFailedUpload(file, FileModel.homework, homeworkId);

      return ApiResult.error(ApiError(
        detail: 'Vazifa faylini yuklashda xatolik yuz berdi',
        type: 'upload_error',
      ));
    }
  }

  /// Upload exam file (Teacher only)
  Future<ApiResult<FileUploadResponse>> uploadExamFile(
      int examId,
      File file,
      ) async {
    print('FileService: uploading exam file for exam $examId');

    final validation = _validateFile(file, FileModel.exam);
    if (!validation.isValid) {
      print('FileService: exam file validation failed - ${validation.error}');
      return ApiResult.error(ApiError(
        detail: validation.error!,
        type: 'validation_error',
      ));
    }

    try {
      _uploadProgressController.add(FileProgress(
        fileId: 0,
        fileName: _getFileName(file.path),
        progress: 0.0,
        status: 'Fayl yuklanmoqda...',
      ));

      final result = await _apiService.uploadFile<FileUploadResponse>(
        FileEndpoints.examUpload(examId),
        file,
        onSendProgress: (sent, total) {
          final progress = sent / total;
          _uploadProgressController.add(FileProgress(
            fileId: 0,
            fileName: _getFileName(file.path),
            progress: progress,
            status: 'Yuklanyapti... ${(progress * 100).toInt()}%',
          ));
        },
        fromJson: (data) => FileUploadResponse.fromJson(data),
      );

      if (result.isSuccess) {
        print('FileService: exam file uploaded successfully');
        _uploadProgressController.add(FileProgress(
          fileId: result.data!.fileId,
          fileName: _getFileName(file.path),
          progress: 1.0,
          status: 'Muvaffaqiyatli yuklandi',
        ));
      } else {
        print('FileService: exam file upload failed - ${result.error?.detail}');
        _uploadProgressController.add(FileProgress(
          fileId: 0,
          fileName: _getFileName(file.path),
          progress: 0.0,
          status: 'Yuklashda xatolik',
        ));

        if (result.error?.type == 'network_error') {
          _queueFailedUpload(file, FileModel.exam, examId);
        }
      }

      return result;
    } catch (e) {
      print('FileService: exam file upload error - $e');
      _uploadProgressController.add(FileProgress(
        fileId: 0,
        fileName: _getFileName(file.path),
        progress: 0.0,
        status: 'Yuklashda xatolik',
      ));

      _queueFailedUpload(file, FileModel.exam, examId);

      return ApiResult.error(ApiError(
        detail: 'Imtihon faylini yuklashda xatolik yuz berdi',
        type: 'upload_error',
      ));
    }
  }

  // ===================== STUDENT DOWNLOADS =====================

  /// Download file by ID (Student/Teacher)
  Future<ApiResult<File>> downloadFile(
      int fileId, {
        String? fileName,
        bool useCache = true,
      }) async {
    print('FileService: downloading file $fileId');

    try {
      // Check cache first
      if (useCache) {
        final cachedFile = await _getCachedFile(fileId);
        if (cachedFile != null) {
          print('FileService: file found in cache');
          _downloadProgressController.add(FileProgress(
            fileId: fileId,
            fileName: fileName ?? 'Fayl',
            progress: 1.0,
            status: 'Keshdan olindi',
          ));
          return ApiResult.success(cachedFile);
        }
      }

      _downloadProgressController.add(FileProgress(
        fileId: fileId,
        fileName: fileName ?? 'Fayl',
        progress: 0.0,
        status: 'Yuklab olinyapti...',
      ));

      final downloadsDir = await _getDownloadsDir();
      final filePath = '${downloadsDir.path}/file_$fileId${fileName != null ? '_$fileName' : ''}';

      final result = await _apiService.downloadFile(
        FileEndpoints.download(fileId),
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            _downloadProgressController.add(FileProgress(
              fileId: fileId,
              fileName: fileName ?? 'Fayl',
              progress: progress,
              status: 'Yuklab olinyapti... ${(progress * 100).toInt()}%',
            ));
          }
        },
      );

      if (result.isSuccess) {
        final downloadedFile = File(result.data!);
        print('FileService: file downloaded successfully');

        _downloadProgressController.add(FileProgress(
          fileId: fileId,
          fileName: fileName ?? 'Fayl',
          progress: 1.0,
          status: 'Muvaffaqiyatli yuklandi',
        ));

        _cacheDownloadedFile(fileId, downloadedFile.path);
        return ApiResult.success(downloadedFile);
      } else {
        print('FileService: file download failed - ${result.error?.detail}');
        _downloadProgressController.add(FileProgress(
          fileId: fileId,
          fileName: fileName ?? 'Fayl',
          progress: 0.0,
          status: 'Yuklab olishda xatolik',
        ));
        return ApiResult.error(result.error!);
      }
    } catch (e) {
      print('FileService: file download error - $e');
      _downloadProgressController.add(FileProgress(
        fileId: fileId,
        fileName: fileName ?? 'Fayl',
        progress: 0.0,
        status: 'Yuklab olishda xatolik',
      ));
      return ApiResult.error(ApiError(
        detail: 'Faylni yuklab olishda xatolik yuz berdi',
        type: 'download_error',
      ));
    }
  }

  // ===================== FILE VALIDATION =====================

  FileValidationResult _validateFile(File file, String fileType) {
    print('FileService: validating file ${file.path} for type $fileType');

    if (!file.existsSync()) {
      return FileValidationResult(false, 'Fayl mavjud emas');
    }

    final extension = file.path.split('.').last.toLowerCase();
    final size = file.lengthSync();

    switch (fileType) {
      case FileModel.homework:
      case FileModel.exam:
        if (!documentTypes.contains(extension)) {
          return FileValidationResult(false,
              'Noto\'g\'ri fayl formati. Ruxsat etilgan formatlar: ${documentTypes.join(', ')}');
        }

        if (size > maxDocumentSize) {
          final maxSizeMB = maxDocumentSize / (1024 * 1024);
          return FileValidationResult(false,
              'Fayl hajmi juda katta. Maksimal hajm: ${maxSizeMB}MB');
        }
        break;

      default:
        return FileValidationResult(false, 'Noma\'lum fayl turi');
    }

    print('FileService: file validation passed');
    return FileValidationResult(true);
  }

  // ===================== UTILITY METHODS =====================

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf': return '📄';
      case 'doc':
      case 'docx': return '📝';
      case 'xls':
      case 'xlsx': return '📊';
      case 'ppt':
      case 'pptx': return '📈';
      case 'txt': return '📋';
      default: return '📁';
    }
  }

  // ===================== CACHE MANAGEMENT =====================

  Future<void> _createCacheDir() async {
    try {
      final cacheDir = await _getCacheDir();
      final downloadsDir = await _getDownloadsDir();

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
        print('FileService: cache directory created');
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
        print('FileService: downloads directory created');
      }
    } catch (e) {
      print('FileService: error creating cache directories - $e');
    }
  }

  Future<Directory> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/file_cache');
  }

  Future<Directory> _getDownloadsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/downloads');
  }

  void _cacheDownloadedFile(int fileId, String filePath) {
    final cachedFiles = _storage.read<Map<String, dynamic>>(_cacheKey) ?? {};
    cachedFiles[fileId.toString()] = {
      'file_path': filePath,
      'cached_at': DateTime.now().toIso8601String(),
    };
    _storage.write(_cacheKey, cachedFiles);
    print('FileService: file cached - $fileId');
  }

  Future<File?> _getCachedFile(int fileId) async {
    final cachedFiles = _storage.read<Map<String, dynamic>>(_cacheKey) ?? {};
    final fileInfo = cachedFiles[fileId.toString()];

    if (fileInfo != null && fileInfo['file_path'] != null) {
      final file = File(fileInfo['file_path']);
      if (await file.exists()) {
        return file;
      } else {
        // File was deleted, remove from cache
        cachedFiles.remove(fileId.toString());
        _storage.write(_cacheKey, cachedFiles);
        print('FileService: removed invalid cache entry - $fileId');
      }
    }

    return null;
  }

  // ===================== FAILED UPLOAD QUEUE =====================

  void _queueFailedUpload(File file, String fileType, int relatedId) {
    final uploadQueue = _storage.read<List>(_uploadQueueKey) ?? [];

    uploadQueue.add({
      'file_path': file.path,
      'file_type': fileType,
      'related_id': relatedId,
      'queued_at': DateTime.now().toIso8601String(),
    });

    _storage.write(_uploadQueueKey, uploadQueue);
    print('FileService: queued failed upload - ${file.path}');
  }

  Future<void> _retryFailedUploads() async {
    final uploadQueue = _storage.read<List>(_uploadQueueKey) ?? [];
    if (uploadQueue.isEmpty) return;

    print('FileService: retrying ${uploadQueue.length} failed uploads');
    final processedItems = <int>[];

    for (int i = 0; i < uploadQueue.length; i++) {
      try {
        final item = uploadQueue[i];
        final file = File(item['file_path']);

        if (!await file.exists()) {
          processedItems.add(i);
          continue;
        }

        final fileType = item['file_type'];
        final relatedId = item['related_id'];

        ApiResult<FileUploadResponse>? result;

        if (fileType == FileModel.homework) {
          result = await uploadHomeworkFile(relatedId, file);
        } else if (fileType == FileModel.exam) {
          result = await uploadExamFile(relatedId, file);
        }

        if (result?.isSuccess == true) {
          processedItems.add(i);
          print('FileService: retry upload successful - ${file.path}');
        }
      } catch (e) {
        print('FileService: retry upload failed - $e');
      }
    }

    // Remove processed items from queue
    for (int i = processedItems.length - 1; i >= 0; i--) {
      uploadQueue.removeAt(processedItems[i]);
    }

    _storage.write(_uploadQueueKey, uploadQueue);
    print('FileService: removed ${processedItems.length} processed items from queue');
  }

  /// Get pending uploads count
  int getPendingUploadsCount() {
    final uploadQueue = _storage.read<List>(_uploadQueueKey) ?? [];
    return uploadQueue.length;
  }

  /// Retry pending uploads manually
  Future<void> retryPendingUploads() async {
    print('FileService: manual retry of pending uploads');
    await _retryFailedUploads();
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDir();
      final downloadsDir = await _getDownloadsDir();

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      if (await downloadsDir.exists()) {
        await downloadsDir.delete(recursive: true);
      }

      _storage.remove(_cacheKey);
      _storage.remove(_uploadQueueKey);

      await _createCacheDir();
      print('FileService: cache cleared');
    } catch (e) {
      print('FileService: error clearing cache - $e');
    }
  }
}

// Progress model for streams
class FileProgress {
  final int fileId;
  final String fileName;
  final double progress; // 0.0 to 1.0
  final String status; // Uzbek status message

  FileProgress({
    required this.fileId,
    required this.fileName,
    required this.progress,
    required this.status,
  });

  @override
  String toString() => 'FileProgress(id: $fileId, progress: ${(progress * 100).toInt()}%, status: $status)';
}

// Validation result
class FileValidationResult {
  final bool isValid;
  final String? error;

  FileValidationResult(this.isValid, [this.error]);
}