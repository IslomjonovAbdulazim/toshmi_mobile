// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentDashboardModel _$StudentDashboardModelFromJson(
  Map<String, dynamic> json,
) => StudentDashboardModel(
  upcomingHomework: (json['upcoming_homework'] as List<dynamic>)
      .map((e) => UpcomingHomeworkModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  upcomingExams: (json['upcoming_exams'] as List<dynamic>)
      .map((e) => UpcomingExamModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  recentGrades: (json['recent_grades'] as List<dynamic>)
      .map((e) => RecentGradeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StudentDashboardModelToJson(
  StudentDashboardModel instance,
) => <String, dynamic>{
  'upcoming_homework': instance.upcomingHomework,
  'upcoming_exams': instance.upcomingExams,
  'recent_grades': instance.recentGrades,
};

UpcomingHomeworkModel _$UpcomingHomeworkModelFromJson(
  Map<String, dynamic> json,
) => UpcomingHomeworkModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  dueDate: DateTime.parse(json['due_date'] as String),
  subject: json['subject'] as String,
);

Map<String, dynamic> _$UpcomingHomeworkModelToJson(
  UpcomingHomeworkModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'due_date': instance.dueDate.toIso8601String(),
  'subject': instance.subject,
};

UpcomingExamModel _$UpcomingExamModelFromJson(Map<String, dynamic> json) =>
    UpcomingExamModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      examDate: DateTime.parse(json['exam_date'] as String),
      subject: json['subject'] as String,
    );

Map<String, dynamic> _$UpcomingExamModelToJson(UpcomingExamModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'exam_date': instance.examDate.toIso8601String(),
      'subject': instance.subject,
    };

RecentGradeModel _$RecentGradeModelFromJson(Map<String, dynamic> json) =>
    RecentGradeModel(
      title: json['title'] as String,
      type: json['type'] as String,
      points: (json['points'] as num).toInt(),
      maxPoints: (json['max_points'] as num).toInt(),
      gradedAt: DateTime.parse(json['graded_at'] as String),
    );

Map<String, dynamic> _$RecentGradeModelToJson(RecentGradeModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'type': instance.type,
      'points': instance.points,
      'max_points': instance.maxPoints,
      'graded_at': instance.gradedAt.toIso8601String(),
    };

ParentDashboardModel _$ParentDashboardModelFromJson(
  Map<String, dynamic> json,
) => ParentDashboardModel(
  childrenSummary: (json['children_summary'] as List<dynamic>)
      .map((e) => ChildSummaryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ParentDashboardModelToJson(
  ParentDashboardModel instance,
) => <String, dynamic>{'children_summary': instance.childrenSummary};

ChildSummaryModel _$ChildSummaryModelFromJson(Map<String, dynamic> json) =>
    ChildSummaryModel(
      childId: (json['child_id'] as num).toInt(),
      childName: json['child_name'] as String,
      upcomingHomeworkCount: (json['upcoming_homework_count'] as num).toInt(),
      pendingPaymentsCount: (json['pending_payments_count'] as num).toInt(),
    );

Map<String, dynamic> _$ChildSummaryModelToJson(ChildSummaryModel instance) =>
    <String, dynamic>{
      'child_id': instance.childId,
      'child_name': instance.childName,
      'upcoming_homework_count': instance.upcomingHomeworkCount,
      'pending_payments_count': instance.pendingPaymentsCount,
    };
