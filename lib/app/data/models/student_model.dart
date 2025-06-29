// lib/app/data/models/student_model.dart
import 'group_model.dart';

class Student {
  final int id;
  final int userId;
  final int groupId;
  final String parentPhone;
  final int graduationYear;
  final List<PaymentRecord>? paymentRecords; // CRITICAL FIX: Backend has payment_records, not monthly_payments

  Student({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.parentPhone,
    required this.graduationYear,
    this.paymentRecords,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      parentPhone: json['parent_phone'],
      graduationYear: json['graduation_year'],
      paymentRecords: json['payment_records'] != null
          ? (json['payment_records'] as List)
          .map((p) => PaymentRecord.fromJson(p))
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
      'payment_records': paymentRecords?.map((p) => p.toJson()).toList(),
    };
  }

  Student copyWith({
    int? id,
    int? userId,
    int? groupId,
    String? parentPhone,
    int? graduationYear,
    List<PaymentRecord>? paymentRecords,
  }) {
    return Student(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      parentPhone: parentPhone ?? this.parentPhone,
      graduationYear: graduationYear ?? this.graduationYear,
      paymentRecords: paymentRecords ?? this.paymentRecords,
    );
  }
}