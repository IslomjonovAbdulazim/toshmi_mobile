import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/loading_widget.dart';
import '../controllers/parent_controller.dart';

class ParentAttendanceView extends StatelessWidget {
  const ParentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ParentController>();
    final childId = Get.arguments?['childId'] ?? controller.selectedChildId.value;

    if (childId == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'attendance'.tr),
        body: Center(
          child: Text('child_not_selected'.tr),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '${'attendance'.tr} - ${controller.selectedChildName}',
        actions: [
          IconButton(
            onPressed: () => controller.refreshChildAttendance(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshChildAttendance(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAttendanceSummary(controller, childId),
              const SizedBox(height: 24),
              _buildAttendanceList(controller, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary(ParentController controller, int childId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getChildAttendanceSummary(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final total = data['total'] as int;
        final present = data['present'] as int;
        final absent = data['absent'] as int;
        final late = data['late'] as int;
        final excused = data['excused'] as int;
        final percentage = data['present_percentage'] as double;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'attendance_report'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.assessment,
                        color: _getPercentageColor(percentage),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'overall_attendance'.tr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: _getPercentageColor(percentage),
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
                        'present'.tr,
                        present.toString(),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'absent'.tr,
                        absent.toString(),
                        Colors.red,
                        Icons.cancel,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'late'.tr,
                        late.toString(),
                        Colors.orange,
                        Icons.access_time,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'excused'.tr,
                        excused.toString(),
                        Colors.blue,
                        Icons.verified,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(ParentController controller, BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      if (controller.currentChildAttendance.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.event_available,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'attendance_info_not_found'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final groupedAttendance = <String, List<Map<String, dynamic>>>{};
      for (final record in controller.currentChildAttendance) {
        final date = DateTime.parse(record['date']);
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        groupedAttendance.putIfAbsent(monthKey, () => []).add(record);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'attendance_history'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...groupedAttendance.entries.map((entry) {
            final monthYear = entry.key;
            final records = entry.value;
            records.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

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
                    child: Text(
                      _formatMonthYear(monthYear),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.parentColor,
                      ),
                    ),
                  ),
                  ...records.map((record) => _buildAttendanceItem(record)),
                ],
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  Widget _buildAttendanceItem(Map<String, dynamic> record) {
    final date = DateTime.parse(record['date']);
    final status = record['status'] as String;
    final subject = record['subject'] as String;
    final teacher = record['teacher'] as String;

    final statusInfo = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusInfo['color'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusInfo['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusInfo['text'],
                        style: TextStyle(
                          color: statusInfo['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${'teacher'.tr}: $teacher',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return {'text': 'present'.tr, 'color': Colors.green};
      case 'absent':
        return {'text': 'absent'.tr, 'color': Colors.red};
      case 'late':
        return {'text': 'late'.tr, 'color': Colors.orange};
      case 'excused':
        return {'text': 'excused'.tr, 'color': Colors.blue};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final months = [
      'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr, 'may'.tr, 'june'.tr,
      'july'.tr, 'august'.tr, 'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr
    ];
    final weekdays = ['monday'.tr, 'tuesday'.tr, 'wednesday'.tr, 'thursday'.tr, 'friday'.tr, 'saturday'.tr, 'sunday'.tr];

    return '${date.day} ${months[date.month - 1]}, ${weekdays[date.weekday - 1]}';
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