// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  groupId: (json['group_id'] as num).toInt(),
  parentPhone: json['parent_phone'] as String,
  graduationYear: (json['graduation_year'] as num).toInt(),
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  groupName: json['group_name'] as String?,
  isActive: json['is_active'] as bool?,
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  group: json['group'] == null
      ? null
      : GroupModel.fromJson(json['group'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'group_id': instance.groupId,
      'parent_phone': instance.parentPhone,
      'graduation_year': instance.graduationYear,
      'name': instance.name,
      'phone': instance.phone,
      'group_name': instance.groupName,
      'is_active': instance.isActive,
      'user': instance.user,
      'group': instance.group,
    };

ChildModel _$ChildModelFromJson(Map<String, dynamic> json) => ChildModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  groupName: json['group_name'] as String,
  graduationYear: (json['graduation_year'] as num).toInt(),
);

Map<String, dynamic> _$ChildModelToJson(ChildModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'group_name': instance.groupName,
      'graduation_year': instance.graduationYear,
    };
