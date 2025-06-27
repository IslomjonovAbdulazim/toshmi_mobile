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

  // Computed properties
  String get fileExtension => filename.split('.').last.toLowerCase();

  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  bool get isDocument {
    const docExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    return docExtensions.contains(fileExtension);
  }

  bool get isProfileImage => fileType == profile;
  bool get isHomeworkFile => fileType == homework;
  bool get isExamFile => fileType == exam;
  bool get isNewsImage => fileType == news;

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get displayName {
    final parts = filename.split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }
    return filename;
  }

  bool get isRecentlyUploaded {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);
    return difference.inHours < 24;
  }

  bool get isLargeFile => fileSize > 5 * 1024 * 1024;

  String get downloadUrl => '/files/$id';

  String get fileTypeUz => switch (fileType) {
    profile => 'Profil rasmi',
    homework => 'Vazifa fayli',
    exam => 'Imtihon fayli',
    news => 'Yangilik rasmi',
    _ => 'Fayl',
  };

  bool get canPreview => isImage || fileExtension == 'pdf';

  String get mimeType => switch (fileExtension) {
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls' => 'application/vnd.ms-excel',
    'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'txt' => 'text/plain',
    'zip' => 'application/zip',
    _ => 'application/octet-stream',
  };

  bool get isValidFile => switch (fileType) {
    profile => isImage,
    homework || exam => isDocument,
    news => isImage,
    _ => true,
  };

  String get fileCategory {
    if (isImage) return 'Rasm';
    if (isDocument) return 'Hujjat';
    return 'Fayl';
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
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FileModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FileModel(id: $id, filename: $filename, size: $formattedFileSize)';
}

@JsonSerializable()
class FileUploadResponse {
  final String message;
  @JsonKey(name: 'file_id')
  final int fileId;

  const FileUploadResponse({
    required this.message,
    required this.fileId,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) => _$FileUploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);

  @override
  String toString() => 'FileUploadResponse(message: $message, fileId: $fileId)';
}