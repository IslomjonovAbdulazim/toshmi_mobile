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
      'payment_date': paymentDate.toIso8601String().split('T')[0], // Date only
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