import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class StudentPaymentsView extends StatefulWidget {
  const StudentPaymentsView({super.key});

  @override
  State<StudentPaymentsView> createState() => _StudentPaymentsViewState();
}

class _StudentPaymentsViewState extends State<StudentPaymentsView> {
  final StudentRepository repository = StudentRepository();
  final isLoading = false.obs;
  final payments = <String, dynamic>{}.obs;
  final summary = <String, dynamic>{}.obs;

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      isLoading.value = true;
      final paymentsData = await repository.getPayments();
      final summaryData = await repository.getPaymentSummary();

      payments.value = paymentsData;
      summary.value = summaryData;
    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'payments'.tr,
        showBackButton: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: loadPayments,
          child: Column(
            children: [
              _buildSummaryCards(),
              Expanded(child: _buildPaymentsList()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards() {
    if (summary.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'total_paid'.tr,
                  _formatAmount(summary['total_paid'] ?? 0),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'payment_count'.tr,
                  '${summary['payment_count'] ?? 0}',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'average_payment'.tr,
                  _formatAmount(summary['average_payment'] ?? 0),
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  'last_payment'.tr,
                  _getLastPaymentDate(),
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    final paymentRecords = payments['payment_records'] as List? ?? [];

    if (paymentRecords.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paymentRecords.length,
      itemBuilder: (context, index) => _buildPaymentCard(paymentRecords[index]),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final amount = payment['amount'] as int;
    final paymentDate = DateTime.parse(payment['payment_date']);
    final method = payment['payment_method'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatAmount(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMethodColor(method).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getMethodText(method),
                    style: TextStyle(
                      color: _getMethodColor(method),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (payment['description'] != null && payment['description'].isNotEmpty)
              Text(
                payment['description'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(paymentDate),
                  style: TextStyle(color: Colors.grey[550], fontSize: 12),
                ),
                const Spacer(),
                Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _getMethodText(method),
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'payment_history_empty'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      // 1 million or more
      final millions = amount / 1000000;
      if (millions == millions.toInt()) {
        return '${millions.toInt()} million ${'som'.tr}';
      } else {
        return '${millions.toStringAsFixed(1)} million ${'som'.tr}';
      }
    } else if (amount >= 1000) {
      // 1 thousand to 999,999
      final thousands = amount / 1000;
      if (thousands == thousands.toInt()) {
        return '${thousands.toInt()} ming ${'som'.tr}';
      } else {
        return '${thousands.toStringAsFixed(1)} ming ${'som'.tr}';
      }
    } else {
      // Less than 1000
      return '$amount ${'som'.tr}';
    }
  }

  String _getLastPaymentDate() {
    final latestPayment = summary['latest_payment'];
    if (latestPayment == null) return 'Yo\'q';

    try {
      final date = DateTime.parse(latestPayment['payment_date']);
      return _formatDate(date);
    } catch (e) {
      return 'Yo\'q';
    }
  }

  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'transfer':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'cash'.tr;
      case 'card':
        return 'card'.tr;
      case 'transfer':
        return 'transfer'.tr;
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'today'.tr;
    if (diff == 1) return 'yesterday'.tr;
    if (diff < 30) return '$diff ${'days_ago'.tr}';
    return '${date.day}/${date.month}/${date.year}';
  }
}