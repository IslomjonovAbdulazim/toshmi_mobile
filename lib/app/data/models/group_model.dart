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

// lib/app/data/models/payment_record_model.dart
// CRITICAL FIX: Backend has PaymentRecord, not MonthlyPayment
class PaymentRecord {
  final int id;
  final int studentId;
  final int amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String description;
  final DateTime createdAt;

  PaymentRecord({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.description,
    required this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'],
      studentId: json['student_id'],
      amount: json['amount'],
      paymentDate: DateTime.parse(json['payment_date']),
      paymentMethod: json['payment_method'] ?? 'cash',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PaymentRecord copyWith({
    int? id,
    int? studentId,
    int? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? description,
    DateTime? createdAt,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}