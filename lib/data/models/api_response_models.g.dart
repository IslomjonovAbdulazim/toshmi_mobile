// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  detail: json['detail'] as String,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  type: json['type'] as String?,
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'detail': instance.detail,
  'statusCode': instance.statusCode,
  'type': instance.type,
};

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  hasMore: json['has_more'] as bool,
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': instance.data.map(toJsonT).toList(),
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
  'has_more': instance.hasMore,
};

ListResponse<T> _$ListResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ListResponse<T>(
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$ListResponseToJson<T>(
  ListResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': instance.data.map(toJsonT).toList(),
  'count': instance.count,
};

StatsResponse _$StatsResponseFromJson(Map<String, dynamic> json) =>
    StatsResponse(
      totalUsers: (json['total_users'] as num).toInt(),
      totalStudents: (json['total_students'] as num).toInt(),
      totalGroups: (json['total_groups'] as num).toInt(),
      totalSubjects: (json['total_subjects'] as num).toInt(),
      activeUsers: (json['active_users'] as num).toInt(),
      activeStudents: (json['active_students'] as num).toInt(),
      teachers: (json['teachers'] as num).toInt(),
      parents: (json['parents'] as num).toInt(),
      admins: (json['admins'] as num).toInt(),
    );

Map<String, dynamic> _$StatsResponseToJson(StatsResponse instance) =>
    <String, dynamic>{
      'total_users': instance.totalUsers,
      'total_students': instance.totalStudents,
      'total_groups': instance.totalGroups,
      'total_subjects': instance.totalSubjects,
      'active_users': instance.activeUsers,
      'active_students': instance.activeStudents,
      'teachers': instance.teachers,
      'parents': instance.parents,
      'admins': instance.admins,
    };

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    HealthResponse(
      status: json['status'] as String,
      databaseConnected: json['database_connected'] as bool,
      version: json['version'] as String,
    );

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'database_connected': instance.databaseConnected,
      'version': instance.version,
    };
