// FIXED: Updated to match backend SQLAlchemy model exactly
class Homework {
  final int id;
  final int groupSubjectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int maxPoints;
  final List<String> externalLinks;
  final List<int> documentIds; // Changed to match backend
  final DateTime createdAt;

  Homework({
    required this.id,
    required this.groupSubjectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxPoints,
    required this.externalLinks,
    required this.documentIds,
    required this.createdAt,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'],
      groupSubjectId: json['group_subject_id'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['due_date']),
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
      'due_date': dueDate.toIso8601String(),
      'max_points': maxPoints,
      'external_links': externalLinks,
      'document_ids': documentIds, // Fixed to match backend
      'created_at': createdAt.toIso8601String(),
    };
  }

  Homework copyWith({
    int? id,
    int? groupSubjectId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxPoints,
    List<String>? externalLinks,
    List<int>? documentIds,
    DateTime? createdAt,
  }) {
    return Homework(
      id: id ?? this.id,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      maxPoints: maxPoints ?? this.maxPoints,
      externalLinks: externalLinks ?? this.externalLinks,
      documentIds: documentIds ?? this.documentIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}