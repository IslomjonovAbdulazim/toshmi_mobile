import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel {
  final int? id;
  @JsonKey(name: 'student_id')
  final int? studentId;
  final int amount;
  @JsonKey(name: 'payment_date')
  final DateTime paymentDate;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String description;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const PaymentModel({
    this.id,
    this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.description,
    this.createdAt,
  });

  // Payment method constants
  static const String cash = 'cash';
  static const String card = 'card';
  static const String transfer = 'transfer';
  static const String online = 'online';

  // Check payment method
  bool get isCash => paymentMethod == cash;
  bool get isCard => paymentMethod == card;
  bool get isTransfer => paymentMethod == transfer;
  bool get isOnline => paymentMethod == online;

  // Get payment method in Uzbek
  String get paymentMethodUz {
    switch (paymentMethod) {
      case cash:
        return 'Naqd pul';
      case card:
        return 'Plastik karta';
      case transfer:
        return 'Bank o\'tkazmasi';
      case online:
        return 'Onlayn to\'lov';
      default:
        return paymentMethod;
    }
  }

  // Get payment method icon
  String get paymentMethodIcon {
    switch (paymentMethod) {
      case cash:
        return '💵';
      case card:
        return '💳';
      case transfer:
        return '🏦';
      case online:
        return '💻';
      default:
        return '💰';
    }
  }

  // Get formatted amount
  String get formattedAmount {
    // Format number with thousands separator
    final amountStr = amount.toString();
    final reversed = amountStr.split('').reversed.join();
    final chunks = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end < reversed.length ? end : reversed.length));
    }

    return chunks.join(' ').split('').reversed.join() + ' so\'m';
  }

  // Get formatted payment date
  String get formattedPaymentDate {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = paymentDate.day;
    final month = months[paymentDate.month];
    final year = paymentDate.year;

    return '$day $month $year';
  }

  // Get short formatted date
  String get shortFormattedDate {
    final day = paymentDate.day.toString().padLeft(2, '0');
    final month = paymentDate.month.toString().padLeft(2, '0');
    final year = paymentDate.year;

    return '$day.$month.$year';
  }

  // Get display description
  String get displayDescription => description.isEmpty ? 'To\'lov' : description;

  // Check if payment is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return paymentDate.year == now.year && paymentDate.month == now.month;
  }

  // Check if payment is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final paymentDay = DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
    return today.isAtSameMomentAs(paymentDay);
  }

  // Get month and year
  String get monthYear {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    return '${months[paymentDate.month]} ${paymentDate.year}';
  }

  // Get payment summary
  String get paymentSummary => '$formattedAmount - $paymentMethodUz';

  // JSON serialization
  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  // Copy with method
  PaymentModel copyWith({
    int? id,
    int? studentId,
    int? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? description,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $formattedAmount, date: $shortFormattedDate, method: $paymentMethodUz)';
  }
}

// Monthly payment status model (appears in API responses)
@JsonSerializable()
class MonthlyPaymentModel {
  final int month;
  final int year;
  @JsonKey(name: 'paid_amount')
  final int paidAmount;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'due_date')
  final DateTime? dueDate;

  const MonthlyPaymentModel({
    required this.month,
    required this.year,
    required this.paidAmount,
    required this.isCompleted,
    this.dueDate,
  });

  // Get month name in Uzbek
  String get monthNameUz {
    const monthNames = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return month >= 1 && month <= 12 ? monthNames[month] : 'Noma\'lum';
  }

  // Get display period
  String get displayPeriod => '$monthNameUz $year';

  // Get formatted amount
  String get formattedAmount {
    final amountStr = paidAmount.toString();
    final reversed = amountStr.split('').reversed.join();
    final chunks = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end < reversed.length ? end : reversed.length));
    }

    return chunks.join(' ').split('').reversed.join() + ' so\'m';
  }

  // Get status text
  String get statusText => isCompleted ? 'To\'langan' : 'To\'lanmagan';

  // Get status icon
  String get statusIcon => isCompleted ? '✅' : '❌';

  // Get status color
  String get statusColor => isCompleted ? '#4CAF50' : '#F44336';

  // Check if payment is overdue
  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Get formatted due date
  String get formattedDueDate {
    if (dueDate == null) return '';

    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = dueDate!.day;
    final month = months[dueDate!.month];
    final year = dueDate!.year;

    return '$day $month $year';
  }

  // JSON serialization
  factory MonthlyPaymentModel.fromJson(Map<String, dynamic> json) => _$MonthlyPaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyPaymentModelToJson(this);

  @override
  String toString() {
    return 'MonthlyPaymentModel(period: $displayPeriod, amount: $formattedAmount, completed: $isCompleted)';
  }
}

// Payments response model
@JsonSerializable()
class PaymentsResponseModel {
  @JsonKey(name: 'payment_records')
  final List<PaymentModel> paymentRecords;
  @JsonKey(name: 'monthly_status')
  final List<MonthlyPaymentModel> monthlyStatus;

  const PaymentsResponseModel({
    required this.paymentRecords,
    required this.monthlyStatus,
  });

  // Get total paid amount
  int get totalPaidAmount {
    return paymentRecords.fold(0, (sum, payment) => sum + payment.amount);
  }

  // Get formatted total
  String get formattedTotal {
    final amountStr = totalPaidAmount.toString();
    final reversed = amountStr.split('').reversed.join();
    final chunks = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final end = i + 3;
      chunks.add(reversed.substring(i, end < reversed.length ? end : reversed.length));
    }

    return chunks.join(' ').split('').reversed.join() + ' so\'m';
  }

  // Get pending payments count
  int get pendingPaymentsCount {
    return monthlyStatus.where((m) => !m.isCompleted).length;
  }

  // Get completed payments count
  int get completedPaymentsCount {
    return monthlyStatus.where((m) => m.isCompleted).length;
  }

  // Get overdue payments count
  int get overduePaymentsCount {
    return monthlyStatus.where((m) => m.isOverdue).length;
  }

  // Get recent payments (last 5)
  List<PaymentModel> get recentPayments {
    final sorted = List<PaymentModel>.from(paymentRecords);
    sorted.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    return sorted.take(5).toList();
  }

  // JSON serialization
  factory PaymentsResponseModel.fromJson(Map<String, dynamic> json) => _$PaymentsResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentsResponseModelToJson(this);

  @override
  String toString() {
    return 'PaymentsResponseModel(records: ${paymentRecords.length}, total: $formattedTotal, pending: $pendingPaymentsCount)';
  }
}

// Payment request model for admin endpoint
@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'student_id')
  final int studentId;
  final int amount;
  @JsonKey(name: 'payment_date')
  final DateTime paymentDate;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String description;

  const PaymentRequest({
    required this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.description,
  });

  // JSON serialization
  factory PaymentRequest.fromJson(Map<String, dynamic> json) => _$PaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);

  @override
  String toString() {
    return 'PaymentRequest(studentId: $studentId, amount: $amount, method: $paymentMethod)';
  }
}