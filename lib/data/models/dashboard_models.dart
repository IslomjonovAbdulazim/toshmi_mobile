import 'package:json_annotation/json_annotation.dart';

part 'dashboard_models.g.dart';

// Student dashboard model
@JsonSerializable()
class StudentDashboardModel {
  @JsonKey(name: 'upcoming_homework')
  final List<UpcomingHomeworkModel> upcomingHomework;
  @JsonKey(name: 'upcoming_exams')
  final List<UpcomingExamModel> upcomingExams;
  @JsonKey(name: 'recent_grades')
  final List<RecentGradeModel> recentGrades;

  const StudentDashboardModel({
    required this.upcomingHomework,
    required this.upcomingExams,
    required this.recentGrades,
  });

  // Get total upcoming items count
  int get totalUpcomingCount => upcomingHomework.length + upcomingExams.length;

  // Get urgent items count (due within 24 hours)
  int get urgentItemsCount {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    int urgentCount = 0;

    for (final homework in upcomingHomework) {
      if (homework.dueDate.isBefore(tomorrow)) urgentCount++;
    }

    for (final exam in upcomingExams) {
      if (exam.examDate.isBefore(tomorrow)) urgentCount++;
    }

    return urgentCount;
  }

  // Get average grade percentage
  double get averageGrade {
    if (recentGrades.isEmpty) return 0.0;

    double total = 0.0;
    for (final grade in recentGrades) {
      final percentage = (grade.points / grade.maxPoints) * 100;
      total += percentage;
    }

    return total / recentGrades.length;
  }

  // Get performance status
  String get performanceStatus {
    final avg = averageGrade;
    if (avg >= 90) return 'A\'lo';
    if (avg >= 70) return 'Yaxshi';
    if (avg >= 50) return 'Qoniqarli';
    return 'Yaxshilanishi kerak';
  }

  // JSON serialization
  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) => _$StudentDashboardModelFromJson(json);
  Map<String, dynamic> toJson() => _$StudentDashboardModelToJson(this);

  @override
  String toString() {
    return 'StudentDashboardModel(homework: ${upcomingHomework.length}, exams: ${upcomingExams.length}, grades: ${recentGrades.length})';
  }
}

// Upcoming homework model for dashboard
@JsonSerializable()
class UpcomingHomeworkModel {
  final int id;
  final String title;
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  final String subject;

  const UpcomingHomeworkModel({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.subject,
  });

  // Get days until due
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final homeworkDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return homeworkDay.difference(today).inDays;
  }

  // Get urgency level
  String get urgencyLevel {
    final days = daysUntilDue;
    if (days < 0) return 'Kech';
    if (days == 0) return 'Bugun';
    if (days == 1) return 'Erta';
    if (days <= 3) return 'Yaqin';
    return 'Uzoq';
  }

  // Get formatted due date
  String get formattedDueDate {
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');
    final hour = dueDate.hour.toString().padLeft(2, '0');
    final minute = dueDate.minute.toString().padLeft(2, '0');

    return '$day.$month $hour:$minute';
  }

  // JSON serialization
  factory UpcomingHomeworkModel.fromJson(Map<String, dynamic> json) => _$UpcomingHomeworkModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpcomingHomeworkModelToJson(this);

  @override
  String toString() {
    return 'UpcomingHomeworkModel(id: $id, title: $title, subject: $subject, urgency: $urgencyLevel)';
  }
}

// Upcoming exam model for dashboard
@JsonSerializable()
class UpcomingExamModel {
  final int id;
  final String title;
  @JsonKey(name: 'exam_date')
  final DateTime examDate;
  final String subject;

  const UpcomingExamModel({
    required this.id,
    required this.title,
    required this.examDate,
    required this.subject,
  });

  // Get days until exam
  int get daysUntilExam {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    return examDay.difference(today).inDays;
  }

  // Get urgency level
  String get urgencyLevel {
    final days = daysUntilExam;
    if (days < 0) return 'O\'tgan';
    if (days == 0) return 'Bugun';
    if (days == 1) return 'Erta';
    if (days <= 3) return 'Yaqin';
    if (days <= 7) return 'Hafta ichida';
    return 'Uzoq';
  }

  // Get formatted exam date
  String get formattedExamDate {
    final day = examDate.day.toString().padLeft(2, '0');
    final month = examDate.month.toString().padLeft(2, '0');
    final hour = examDate.hour.toString().padLeft(2, '0');
    final minute = examDate.minute.toString().padLeft(2, '0');

    return '$day.$month $hour:$minute';
  }

  // JSON serialization
  factory UpcomingExamModel.fromJson(Map<String, dynamic> json) => _$UpcomingExamModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpcomingExamModelToJson(this);

