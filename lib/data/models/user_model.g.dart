// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  phone: json['phone'] as String,
  role: json['role'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  profileImageId: (json['profile_image_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'role': instance.role,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'is_active': instance.isActive,
  'created_at': instance.createdAt.toIso8601String(),
  'profile_image_id': instance.profileImageId,
};
