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

  // Get payment by ID
  Future<PaymentRecord> getPaymentById(int paymentId) async {
    try {
      final response = await get('${ApiConstants.adminPayments}/$paymentId');
      return PaymentRecord.fromJson(response.body as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load payment: $e');
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