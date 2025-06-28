import '../../../core/base/base_repository.dart';
import '../models/payment_model.dart';
import '../../utils/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

class PaymentRepository extends BaseRepository {
  final AuthService _authService = Get.find<AuthService>();

  // Get payments (role-based)
  Future<Map<String, dynamic>> getPayments() async {
    try {
      String endpoint;
      switch (_authService.userRole?.toLowerCase()) {
        case 'admin':
          endpoint = ApiConstants.adminPayments;
          break;
        case 'student':
          endpoint = ApiConstants.studentPayments;
          break;
        default:
          throw Exception('Invalid role for payment access');
      }

      final response = await get(endpoint);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  // Record payment (admin only)
  Future<PaymentRecord> recordPayment({
    required int studentId,
    required int amount,
    required DateTime paymentDate,
    String paymentMethod = 'cash',
    String description = '',
  }) async {
    try {
      final response = await post(ApiConstants.adminPayments, {
        'student_id': studentId,
        'amount': amount,
        'payment_date': paymentDate.toIso8601String().split('T')[0],
        'payment_method': paymentMethod,
        'description': description,
      });

      final data = response.body as Map<String, dynamic>;
      final paymentId = data['id'] as int;

      return await getPaymentById(paymentId);
    } catch (e) {
      throw Exception('Failed to record payment: $e');
    }
  }

  // Get payment by ID
  Future<PaymentRecord> getPaymentById(int paymentId) async {
    try {
      final response = await get('${ApiConstants.adminPayments}/$paymentId');
      return PaymentRecord.fromJson(response.body as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load payment: $e');
    }
  }

  // Update payment (admin only)
  Future<void> updatePayment({
    required int paymentId,
    required int studentId,
    required int amount,
    required DateTime paymentDate,
    String paymentMethod = 'cash',
    String description = '',
  }) async {
    try {
      await put('${ApiConstants.adminPayments}/$paymentId', {
        'student_id': studentId,
        'amount': amount,
        'payment_date': paymentDate.toIso8601String().split('T')[0],
        'payment_method': paymentMethod,
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  // Delete payment (admin only)
  Future<void> deletePayment(int paymentId) async {
    try {
      await delete('${ApiConstants.adminPayments}/$paymentId');
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }

  // Update monthly payment status (admin only) - NEW
  Future<void> updateMonthlyPaymentStatus({
    required int studentId,
    required int month,
    required int year,
    required bool isCompleted,
    required int paidAmount,
    DateTime? dueDate,
  }) async {
    try {
      await put(ApiConstants.adminMonthlyPaymentStatus, {
        'student_id': studentId,
        'month': month,
        'year': year,
        'is_completed': isCompleted,
        'paid_amount': paidAmount,
        'due_date': dueDate?.toIso8601String().split('T')[0],
      });
    } catch (e) {
      throw Exception('Failed to update monthly payment status: $e');
    }
  }

  // Get all payments with filters (admin only)
  Future<List<dynamic>> getAllPayments({
    int skip = 0,
    int limit = 100,
    int? studentId,
    String? paymentMethod,
  }) async {
    try {
      final query = buildQuery({
        'skip': skip,
        'limit': limit,
        'student_id': studentId,
        'payment_method': paymentMethod,
      });

      final response = await get(ApiConstants.adminPayments, query: query);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load all payments: $e');
    }
  }

  // Get payment summary (admin only)
  Future<Map<String, dynamic>> getPaymentSummary() async {
    try {
      final response = await get('${ApiConstants.adminPayments}/summary');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load payment summary: $e');
    }
  }

  // Get child payments (parent)
  Future<Map<String, dynamic>> getChildPayments(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildren}/$childId/payments');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load child payments: $e');
    }
  }

  // Get payments by student (admin)
  Future<List<dynamic>> getPaymentsByStudent(int studentId) async {
    try {
      return await getAllPayments(studentId: studentId);
    } catch (e) {
      throw Exception('Failed to load payments by student: $e');
    }
  }

  // Get payments by method (admin)
  Future<List<dynamic>> getPaymentsByMethod(String paymentMethod) async {
    try {
      return await getAllPayments(paymentMethod: paymentMethod);
    } catch (e) {
      throw Exception('Failed to load payments by method: $e');
    }
  }

  // Get payments by date range (admin)
  Future<List<dynamic>> getPaymentsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final payments = await getAllPayments();

      return payments.where((p) {
        final paymentDate = DateTime.parse(p['payment_date']);
        if (startDate != null && paymentDate.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && paymentDate.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load payments by date range: $e');
    }
  }

  // Calculate payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics() async {
    try {
      final paymentsData = await getPayments();
      final paymentRecords = paymentsData['payment_records'] as List<dynamic>;

      if (paymentRecords.isEmpty) {
        return {
          'total_amount': 0,
          'total_payments': 0,
          'average_payment': 0,
          'payment_methods': <String, int>{},
        };
      }

      final totalAmount = paymentRecords.fold<int>(0, (sum, p) => sum + (p['amount'] as int));
      final averagePayment = totalAmount / paymentRecords.length;

      final methodCounts = <String, int>{};
      for (final payment in paymentRecords) {
        final method = payment['payment_method'] as String;
        methodCounts[method] = (methodCounts[method] ?? 0) + 1;
      }

      return {
        'total_amount': totalAmount,
        'total_payments': paymentRecords.length,
        'average_payment': averagePayment.round(),
        'payment_methods': methodCounts,
      };
    } catch (e) {
      throw Exception('Failed to calculate payment statistics: $e');
    }
  }

  @override
  void clearCache() {
    // Clear cached payment data
  }
}