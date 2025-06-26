import 'package:json_annotation/json_annotation.dart';

part 'grade_model.g.dart';

// Simple grade model for inline grade data
@JsonSerializable()
class GradeModel {
  final int? points;
  final String comment;
  @JsonKey(name: 'max_points')
  final int? maxPoints;
  @JsonKey(name: 'graded_at')
  final DateTime? gradedAt;

  const GradeModel({
    this.points,
    required this.comment,
    this.maxPoints,
    this.gradedAt,
  });

  // Check if grade exists
  bool get hasGrade => points != null;

  // Calculate percentage
  double get percentage {
    if (points == null || maxPoints == null || maxPoints == 0) return 0.0;
    return (points! / maxPoints!) * 100;
  }

  // Get percentage as string
  String get percentageText => '${percentage.toStringAsFixed(1)}%';

  // Get grade status
  String get gradeStatus {
    if (!hasGrade) return 'Baholanmagan';

    final percent = percentage;
    if (percent >= 90) return 'A\'lo';
    if (percent >= 70) return 'Yaxshi';
    if (percent >= 50) return 'Qoniqarli';
    return 'Qoniqarsiz';
  }

  // Get grade emoji
  String get gradeEmoji {
    if (!hasGrade) return '⏳';

    final percent = percentage;
    if (percent >= 90) return '🌟';
    if (percent >= 70) return '👍';
    if (percent >= 50) return '👌';
    return '👎';
  }

  // Get display text
  String get displayText {
    if (!hasGrade) return 'Baholanmagan';
    if (maxPoints != null) {
      return '$points/$maxPoints ($percentageText)';
    }
    return '$points ball';
  }

  // JSON serialization
  factory GradeModel.fromJson(Map<String, dynamic> json) => _$GradeModelFromJson(json);
  Map<String, dynamic> toJson() => _$GradeModelToJson(this);

  @override
  String toString() {
    return 'GradeModel(points: $points, maxPoints: $maxPoints, percentage: ${percentage.toStringAsFixed(1)}%)';
  }
}

// Homework grade model for detailed responses
@JsonSerializable()
class HomeworkGradeModel {
  final int? id;
  @JsonKey(name: 'student_id')
  final int? studentId;
  @JsonKey(name: 'homework_id')
  final int? homeworkId;
  @JsonKey(name: 'homework_title')
  final String? homeworkTitle;
  final String? subject;
  final int? points;
  @JsonKey(name: 'max_points')
  final int maxPoints;
  final double? percentage;
  final String comment;
  @JsonKey(name: 'graded_at')
  final DateTime? gradedAt;

  const HomeworkGradeModel({
    this.id,
    this.studentId,
    this.homeworkId,
    this.homeworkTitle,
    this.subject,
    this.points,
    required this.maxPoints,
    this.percentage,
    required this.comment,
    this.gradedAt,
  });

  // Check if graded
  bool get isGraded => points != null;

  // Calculate percentage if not provided
  double get calculatedPercentage {
    if (percentage != null) return percentage!;
    if (points == null || maxPoints == 0) return 0.0;
    return (points! / maxPoints) * 100;
  }

  // Get grade status
  String get gradeStatus {
    if (!isGraded) return 'Baholanmagan';

    final percent = calculatedPercentage;
    if (percent >= 90) return 'A\'lo';
    if (percent >= 70) return 'Yaxshi';
    if (percent >= 50) return 'Qoniqarli';
    return 'Qoniqarsiz';
  }

  // Get display title
  String get displayTitle => homeworkTitle ?? 'Vazifa #$homeworkId';

  // Get display subject
  String get displaySubject => subject ?? 'Fan noma\'lum';

  // Get display text
  String get displayText {
    if (!isGraded) return 'Baholanmagan';
    return '$points/$maxPoints (${calculatedPercentage.toStringAsFixed(1)}%)';
  }

  // JSON serialization
  factory HomeworkGradeModel.fromJson(Map<String, dynamic> json) => _$HomeworkGradeModelFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkGradeModelToJson(this);