  @override
  String toString() {
    return 'UpcomingExamModel(id: $id, title: $title, subject: $subject, urgency: $urgencyLevel)';
  }
}

// Recent grade model for dashboard
@JsonSerializable()
class RecentGradeModel {
  final String title;
  final String type; // "homework" or "exam"
  final int points;
  @JsonKey(name: 'max_points')
  final int maxPoints;
  @JsonKey(name: 'graded_at')
  final DateTime gradedAt;

  const RecentGradeModel({
    required this.title,
    required this.type,
    required this.points,
    required this.maxPoints,
    required this.gradedAt,
  });

  // Get percentage
  double get percentage => (points / maxPoints) * 100;

  // Get grade status
  String get gradeStatus {
    final percent = percentage;
    if (percent >= 90) return 'A\'lo';
    if (percent >= 70) return 'Yaxshi';
    if (percent >= 50) return 'Qoniqarli';
    return 'Qoniqarsiz';
  }

  // Get type in Uzbek
  String get typeUz => type == 'homework' ? 'Vazifa' : 'Imtihon';

  // Get formatted percentage
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

  // Get display text
  String get displayText => '$points/$maxPoints ($formattedPercentage)';

  // JSON serialization
  factory RecentGradeModel.fromJson(Map<String, dynamic> json) => _$RecentGradeModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecentGradeModelToJson(this);

  @override
  String toString() {
    return 'RecentGradeModel(title: $title, type: $typeUz, grade: $displayText, status: $gradeStatus)';
  }
}

// Parent dashboard model
@JsonSerializable()
class ParentDashboardModel {
  @JsonKey(name: 'children_summary')
  final List<ChildSummaryModel> childrenSummary;

  const ParentDashboardModel({
    required this.childrenSummary,
  });

  // Get total children count
  int get totalChildren => childrenSummary.length;

  // Get total upcoming homework across all children
  int get totalUpcomingHomework {
    return childrenSummary.fold(0, (sum, child) => sum + child.upcomingHomeworkCount);
  }

  // Get total pending payments across all children
  int get totalPendingPayments {
    return childrenSummary.fold(0, (sum, child) => sum + child.pendingPaymentsCount);
  }

  // Check if any child has urgent items
  bool get hasUrgentItems {
    return childrenSummary.any((child) =>
    child.upcomingHomeworkCount > 0 || child.pendingPaymentsCount > 0);
  }

  // JSON serialization
  factory ParentDashboardModel.fromJson(Map<String, dynamic> json) => _$ParentDashboardModelFromJson(json);
  Map<String, dynamic> toJson() => _$ParentDashboardModelToJson(this);

  @override
  String toString() {
    return 'ParentDashboardModel(children: $totalChildren, homework: $totalUpcomingHomework, payments: $totalPendingPayments)';
  }
}

// Child summary model for parent dashboard
@JsonSerializable()
class ChildSummaryModel {
  @JsonKey(name: 'child_id')
  final int childId;
  @JsonKey(name: 'child_name')
  final String childName;
  @JsonKey(name: 'upcoming_homework_count')
  final int upcomingHomeworkCount;
  @JsonKey(name: 'pending_payments_count')
  final int pendingPaymentsCount;

  const ChildSummaryModel({
    required this.childId,
    required this.childName,
    required this.upcomingHomeworkCount,
    required this.pendingPaymentsCount,
  });

  // Check if child needs attention
  bool get needsAttention => upcomingHomeworkCount > 0 || pendingPaymentsCount > 0;

  // Get attention level
  String get attentionLevel {
    if (pendingPaymentsCount > 0 && upcomingHomeworkCount > 3) return 'Yuqori';
    if (pendingPaymentsCount > 0 || upcomingHomeworkCount > 5) return 'O\'rta';
    if (upcomingHomeworkCount > 0) return 'Past';
    return 'Yaxshi';
  }

  // Get status summary
  String get statusSummary {
    if (!needsAttention) return 'Hammasi yaxshi';

    List<String> issues = [];
    if (upcomingHomeworkCount > 0) {
      issues.add('$upcomingHomeworkCount vazifa');
    }
    if (pendingPaymentsCount > 0) {
      issues.add('$pendingPaymentsCount to\'lov');
    }

    return issues.join(', ');
  }

  // JSON serialization
  factory ChildSummaryModel.fromJson(Map<String, dynamic> json) => _$ChildSummaryModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChildSummaryModelToJson(this);

  @override
  String toString() {
    return 'ChildSummaryModel(id: $childId, name: $childName, attention: $attentionLevel, status: $statusSummary)';
  }
}