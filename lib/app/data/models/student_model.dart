class Student {
  final int id;
  final int userId;
  final int groupId;
  final String parentPhone;
  final int graduationYear;

  Student({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.parentPhone,
    required this.graduationYear,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      parentPhone: json['parent_phone'],
      graduationYear: json['graduation_year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'parent_phone': parentPhone,
      'graduation_year': graduationYear,
    };
  }

  Student copyWith({
    int? id,
    int? userId,
    int? groupId,
    String? parentPhone,
    int? graduationYear,
  }) {
    return Student(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      parentPhone: parentPhone ?? this.parentPhone,
      graduationYear: graduationYear ?? this.graduationYear,
    );
  }
}