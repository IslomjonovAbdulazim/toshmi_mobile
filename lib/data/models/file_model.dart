import 'package:json_annotation/json_annotation.dart';

part 'file_model.g.dart';

@JsonSerializable()
class FileModel {
  final int id;
  final String filename;
  @JsonKey(name: 'file_path')
  final String filePath;
  @JsonKey(name: 'file_size')
  final int fileSize;
  @JsonKey(name: 'uploaded_by')
  final int uploadedBy;
  @JsonKey(name: 'upload_date')
  final DateTime uploadDate;
  @JsonKey(name: 'related_id')
  final int? relatedId;
  @JsonKey(name: 'file_type')
  final String fileType;

  const FileModel({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadDate,
    this.relatedId,
    required this.fileType,
  });

  // File type constants
  static const String profile = 'profile';
  static const String homework = 'homework';
  static const String exam = 'exam';
  static const String news = 'news';

  // Check file type
  bool get isProfileImage => fileType == profile;
  bool get isHomeworkFile => fileType == homework;
  bool get isExamFile => fileType == exam;
  bool get isNewsImage => fileType == news;

  // Get file extension
  String get fileExtension {
    final parts = filename.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : '';
  }

  // Check if file is image
  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  // Check if file is document
  bool get isDocument {
    const documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    return documentExtensions.contains(fileExtension);
  }

  // Check if file is presentation
  bool get isPresentation {
    const presentationExtensions = ['ppt', 'pptx', 'odp'];
    return presentationExtensions.contains(fileExtension);
  }

  // Check if file is spreadsheet
  bool get isSpreadsheet {
    const spreadsheetExtensions = ['xls', 'xlsx', 'ods', 'csv'];
    return spreadsheetExtensions.contains(fileExtension);
  }

  // Check if file is archive
  bool get isArchive {
    const archiveExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];
    return archiveExtensions.contains(fileExtension);
  }

  // Get file type category
  String get fileCategory {
    if (isImage) return 'Rasm';
    if (isDocument) return 'Hujjat';
    if (isPresentation) return 'Taqdimot';
    if (isSpreadsheet) return 'Jadval';
    if (isArchive) return 'Arxiv';
    return 'Fayl';
  }

  // Get file icon
  String get fileIcon {
    if (isImage) return '🖼️';
    if (isDocument) {
      if (fileExtension == 'pdf') return '📄';
      return '📝';
    }
    if (isPresentation) return '📊';
    if (isSpreadsheet) return '📈';
    if (isArchive) return '🗜️';
    return '📎';
  }

  // Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      final kb = (fileSize / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      final mb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1);
      return '$gb GB';
    }
  }

  // Get formatted upload date
  String get formattedUploadDate {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = uploadDate.day;
    final month = months[uploadDate.month];
    final year = uploadDate.year;

    return '$day $month $year';
  }

  // Get short formatted date
  String get shortFormattedDate {
    final day = uploadDate.day.toString().padLeft(2, '0');
    final month = uploadDate.month.toString().padLeft(2, '0');
    final year = uploadDate.year;

    return '$day.$month.$year';
  }

  // Get time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);

    if (difference.inMinutes < 1) {
      return 'Hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks hafta oldin';
    } else {
      final months = difference.inDays ~/ 30;
      return '$months oy oldin';
    }
  }

  // Get display name (without extension for better UX)
  String get displayName {
    final parts = filename.split('.');
    if (parts.length > 1) {
      parts.removeLast(); // Remove extension
      return parts.join('.');
    }
    return filename;
  }

  // Get full display name with extension
  String get fullDisplayName => filename;

  // Check if file is recently uploaded (within last 24 hours)
  bool get isRecentlyUploaded {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);
    return difference.inHours < 24;
  }

  // Check if file is large (> 5MB)
  bool get isLargeFile => fileSize > 5 * 1024 * 1024;

  // Get download URL (assuming API structure)
  String get downloadUrl => '/files/$id';

  // Get file type in Uzbek
  String get fileTypeUz {
    switch (fileType) {
      case profile:
        return 'Profil rasmi';
      case homework:
        return 'Vazifa fayli';
      case exam:
        return 'Imtihon fayli';
      case news:
        return 'Yangilik rasmi';
      default:
        return 'Fayl';
    }
  }

  // Check if file can be previewed (images, PDFs)
  bool get canPreview {
    return isImage || fileExtension == 'pdf';
  }

  // Get MIME type
  String get mimeType {
    switch (fileExtension) {
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

  // Check if file is valid based on type and extension
  bool get isValidFile {
    switch (fileType) {
      case profile:
        return isImage;
      case homework:
      case exam:
        const allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'];
        return allowedExtensions.contains(fileExtension);
      case news:
        return isImage;
      default:
        return true;
    }
  }

  // JSON serialization
  factory FileModel.fromJson(Map<String, dynamic> json) => _$FileModelFromJson(json);
  Map<String, dynamic> toJson() => _$FileModelToJson(this);

  // Copy with method
  FileModel copyWith({
    int? id,
    String? filename,
    String? filePath,
    int? fileSize,
    int? uploadedBy,
    DateTime? uploadDate,
    int? relatedId,
    String? fileType,
  }) {
    return FileModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadDate: uploadDate ?? this.uploadDate,
      relatedId: relatedId ?? this.relatedId,
      fileType: fileType ?? this.fileType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FileModel(id: $id, filename: $filename, size: $formattedFileSize, type: $fileTypeUz)';
  }
}

// File upload response model
@JsonSerializable()
class FileUploadResponse {
  final String message;
  @JsonKey(name: 'file_id')
  final int fileId;

  const FileUploadResponse({
    required this.message,
    required this.fileId,
  });

  // JSON serialization
  factory FileUploadResponse.fromJson(Map<String, dynamic> json) => _$FileUploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);

  @override
  String toString() {
    return 'FileUploadResponse(message: $message, fileId: $fileId)';
  }
}