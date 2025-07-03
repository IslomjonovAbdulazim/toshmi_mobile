import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/loading_widget.dart';
import '../controllers/parent_controller.dart';

class ParentPaymentsView extends StatefulWidget {
  const ParentPaymentsView({super.key});

  @override
  State<ParentPaymentsView> createState() => _ParentPaymentsViewState();
}

class _ParentPaymentsViewState extends State<ParentPaymentsView> {
  late int childId;
  late ParentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ParentController>();

    final arguments = Get.arguments as Map<String, dynamic>?;
    childId = arguments?['childId'] ?? controller.selectedChildId.value ?? 0;

    if (childId == 0) {
      Get.back();
      Get.snackbar('error'.tr, 'child_not_selected'.tr);
      return;
    }

    if (controller.selectedChildId.value != childId) {
      controller.selectChild(childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: '${'payments'.tr} - ${controller.selectedChildName}',
        actions: [
          IconButton(
            onPressed: () => controller.refreshChildPayments(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshChildPayments(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentSummary(theme),
              const SizedBox(height: 24),
              _buildPaymentsList(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(ThemeData theme) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getChildPaymentSummary(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final totalPaid = data['total_paid'] as int;
        final paymentCount = data['payment_count'] as int;
        final averagePayment = data['average_payment'] as int;
        final latestPayment = data['latest_payment'] as Map<String, dynamic>?;
        final paymentMethods = data['payment_methods'] as Map<String, int>;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'payment_report'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.parentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.parentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'total_paid'.tr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_formatAmount(totalPaid)} ${'som'.tr}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.parentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'payments'.tr,
                        paymentCount.toString(),
                        Colors.blue,
                        Icons.payment,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'average'.tr,
                        '${_formatAmount(averagePayment)} ${'som'.tr}',
                        Colors.green,
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),

                if (latestPayment != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'last_payment'.tr,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatAmount(latestPayment['amount'])} ${'som'.tr}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(DateTime.parse(latestPayment['payment_date'])),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(ThemeData theme) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      final paymentsData = controller.currentChildPayments.value;
      if (paymentsData == null) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.payment, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'payment_info_not_found'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final paymentRecords = paymentsData['payment_records'] as List<dynamic>;

      if (paymentRecords.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.payment_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'payments_empty'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'payments_empty_subtitle'.tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final groupedPayments = <String, List<Map<String, dynamic>>>{};
      for (final payment in paymentRecords) {
        final date = DateTime.parse(payment['payment_date']);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        groupedPayments.putIfAbsent(monthKey, () => []).add(payment.cast<String, dynamic>());
      }

      final sortedMonths = groupedPayments.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      for (final monthKey in groupedPayments.keys) {
        groupedPayments[monthKey]!.sort((a, b) =>
            DateTime.parse(b['payment_date']).compareTo(DateTime.parse(a['payment_date'])));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_history'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedMonths.map((monthYear) {
            final payments = groupedPayments[monthYear]!;
            final monthTotal = payments.fold<int>(0, (sum, p) => sum + (p['amount'] as int));

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.parentColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _formatMonthYear(monthYear),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.parentColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatAmount(monthTotal)} ${'som'.tr}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.parentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...payments.map((payment) => _buildPaymentItem(payment)),
                ],
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final amount = payment['amount'] as int;
    final paymentDate = DateTime.parse(payment['payment_date']);
    final paymentMethod = payment['payment_method'] as String;
    final description = payment['description'] as String? ?? '';
    final createdAt = DateTime.parse(payment['created_at']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(paymentMethod),
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatAmount(amount)} ${'som'.tr}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _getPaymentMethodName(paymentMethod),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(paymentDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'cash'.tr;
      case 'card':
        return 'card'.tr;
      case 'transfer':
        return 'transfer'.tr;
      case 'online':
        return 'online'.tr;
      default:
        return method;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'transfer':
        return Icons.account_balance;
      case 'online':
        return Icons.computer;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr, 'may'.tr, 'june'.tr,
      'july'.tr, 'august'.tr, 'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatMonthYear(String monthYear) {
    final months = [
      'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr, 'may'.tr, 'june'.tr,
      'july'.tr, 'august'.tr, 'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr
    ];

    final parts = monthYear.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);

    return '${months[month - 1]} $year';
  }
}