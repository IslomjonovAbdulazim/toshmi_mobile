// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileModel _$FileModelFromJson(Map<String, dynamic> json) => FileModel(
  id: (json['id'] as num).toInt(),
  filename: json['filename'] as String,
  filePath: json['file_path'] as String,
  fileSize: (json['file_size'] as num).toInt(),
  uploadedBy: (json['uploaded_by'] as num).toInt(),
  uploadDate: DateTime.parse(json['upload_date'] as String),
  relatedId: (json['related_id'] as num?)?.toInt(),
  fileType: json['file_type'] as String,
);

Map<String, dynamic> _$FileModelToJson(FileModel instance) => <String, dynamic>{
  'id': instance.id,
  'filename': instance.filename,
  'file_path': instance.filePath,
  'file_size': instance.fileSize,
  'uploaded_by': instance.uploadedBy,
  'upload_date': instance.uploadDate.toIso8601String(),
  'related_id': instance.relatedId,
  'file_type': instance.fileType,
};

FileUploadResponse _$FileUploadResponseFromJson(Map<String, dynamic> json) =>
    FileUploadResponse(
      message: json['message'] as String,
      fileId: (json['file_id'] as num).toInt(),
    );

Map<String, dynamic> _$FileUploadResponseToJson(FileUploadResponse instance) =>
    <String, dynamic>{'message': instance.message, 'file_id': instance.fileId};
