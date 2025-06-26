import 'package:json_annotation/json_annotation.dart';
import 'grade_model.dart';

part 'homework_model.g.dart';

@JsonSerializable()
class HomeworkModel {
  final int id;
  @JsonKey(name: 'group_subject_id')
  final int? groupSubjectId;
  final String title;
  final String description;
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
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

  const HomeworkModel({
    required this.id,
    this.groupSubjectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxPoints,
    required this.externalLinks,
    required this.documentIds,
    this.createdAt,
    this.subject,
    this.teacher,
    this.group,
    this.grade,
  });

  // Check if homework is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  // Check if homework is due today
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final homeworkDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return today.isAtSameMomentAs(homeworkDay);
  }

  // Check if homework is due tomorrow
  bool get isDueTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final homeworkDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return tomorrow.isAtSameMomentAs(homeworkDay);
  }

  // Get days until due
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final homeworkDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return homeworkDay.difference(today).inDays;
  }

  // Get due status text
  String get dueStatusText {
    if (isOverdue) {
      final daysPast = -daysUntilDue;
      if (daysPast == 1) return '1 kun kech';
      return '$daysPast kun kech';
    } else if (isDueToday) {
      return 'Bugun topshirish';
    } else if (isDueTomorrow) {
      return 'Erta topshirish';
    } else {
      final days = daysUntilDue;
      if (days == 1) return '1 kun qoldi';
      return '$days kun qoldi';
    }
  }

  // Get due status color (as hex string)
  String get dueStatusColor {
    if (isOverdue) return '#F44336'; // Red
    if (isDueToday) return '#FF9800'; // Orange
    if (isDueTomorrow) return '#FFC107'; // Amber
    if (daysUntilDue <= 3) return '#FF9800'; // Orange
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

  // Check if homework has grade
  bool get hasGrade => grade?.hasGrade ?? false;

  // Get grade status
  String get gradeStatus => grade?.gradeStatus ?? 'Baholanmagan';

  // Get priority level based on due date and grade status
  int get priorityLevel {
    if (hasGrade) return 0; // Lowest priority if already graded
    if (isOverdue) return 4; // Highest priority if overdue
    if (isDueToday) return 3; // High priority if due today
    if (isDueTomorrow) return 2; // Medium priority if due tomorrow
    if (daysUntilDue <= 3) return 1; // Low priority if due soon
    return 0; // Lowest priority
  }

  // Get formatted due date
  String get formattedDueDate {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = dueDate.day;
    final month = months[dueDate.month];
    final year = dueDate.year;
    final hour = dueDate.hour.toString().padLeft(2, '0');
    final minute = dueDate.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  // JSON serialization
  factory HomeworkModel.fromJson(Map<String, dynamic> json) => _$HomeworkModelFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkModelToJson(this);

  // Copy with method
  HomeworkModel copyWith({
    int? id,
    int? groupSubjectId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxPoints,
    List<String>? externalLinks,
    List<int>? documentIds,
    DateTime? createdAt,
    String? subject,
    String? teacher,
    String? group,
    GradeModel? grade,
  }) {
    return HomeworkModel(
      id: id ?? this.id,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
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
    return other is HomeworkModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HomeworkModel(id: $id, title: $title, subject: $displaySubject, dueDate: $formattedDueDate, hasGrade: $hasGrade)';
  }
}

// Homework request model for creating/updating homework
@JsonSerializable()
class HomeworkRequest {
  @JsonKey(name: 'group_subject_id')
  final int groupSubjectId;
  final String title;
  final String description;
  @JsonKey(name: 'due_date')
  final DateTime dueDate;
  @JsonKey(name: 'max_points')
  final int maxPoints;
  @JsonKey(name: 'external_links')
  final List<String> externalLinks;

  const HomeworkRequest({
    required this.groupSubjectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxPoints,
    required this.externalLinks,
  });

  // JSON serialization
  factory HomeworkRequest.fromJson(Map<String, dynamic> json) => _$HomeworkRequestFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkRequestToJson(this);

  @override
  String toString() {
    return 'HomeworkRequest(title: $title, groupSubjectId: $groupSubjectId, dueDate: $dueDate)';
  }
}