  @override
  String toString() {
    return 'HomeworkGradeModel(title: $displayTitle, subject: $displaySubject, grade: $displayText)';
  }
}

// Exam grade model for detailed responses
@JsonSerializable()
class ExamGradeModel {
  final int? id;
  @JsonKey(name: 'student_id')
  final int? studentId;
  @JsonKey(name: 'exam_id')
  final int? examId;
  @JsonKey(name: 'exam_title')
  final String? examTitle;
  final String? subject;
  final int? points;
  @JsonKey(name: 'max_points')
  final int maxPoints;
  final double? percentage;
  final String comment;
  @JsonKey(name: 'graded_at')
  final DateTime? gradedAt;

  const ExamGradeModel({
    this.id,
    this.studentId,
    this.examId,
    this.examTitle,
    this.subject,
    this.points,
    required this.maxPoints,
    this.percentage,
    required this.comment,
    this.gradedAt,
  });

  // Check if graded
  bool get isGraded => points != null;

  // Calculate percentage if not provided
  double get calculatedPercentage {
    if (percentage != null) return percentage!;
    if (points == null || maxPoints == 0) return 0.0;
    return (points! / maxPoints) * 100;
  }

  // Get grade status
  String get gradeStatus {
    if (!isGraded) return 'Baholanmagan';

    final percent = calculatedPercentage;
    if (percent >= 90) return 'A\'lo';
    if (percent >= 70) return 'Yaxshi';
    if (percent >= 50) return 'Qoniqarli';
    return 'Qoniqarsiz';
  }

  // Get display title
  String get displayTitle => examTitle ?? 'Imtihon #$examId';

  // Get display subject
  String get displaySubject => subject ?? 'Fan noma\'lum';

  // Get display text
  String get displayText {
    if (!isGraded) return 'Baholanmagan';
    return '$points/$maxPoints (${calculatedPercentage.toStringAsFixed(1)}%)';
  }

  // JSON serialization
  factory ExamGradeModel.fromJson(Map<String, dynamic> json) => _$ExamGradeModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamGradeModelToJson(this);

  @override
  String toString() {
    return 'ExamGradeModel(title: $displayTitle, subject: $displaySubject, grade: $displayText)';
  }
}

// Combined grades response model
@JsonSerializable()
class GradesResponseModel {
  @JsonKey(name: 'homework_grades')
  final List<HomeworkGradeModel> homeworkGrades;
  @JsonKey(name: 'exam_grades')
  final List<ExamGradeModel> examGrades;

  const GradesResponseModel({
    required this.homeworkGrades,
    required this.examGrades,
  });

  // Get all grades count
  int get totalGradesCount => homeworkGrades.length + examGrades.length;

  // Get graded count
  int get gradedCount {
    int count = 0;
    count += homeworkGrades.where((g) => g.isGraded).length;
    count += examGrades.where((g) => g.isGraded).length;
    return count;
  }

  // Get pending count
  int get pendingCount => totalGradesCount - gradedCount;

  // Calculate average grade
  double get averageGrade {
    if (gradedCount == 0) return 0.0;

    double total = 0.0;
    int count = 0;

    for (final grade in homeworkGrades) {
      if (grade.isGraded) {
        total += grade.calculatedPercentage;
        count++;
      }
    }

    for (final grade in examGrades) {
      if (grade.isGraded) {
        total += grade.calculatedPercentage;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }

  // Get average grade status
  String get averageGradeStatus {
    final avg = averageGrade;
    if (avg >= 90) return 'A\'lo';
    if (avg >= 70) return 'Yaxshi';
    if (avg >= 50) return 'Qoniqarli';
    return 'Qoniqarsiz';
  }

  // JSON serialization
  factory GradesResponseModel.fromJson(Map<String, dynamic> json) => _$GradesResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$GradesResponseModelToJson(this);

  @override
  String toString() {
    return 'GradesResponseModel(homework: ${homeworkGrades.length}, exams: ${examGrades.length}, average: ${averageGrade.toStringAsFixed(1)}%)';
  }
}