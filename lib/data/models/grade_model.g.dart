// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeModel _$GradeModelFromJson(Map<String, dynamic> json) => GradeModel(
  points: (json['points'] as num?)?.toInt(),
  comment: json['comment'] as String,
  maxPoints: (json['max_points'] as num?)?.toInt(),
  gradedAt: json['graded_at'] == null
      ? null
      : DateTime.parse(json['graded_at'] as String),
);

Map<String, dynamic> _$GradeModelToJson(GradeModel instance) =>
    <String, dynamic>{
      'points': instance.points,
      'comment': instance.comment,
      'max_points': instance.maxPoints,
      'graded_at': instance.gradedAt?.toIso8601String(),
    };

HomeworkGradeModel _$HomeworkGradeModelFromJson(Map<String, dynamic> json) =>
    HomeworkGradeModel(
      id: (json['id'] as num?)?.toInt(),
      studentId: (json['student_id'] as num?)?.toInt(),
      homeworkId: (json['homework_id'] as num?)?.toInt(),
      homeworkTitle: json['homework_title'] as String?,
      subject: json['subject'] as String?,
      points: (json['points'] as num?)?.toInt(),
      maxPoints: (json['max_points'] as num).toInt(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      comment: json['comment'] as String,
      gradedAt: json['graded_at'] == null
          ? null
          : DateTime.parse(json['graded_at'] as String),
    );

Map<String, dynamic> _$HomeworkGradeModelToJson(HomeworkGradeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'homework_id': instance.homeworkId,
      'homework_title': instance.homeworkTitle,
      'subject': instance.subject,
      'points': instance.points,
      'max_points': instance.maxPoints,
      'percentage': instance.percentage,
      'comment': instance.comment,
      'graded_at': instance.gradedAt?.toIso8601String(),
    };

ExamGradeModel _$ExamGradeModelFromJson(Map<String, dynamic> json) =>
    ExamGradeModel(
      id: (json['id'] as num?)?.toInt(),
      studentId: (json['student_id'] as num?)?.toInt(),
      examId: (json['exam_id'] as num?)?.toInt(),
      examTitle: json['exam_title'] as String?,
      subject: json['subject'] as String?,
      points: (json['points'] as num?)?.toInt(),
      maxPoints: (json['max_points'] as num).toInt(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      comment: json['comment'] as String,
      gradedAt: json['graded_at'] == null
          ? null
          : DateTime.parse(json['graded_at'] as String),
    );

Map<String, dynamic> _$ExamGradeModelToJson(ExamGradeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'exam_id': instance.examId,
      'exam_title': instance.examTitle,
      'subject': instance.subject,
      'points': instance.points,
      'max_points': instance.maxPoints,
      'percentage': instance.percentage,
      'comment': instance.comment,
      'graded_at': instance.gradedAt?.toIso8601String(),
    };

GradesResponseModel _$GradesResponseModelFromJson(Map<String, dynamic> json) =>
    GradesResponseModel(
      homeworkGrades: (json['homework_grades'] as List<dynamic>)
          .map((e) => HomeworkGradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      examGrades: (json['exam_grades'] as List<dynamic>)
          .map((e) => ExamGradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GradesResponseModelToJson(
  GradesResponseModel instance,
) => <String, dynamic>{
  'homework_grades': instance.homeworkGrades,
  'exam_grades': instance.examGrades,
};
