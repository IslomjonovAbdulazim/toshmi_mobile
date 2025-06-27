import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  // File limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  // Supported file types
  static const List<String> imageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> documentTypes = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'];

  @override
  void onInit() {
    super.onInit();
    _createCacheDir();
  }

  @override
  void onClose() {
    _uploadProgressController.close();
    _downloadProgressController.close();
    super.onClose();
  }

  // Upload profile picture
  Future<ApiResult<FileUploadResponse>> uploadProfilePicture(File file) async {
    final validation = _validateFile(file, FileModel.profile);
    if (!validation.isValid) {
      return ApiResult.error(ApiError.validationError(validation.errorMessage!));
    }

    return _uploadFileWithProgress(
      FileEndpoints.profilePicture,
      file,
      'Profil rasmi',
    );
  }

  // Upload homework file
  Future<ApiResult<FileUploadResponse>> uploadHomeworkFile(File file, int homeworkId) async {
    final validation = _validateFile(file, FileModel.homework);
    if (!validation.isValid) {
      return ApiResult.error(ApiError.validationError(validation.errorMessage!));
    }

    return _uploadFileWithProgress(
      FileEndpoints.homeworkUpload(homeworkId),
      file,
      'Vazifa fayli',
    );
  }

  // Upload exam file
  Future<ApiResult<FileUploadResponse>> uploadExamFile(File file, int examId) async {
    final validation = _validateFile(file, FileModel.exam);
    if (!validation.isValid) {
      return ApiResult.error(ApiError.validationError(validation.errorMessage!));
    }

    return _uploadFileWithProgress(
      FileEndpoints.examUpload(examId),
      file,
      'Imtihon fayli',
    );
  }

  // Generic file upload with progress
  Future<ApiResult<FileUploadResponse>> _uploadFileWithProgress(
      String endpoint,
      File file,
      String displayName,
      ) async {
    try {
      final fileId = file.hashCode; // Use file hash as temporary ID

      _uploadProgressController.add(FileProgress(
        fileId: fileId,
        fileName: displayName,
        progress: 0.0,
        status: 'Yuklanmoqda...',
      ));

      final result = await _apiService.uploadFile<FileUploadResponse>(
        endpoint,
        file,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            _uploadProgressController.add(FileProgress(
              fileId: fileId,
              fileName: displayName,
              progress: progress,
              status: 'Yuklanmoqda... ${(progress * 100).toInt()}%',
            ));
          }
        },
        fromJson: (data) => FileUploadResponse.fromJson(data),
      );

      if (result.isSuccess) {
        _uploadProgressController.add(FileProgress(
          fileId: fileId,
          fileName: displayName,
          progress: 1.0,
          status: 'Muvaffaqiyatli yuklandi',
        ));
      } else {
        _uploadProgressController.add(FileProgress(
          fileId: fileId,
          fileName: displayName,
          progress: 0.0,
          status: 'Yuklashda xatolik',
        ));
      }

      return result;
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: 'Faylni yuklashda xatolik: ${e.toString()}',
        type: 'upload_error',
      ));
    }
  }

  // Download file
  Future<ApiResult<File>> downloadFile(int fileId, {String? fileName}) async {
    try {
      // Check cache first
      final cachedFile = await _getCachedFile(fileId);
      if (cachedFile != null && await cachedFile.exists()) {
        _downloadProgressController.add(FileProgress(
          fileId: fileId,
          fileName: fileName ?? 'Fayl',
          progress: 1.0,
          status: 'Keshdan olindi',
        ));
        return ApiResult.success(cachedFile);
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

        _downloadProgressController.add(FileProgress(
          fileId: fileId,
          fileName: fileName ?? 'Fayl',
          progress: 1.0,
          status: 'Muvaffaqiyatli yuklandi',
        ));

        _cacheDownloadedFile(fileId, downloadedFile.path);
        return ApiResult.success(downloadedFile);
      } else {
        _downloadProgressController.add(FileProgress(
          fileId: fileId,
          fileName: fileName ?? 'Fayl',
          progress: 0.0,
          status: 'Yuklab olishda xatolik',
        ));
        return ApiResult.error(ApiError(
          detail: 'Faylni yuklab olishda xatolik',
          type: 'download_error',
        ));
      }
    } catch (e) {
      return ApiResult.error(ApiError(
        detail: 'Faylni yuklab olishda xatolik: ${e.toString()}',
        type: 'download_error',
      ));
    }
  }

  // Delete file
  Future<ApiResult<void>> deleteFile(int fileId) async {
    final result = await _apiService.delete<void>(
      FileEndpoints.delete(fileId),
      fromJson: (data) => null,
    );

    if (result.isSuccess) {
      await _removeCachedFile(fileId);
    }

    return result;
  }

  // File validation
  FileValidationResult _validateFile(File file, String fileType) {
    if (!file.existsSync()) {
      return FileValidationResult(false, 'Fayl mavjud emas');
    }

    final extension = file.path.split('.').last.toLowerCase();
    final size = file.lengthSync();

    switch (fileType) {
      case FileModel.profile:
        if (!imageTypes.contains(extension)) {
          return FileValidationResult(false,
              'Noto\'g\'ri fayl formati. Ruxsat etilgan formatlar: ${imageTypes.join(', ')}');
        }
        if (size > maxImageSize) {
          final maxSizeMB = maxImageSize / (1024 * 1024);
          return FileValidationResult(false,
              'Fayl hajmi juda katta. Maksimal hajm: ${maxSizeMB}MB');
        }
        break;

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

    return FileValidationResult(true);
  }

  // Cache management
  Future<void> _createCacheDir() async {
    try {
      final cacheDir = await _getCacheDir();
      final downloadsDir = await _getDownloadsDir();

      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
    } catch (e) {
      print('Error creating cache directories: $e');
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
    final cachedFiles = _storage.read<Map<String, dynamic>>('downloaded_files') ?? {};
    cachedFiles[fileId.toString()] = {
      'file_path': filePath,
      'cached_at': DateTime.now().toIso8601String(),
    };
    _storage.write('downloaded_files', cachedFiles);
  }

  Future<File?> _getCachedFile(int fileId) async {
    final cachedFiles = _storage.read<Map<String, dynamic>>('downloaded_files') ?? {};
    final fileData = cachedFiles[fileId.toString()];

    if (fileData != null) {
      final filePath = fileData['file_path'] as String;
      final file = File(filePath);

      if (await file.exists()) {
        return file;
      }
    }

    return null;
  }

  Future<void> _removeCachedFile(int fileId) async {
    final cachedFiles = _storage.read<Map<String, dynamic>>('downloaded_files') ?? {};
    final fileData = cachedFiles[fileId.toString()];

    if (fileData != null) {
      final filePath = fileData['file_path'] as String;
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      cachedFiles.remove(fileId.toString());
      _storage.write('downloaded_files', cachedFiles);
    }
  }

  // Utility methods
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => '📄',
      'doc' || 'docx' => '📝',
      'xls' || 'xlsx' => '📊',
      'ppt' || 'pptx' => '📈',
      'txt' => '📋',
      _ => '📁',
    };
  }
}