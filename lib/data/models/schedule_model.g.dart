// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    ScheduleModel(
      id: (json['id'] as num?)?.toInt(),
      groupSubjectId: (json['group_subject_id'] as num?)?.toInt(),
      day: (json['day'] as num).toInt(),
      startTime: ScheduleModel._timeFromJson(json['start_time'] as String),
      endTime: ScheduleModel._timeFromJson(json['end_time'] as String),
      room: json['room'] as String?,
      subject: json['subject'] as String?,
      teacher: json['teacher'] as String?,
    );

Map<String, dynamic> _$ScheduleModelToJson(ScheduleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_subject_id': instance.groupSubjectId,
      'day': instance.day,
      'start_time': ScheduleModel._timeToJson(instance.startTime),
      'end_time': ScheduleModel._timeToJson(instance.endTime),
      'room': instance.room,
      'subject': instance.subject,
      'teacher': instance.teacher,
    };

ScheduleRequest _$ScheduleRequestFromJson(Map<String, dynamic> json) =>
    ScheduleRequest(
      groupSubjectId: (json['group_subject_id'] as num).toInt(),
      day: (json['day'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      room: json['room'] as String,
    );

Map<String, dynamic> _$ScheduleRequestToJson(ScheduleRequest instance) =>
    <String, dynamic>{
      'group_subject_id': instance.groupSubjectId,
      'day': instance.day,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'room': instance.room,
    };
