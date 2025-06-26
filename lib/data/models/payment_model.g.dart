// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: (json['id'] as num?)?.toInt(),
  studentId: (json['student_id'] as num?)?.toInt(),
  amount: (json['amount'] as num).toInt(),
  paymentDate: DateTime.parse(json['payment_date'] as String),
  paymentMethod: json['payment_method'] as String,
  description: json['description'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'amount': instance.amount,
      'payment_date': instance.paymentDate.toIso8601String(),
      'payment_method': instance.paymentMethod,
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
    };

MonthlyPaymentModel _$MonthlyPaymentModelFromJson(Map<String, dynamic> json) =>
    MonthlyPaymentModel(
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      paidAmount: (json['paid_amount'] as num).toInt(),
      isCompleted: json['is_completed'] as bool,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
    );

Map<String, dynamic> _$MonthlyPaymentModelToJson(
  MonthlyPaymentModel instance,
) => <String, dynamic>{
  'month': instance.month,
  'year': instance.year,
  'paid_amount': instance.paidAmount,
  'is_completed': instance.isCompleted,
  'due_date': instance.dueDate?.toIso8601String(),
};

PaymentsResponseModel _$PaymentsResponseModelFromJson(
  Map<String, dynamic> json,
) => PaymentsResponseModel(
  paymentRecords: (json['payment_records'] as List<dynamic>)
      .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  monthlyStatus: (json['monthly_status'] as List<dynamic>)
      .map((e) => MonthlyPaymentModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PaymentsResponseModelToJson(
  PaymentsResponseModel instance,
) => <String, dynamic>{
  'payment_records': instance.paymentRecords,
  'monthly_status': instance.monthlyStatus,
};

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      studentId: (json['student_id'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentMethod: json['payment_method'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'student_id': instance.studentId,
      'amount': instance.amount,
      'payment_date': instance.paymentDate.toIso8601String(),
      'payment_method': instance.paymentMethod,
      'description': instance.description,
    };
