// lib/app/data/models/group_model.dart
class Group {
  final int id;
  final String name;
  final String academicYear;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      academicYear: json['academic_year'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'academic_year': academicYear,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Group copyWith({
    int? id,
    String? name,
    String? academicYear,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// lib/app/data/models/subject_model.dart
class Subject {
  final int id;
  final String name;
  final String code;

  Subject({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  Subject copyWith({
    int? id,
    String? name,
    String? code,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }
}

// lib/app/data/models/group_subject_model.dart
class GroupSubject {
  final int id;
  final int groupId;
  final int subjectId;
  final int? teacherId;

  GroupSubject({
    required this.id,
    required this.groupId,
    required this.subjectId,
    this.teacherId,
  });

  factory GroupSubject.fromJson(Map<String, dynamic> json) {
    return GroupSubject(
      id: json['id'],
      groupId: json['group_id'],
      subjectId: json['subject_id'],
      teacherId: json['teacher_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
    };
  }

  GroupSubject copyWith({
    int? id,
    int? groupId,
    int? subjectId,
    int? teacherId,
  }) {
    return GroupSubject(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
    );
  }
}

// lib/app/data/models/monthly_payment_model.dart
class MonthlyPayment {
  final int id;
  final int studentId;
  final int month;
  final int year;
  final int paidAmount;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;

  MonthlyPayment({
    required this.id,
    required this.studentId,
    required this.month,
    required this.year,
    required this.paidAmount,
    required this.isCompleted,
    this.dueDate,
    required this.createdAt,
  });

  factory MonthlyPayment.fromJson(Map<String, dynamic> json) {
    return MonthlyPayment(
      id: json['id'],
      studentId: json['student_id'],
      month: json['month'],
      year: json['year'],
      paidAmount: json['paid_amount'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'month': month,
      'year': year,
      'paid_amount': paidAmount,
      'is_completed': isCompleted,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  MonthlyPayment copyWith({
    int? id,
    int? studentId,
    int? month,
    int? year,
    int? paidAmount,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return MonthlyPayment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      month: month ?? this.month,
      year: year ?? this.year,
      paidAmount: paidAmount ?? this.paidAmount,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}