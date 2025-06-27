class File {
  final int id;
  final String filename;
  final String filePath;
  final int fileSize;
  final int uploadedBy;
  final DateTime uploadDate;
  final int relatedId;
  final String fileType;

  File({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.fileSize,
    required this.uploadedBy,
    required this.uploadDate,
    required this.relatedId,
    required this.fileType,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      filename: json['filename'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      uploadedBy: json['uploaded_by'],
      uploadDate: DateTime.parse(json['upload_date']),
      relatedId: json['related_id'],
      fileType: json['file_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'file_path': filePath,
      'file_size': fileSize,
      'uploaded_by': uploadedBy,
      'upload_date': uploadDate.toIso8601String(),
      'related_id': relatedId,
      'file_type': fileType,
    };
  }

  File copyWith({
    int? id,
    String? filename,
    String? filePath,
    int? fileSize,
    int? uploadedBy,
    DateTime? uploadDate,
    int? relatedId,
    String? fileType,
  }) {
    return File(
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
}