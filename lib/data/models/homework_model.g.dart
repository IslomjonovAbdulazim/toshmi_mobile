// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeworkModel _$HomeworkModelFromJson(Map<String, dynamic> json) =>
    HomeworkModel(
      id: (json['id'] as num).toInt(),
      groupSubjectId: (json['group_subject_id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      maxPoints: (json['max_points'] as num).toInt(),
      externalLinks: (json['external_links'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      documentIds: (json['document_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      subject: json['subject'] as String?,
      teacher: json['teacher'] as String?,
      group: json['group'] as String?,
      grade: json['grade'] == null
          ? null
          : GradeModel.fromJson(json['grade'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeworkModelToJson(HomeworkModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_subject_id': instance.groupSubjectId,
      'title': instance.title,
      'description': instance.description,
      'due_date': instance.dueDate.toIso8601String(),
      'max_points': instance.maxPoints,
      'external_links': instance.externalLinks,
      'document_ids': instance.documentIds,
      'created_at': instance.createdAt?.toIso8601String(),
      'subject': instance.subject,
      'teacher': instance.teacher,
      'group': instance.group,
      'grade': instance.grade,
    };

HomeworkRequest _$HomeworkRequestFromJson(Map<String, dynamic> json) =>
    HomeworkRequest(
      groupSubjectId: (json['group_subject_id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      maxPoints: (json['max_points'] as num).toInt(),
      externalLinks: (json['external_links'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HomeworkRequestToJson(HomeworkRequest instance) =>
    <String, dynamic>{
      'group_subject_id': instance.groupSubjectId,
      'title': instance.title,
      'description': instance.description,
      'due_date': instance.dueDate.toIso8601String(),
      'max_points': instance.maxPoints,
      'external_links': instance.externalLinks,
    };
