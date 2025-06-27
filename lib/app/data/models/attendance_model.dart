class Attendance {
  final int id;
  final int studentId;
  final int groupSubjectId;
  final DateTime date;
  final String status;

  Attendance({
    required this.id,
    required this.studentId,
    required this.groupSubjectId,
    required this.date,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['student_id'],
      groupSubjectId: json['group_subject_id'],
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'group_subject_id': groupSubjectId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'status': status,
    };
  }

  Attendance copyWith({
    int? id,
    int? studentId,
    int? groupSubjectId,
    DateTime? date,
    String? status,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}