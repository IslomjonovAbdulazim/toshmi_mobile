import 'package:json_annotation/json_annotation.dart';
import 'grade_model.dart';

part 'exam_model.g.dart';

@JsonSerializable()
class ExamModel {
  final int id;
  @JsonKey(name: 'group_subject_id')
  final int? groupSubjectId;
  final String title;
  final String description;
  @JsonKey(name: 'exam_date')
  final DateTime examDate;
  @JsonKey(name: 'max_points')
  final int maxPoints;
  @JsonKey(name: 'external_links')
  final List<String> externalLinks;
  @JsonKey(name: 'document_ids')
  final List<int> documentIds;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  // From API responses with joined data
  final String? subject; // group_subject.subject.name
  final String? teacher; // group_subject.teacher.full_name
  final String? group; // group_subject.group.name (teacher endpoint)

  // Grade information (when available)
  final GradeModel? grade;

  const ExamModel({
    required this.id,
    this.groupSubjectId,
    required this.title,
    required this.description,
    required this.examDate,
    required this.maxPoints,
    required this.externalLinks,
    required this.documentIds,
    this.createdAt,
    this.subject,
    this.teacher,
    this.group,
    this.grade,
  });

  // Check if exam is past
  bool get isPast => DateTime.now().isAfter(examDate);

  // Check if exam is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    return today.isAtSameMomentAs(examDay);
  }

  // Check if exam is tomorrow
  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    return tomorrow.isAtSameMomentAs(examDay);
  }

  // Check if exam is upcoming (within next 7 days)
  bool get isUpcoming {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return examDate.isAfter(now) && examDate.isBefore(weekFromNow);
  }

  // Get days until exam
  int get daysUntilExam {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examDate.year, examDate.month, examDate.day);
    return examDay.difference(today).inDays;
  }

  // Get exam status text
  String get examStatusText {
    if (isPast) {
      final daysPast = -daysUntilExam;
      if (daysPast == 0) return 'Bugun bo\'ldi';
      if (daysPast == 1) return '1 kun oldin bo\'ldi';
      return '$daysPast kun oldin bo\'ldi';
    } else if (isToday) {
      return 'Bugun imtihon';
    } else if (isTomorrow) {
      return 'Erta imtihon';
    } else {
      final days = daysUntilExam;
      if (days == 1) return '1 kun qoldi';
      return '$days kun qoldi';
    }
  }

  // Get exam status color (as hex string)
  String get examStatusColor {
    if (isPast) return '#9E9E9E'; // Gray
    if (isToday) return '#F44336'; // Red
    if (isTomorrow) return '#FF9800'; // Orange
    if (daysUntilExam <= 3) return '#FFC107'; // Amber
    if (daysUntilExam <= 7) return '#FF9800'; // Orange
    return '#4CAF50'; // Green
  }

  // Get subject display name
  String get displaySubject => subject ?? 'Fan noma\'lum';

  // Get teacher display name
  String get displayTeacher => teacher ?? 'Ustoz noma\'lum';

  // Get group display name
  String get displayGroup => group ?? 'Guruh noma\'lum';

  // Check if has external links
  bool get hasExternalLinks => externalLinks.isNotEmpty;

  // Check if has documents
  bool get hasDocuments => documentIds.isNotEmpty;

  // Check if exam has grade
  bool get hasGrade => grade?.hasGrade ?? false;

  // Get grade status
  String get gradeStatus => grade?.gradeStatus ?? 'Baholanmagan';

  // Get priority level based on exam date and grade status
  int get priorityLevel {
    if (hasGrade) return 0; // Lowest priority if already graded
    if (isToday) return 5; // Highest priority if today
    if (isTomorrow) return 4; // High priority if tomorrow
    if (daysUntilExam <= 3) return 3; // Medium priority if soon
    if (daysUntilExam <= 7) return 2; // Low priority if within week
    if (isPast && !hasGrade) return 1; // Waiting for results
    return 0; // Lowest priority
  }

  // Get formatted exam date
  String get formattedExamDate {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = examDate.day;
    final month = months[examDate.month];
    final year = examDate.year;
    final hour = examDate.hour.toString().padLeft(2, '0');
    final minute = examDate.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  // Get formatted exam time
  String get formattedExamTime {
    final hour = examDate.hour.toString().padLeft(2, '0');
    final minute = examDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get exam preparation status
  String get preparationStatus {
    final days = daysUntilExam;
    if (isPast) return 'Tugallangan';
    if (isToday) return 'Imtihon kuni!';
    if (days <= 1) return 'So\'nggi tayyorgarlik';
    if (days <= 3) return 'Jadal tayyorgarlik';
    if (days <= 7) return 'Tayyorgarlik boshlash';
    return 'Erta tayyorgarlik';
  }

  // JSON serialization
  factory ExamModel.fromJson(Map<String, dynamic> json) => _$ExamModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamModelToJson(this);

  // Copy with method
  ExamModel copyWith({
    int? id,
    int? groupSubjectId,
    String? title,
    String? description,
    DateTime? examDate,
    int? maxPoints,
    List<String>? externalLinks,
    List<int>? documentIds,
    DateTime? createdAt,
    String? subject,
    String? teacher,
    String? group,
    GradeModel? grade,
  }) {
    return ExamModel(
      id: id ?? this.id,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      examDate: examDate ?? this.examDate,
      maxPoints: maxPoints ?? this.maxPoints,
      externalLinks: externalLinks ?? this.externalLinks,
      documentIds: documentIds ?? this.documentIds,
      createdAt: createdAt ?? this.createdAt,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      group: group ?? this.group,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExamModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExamModel(id: $id, title: $title, subject: $displaySubject, examDate: $formattedExamDate, hasGrade: $hasGrade)';
  }
}

// Exam request model for creating/updating exams
@JsonSerializable()
class ExamRequest {
  @JsonKey(name: 'group_subject_id')
  final int groupSubjectId;
  final String title;
  final String description;
  @JsonKey(name: 'exam_date')
  final DateTime examDate;
  @JsonKey(name: 'max_points')
  final int maxPoints;
  @JsonKey(name: 'external_links')
  final List<String> externalLinks;

  const ExamRequest({
    required this.groupSubjectId,
    required this.title,
    required this.description,
    required this.examDate,
    required this.maxPoints,
    required this.externalLinks,
  });

  // JSON serialization
  factory ExamRequest.fromJson(Map<String, dynamic> json) => _$ExamRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ExamRequestToJson(this);

  @override
  String toString() {
    return 'ExamRequest(title: $title, groupSubjectId: $groupSubjectId, examDate: $examDate)';
  }
}