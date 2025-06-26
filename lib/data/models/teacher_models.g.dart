// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradingTableModel _$GradingTableModelFromJson(Map<String, dynamic> json) =>
    GradingTableModel(
      homework: json['homework'] == null
          ? null
          : HomeworkExamInfo.fromJson(json['homework'] as Map<String, dynamic>),
      exam: json['exam'] == null
          ? null
          : HomeworkExamInfo.fromJson(json['exam'] as Map<String, dynamic>),
      students: (json['students'] as List<dynamic>)
          .map((e) => StudentGradeInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradingTableModelToJson(GradingTableModel instance) =>
    <String, dynamic>{
      'homework': instance.homework,
      'exam': instance.exam,
      'students': instance.students,
    };

HomeworkExamInfo _$HomeworkExamInfoFromJson(Map<String, dynamic> json) =>
    HomeworkExamInfo(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      maxPoints: (json['max_points'] as num).toInt(),
    );

Map<String, dynamic> _$HomeworkExamInfoToJson(HomeworkExamInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'max_points': instance.maxPoints,
    };

StudentGradeInfo _$StudentGradeInfoFromJson(Map<String, dynamic> json) =>
    StudentGradeInfo(
      studentId: (json['student_id'] as num).toInt(),
      name: json['name'] as String,
      grade: GradeInfo.fromJson(json['grade'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentGradeInfoToJson(StudentGradeInfo instance) =>
    <String, dynamic>{
      'student_id': instance.studentId,
      'name': instance.name,
      'grade': instance.grade,
    };

GradeInfo _$GradeInfoFromJson(Map<String, dynamic> json) => GradeInfo(
  points: (json['points'] as num?)?.toInt(),
  comment: json['comment'] as String,
);

Map<String, dynamic> _$GradeInfoToJson(GradeInfo instance) => <String, dynamic>{
  'points': instance.points,
  'comment': instance.comment,
};

GradeRequest _$GradeRequestFromJson(Map<String, dynamic> json) => GradeRequest(
  studentId: (json['student_id'] as num).toInt(),
  points: (json['points'] as num).toInt(),
  comment: json['comment'] as String,
);

Map<String, dynamic> _$GradeRequestToJson(GradeRequest instance) =>
    <String, dynamic>{
      'student_id': instance.studentId,
      'points': instance.points,
      'comment': instance.comment,
    };

BulkHomeworkGradeRequest _$BulkHomeworkGradeRequestFromJson(
  Map<String, dynamic> json,
) => BulkHomeworkGradeRequest(
  homeworkId: (json['homework_id'] as num).toInt(),
  grades: (json['grades'] as List<dynamic>)
      .map((e) => GradeRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BulkHomeworkGradeRequestToJson(
  BulkHomeworkGradeRequest instance,
) => <String, dynamic>{
  'homework_id': instance.homeworkId,
  'grades': instance.grades,
};

BulkExamGradeRequest _$BulkExamGradeRequestFromJson(
  Map<String, dynamic> json,
) => BulkExamGradeRequest(
  examId: (json['exam_id'] as num).toInt(),
  grades: (json['grades'] as List<dynamic>)
      .map((e) => GradeRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BulkExamGradeRequestToJson(
  BulkExamGradeRequest instance,
) => <String, dynamic>{'exam_id': instance.examId, 'grades': instance.grades};

AttendanceTableModel _$AttendanceTableModelFromJson(
  Map<String, dynamic> json,
) => AttendanceTableModel(
  groupSubject: GroupSubjectInfo.fromJson(
    json['group_subject'] as Map<String, dynamic>,
  ),
  dateRange: DateRangeInfo.fromJson(json['date_range'] as Map<String, dynamic>),
  dates: (json['dates'] as List<dynamic>).map((e) => e as String).toList(),
  students: (json['students'] as List<dynamic>)
      .map((e) => StudentAttendanceInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AttendanceTableModelToJson(
  AttendanceTableModel instance,
) => <String, dynamic>{
  'group_subject': instance.groupSubject,
  'date_range': instance.dateRange,
  'dates': instance.dates,
  'students': instance.students,
};

GroupSubjectInfo _$GroupSubjectInfoFromJson(Map<String, dynamic> json) =>
    GroupSubjectInfo(
      id: (json['id'] as num).toInt(),
      groupName: json['group_name'] as String,
      subjectName: json['subject_name'] as String,
    );

Map<String, dynamic> _$GroupSubjectInfoToJson(GroupSubjectInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_name': instance.groupName,
      'subject_name': instance.subjectName,
    };

DateRangeInfo _$DateRangeInfoFromJson(Map<String, dynamic> json) =>
    DateRangeInfo(
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      totalDates: (json['total_dates'] as num).toInt(),
    );

Map<String, dynamic> _$DateRangeInfoToJson(DateRangeInfo instance) =>
    <String, dynamic>{
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'total_dates': instance.totalDates,
    };

StudentAttendanceInfo _$StudentAttendanceInfoFromJson(
  Map<String, dynamic> json,
) => StudentAttendanceInfo(
  studentId: (json['student_id'] as num).toInt(),
  name: json['name'] as String,
  attendanceByDate: Map<String, String>.from(json['attendance_by_date'] as Map),
  summary: AttendanceStats.fromJson(json['summary'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StudentAttendanceInfoToJson(
  StudentAttendanceInfo instance,
) => <String, dynamic>{
  'student_id': instance.studentId,
  'name': instance.name,
  'attendance_by_date': instance.attendanceByDate,
  'summary': instance.summary,
};
