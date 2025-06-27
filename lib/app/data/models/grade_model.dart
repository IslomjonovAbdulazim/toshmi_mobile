class HomeworkGrade {
  final int id;
  final int studentId;
  final int homeworkId;
  final int points;
  final String comment;
  final DateTime gradedAt;

  HomeworkGrade({
    required this.id,
    required this.studentId,
    required this.homeworkId,
    required this.points,
    required this.comment,
    required this.gradedAt,
  });

  factory HomeworkGrade.fromJson(Map<String, dynamic> json) {
    return HomeworkGrade(
      id: json['id'],
      studentId: json['student_id'],
      homeworkId: json['homework_id'],
      points: json['points'],
      comment: json['comment'] ?? '',
      gradedAt: DateTime.parse(json['graded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'homework_id': homeworkId,
      'points': points,
      'comment': comment,
      'graded_at': gradedAt.toIso8601String(),
    };
  }

  HomeworkGrade copyWith({
    int? id,
    int? studentId,
    int? homeworkId,
    int? points,
    String? comment,
    DateTime? gradedAt,
  }) {
    return HomeworkGrade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      homeworkId: homeworkId ?? this.homeworkId,
      points: points ?? this.points,
      comment: comment ?? this.comment,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }
}

class ExamGrade {
  final int id;
  final int studentId;
  final int examId;
  final int points;
  final String comment;
  final DateTime gradedAt;

  ExamGrade({
    required this.id,
    required this.studentId,
    required this.examId,
    required this.points,
    required this.comment,
    required this.gradedAt,
  });

  factory ExamGrade.fromJson(Map<String, dynamic> json) {
    return ExamGrade(
      id: json['id'],
      studentId: json['student_id'],
      examId: json['exam_id'],
      points: json['points'],
      comment: json['comment'] ?? '',
      gradedAt: DateTime.parse(json['graded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'exam_id': examId,
      'points': points,
      'comment': comment,
      'graded_at': gradedAt.toIso8601String(),
    };
  }

  ExamGrade copyWith({
    int? id,
    int? studentId,
    int? examId,
    int? points,
    String? comment,
    DateTime? gradedAt,
  }) {
    return ExamGrade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      examId: examId ?? this.examId,
      points: points ?? this.points,
      comment: comment ?? this.comment,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }
}