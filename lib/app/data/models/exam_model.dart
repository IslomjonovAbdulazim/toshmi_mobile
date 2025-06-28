// FIXED: Updated to match backend SQLAlchemy model exactly
class Exam {
  final int id;
  final int groupSubjectId;
  final String title;
  final String description;
  final DateTime examDate;
  final int maxPoints;
  final List<String> externalLinks;
  final List<int> documentIds; // Changed to match backend
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.groupSubjectId,
    required this.title,
    required this.description,
    required this.examDate,
    required this.maxPoints,
    required this.externalLinks,
    required this.documentIds,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      groupSubjectId: json['group_subject_id'],
      title: json['title'],
      description: json['description'] ?? '',
      examDate: DateTime.parse(json['exam_date']),
      maxPoints: json['max_points'] ?? 100,
      externalLinks: List<String>.from(json['external_links'] ?? []),
      documentIds: List<int>.from(json['document_ids'] ?? []), // Fixed to match backend
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_subject_id': groupSubjectId,
      'title': title,
      'description': description,
      'exam_date': examDate.toIso8601String(),
      'max_points': maxPoints,
      'external_links': externalLinks,
      'document_ids': documentIds, // Fixed to match backend
      'created_at': createdAt.toIso8601String(),
    };
  }

  Exam copyWith({
    int? id,
    int? groupSubjectId,
    String? title,
    String? description,
    DateTime? examDate,
    int? maxPoints,
    List<String>? externalLinks,
    List<int>? documentIds,
    DateTime? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      examDate: examDate ?? this.examDate,
      maxPoints: maxPoints ?? this.maxPoints,
      externalLinks: externalLinks ?? this.externalLinks,
      documentIds: documentIds ?? this.documentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}