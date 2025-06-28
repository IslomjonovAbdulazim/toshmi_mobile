// lib/app/data/models/student_model.dart
import 'group_model.dart';

class Student {
  final int id;
  final int userId;
  final int groupId;
  final String parentPhone;
  final int graduationYear;
  final List<MonthlyPayment>? monthlyPayments; // Added this

  Student({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.parentPhone,
    required this.graduationYear,
    this.monthlyPayments,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      parentPhone: json['parent_phone'],
      graduationYear: json['graduation_year'],
      monthlyPayments: json['monthly_payments'] != null
          ? (json['monthly_payments'] as List)
          .map((m) => MonthlyPayment.fromJson(m))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'parent_phone': parentPhone,
      'graduation_year': graduationYear,
      'monthly_payments': monthlyPayments?.map((m) => m.toJson()).toList(),
    };
  }

  Student copyWith({
    int? id,
    int? userId,
    int? groupId,
    String? parentPhone,
    int? graduationYear,
    List<MonthlyPayment>? monthlyPayments,
  }) {
    return Student(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      parentPhone: parentPhone ?? this.parentPhone,
      graduationYear: graduationYear ?? this.graduationYear,
      monthlyPayments: monthlyPayments ?? this.monthlyPayments,
    );
  }
}