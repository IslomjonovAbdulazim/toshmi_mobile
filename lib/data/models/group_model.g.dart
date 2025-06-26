// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  academicYear: json['academic_year'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  studentCount: (json['student_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'academic_year': instance.academicYear,
      'created_at': instance.createdAt.toIso8601String(),
      'student_count': instance.studentCount,
    };
