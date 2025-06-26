// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: (json['id'] as num?)?.toInt(),
      studentId: (json['student_id'] as num?)?.toInt(),
      groupSubjectId: (json['group_subject_id'] as num?)?.toInt(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      subject: json['subject'] as String?,
      teacher: json['teacher'] as String?,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'group_subject_id': instance.groupSubjectId,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'subject': instance.subject,
      'teacher': instance.teacher,
    };

AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    AttendanceRecord(
      studentId: (json['student_id'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$AttendanceRecordToJson(AttendanceRecord instance) =>
    <String, dynamic>{
      'student_id': instance.studentId,
      'status': instance.status,
    };

BulkAttendanceRequest _$BulkAttendanceRequestFromJson(
  Map<String, dynamic> json,
) => BulkAttendanceRequest(
  groupSubjectId: (json['group_subject_id'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  records: (json['records'] as List<dynamic>)
      .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BulkAttendanceRequestToJson(
  BulkAttendanceRequest instance,
) => <String, dynamic>{
  'group_subject_id': instance.groupSubjectId,
  'date': instance.date.toIso8601String(),
  'records': instance.records,
};

AttendanceStats _$AttendanceStatsFromJson(Map<String, dynamic> json) =>
    AttendanceStats(
      present: (json['present'] as num).toInt(),
      absent: (json['absent'] as num).toInt(),
      late: (json['late'] as num).toInt(),
      excused: (json['excused'] as num).toInt(),
      totalDays: (json['total_days'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceStatsToJson(AttendanceStats instance) =>
    <String, dynamic>{
      'present': instance.present,
      'absent': instance.absent,
      'late': instance.late,
      'excused': instance.excused,
      'total_days': instance.totalDays,
    };
