import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class StudentAttendanceView extends StatefulWidget {
  const StudentAttendanceView({super.key});

  @override
  State<StudentAttendanceView> createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  final StudentRepository repository = StudentRepository();
  final isLoading = false.obs;
  final attendance = <dynamic>[].obs;
  final summary = <String, dynamic>{}.obs;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    try {
      isLoading.value = true;
      final attendanceData = await repository.getAttendance();
      final summaryData = await repository.getAttendanceSummary();

      attendance.value = attendanceData;
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
        title: 'attendance'.tr,
        showBackButton: true,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: loadAttendance,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSummaryCards(),
                _buildAttendanceList(),
                SizedBox(height: 100),
              ],
            ),
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
              Expanded(child: _buildSummaryCard('total'.tr, '${summary['total'] ?? 0}', Colors.blue)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('present'.tr, '${summary['present'] ?? 0}', Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('absent'.tr, '${summary['absent'] ?? 0}', Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('percentage'.tr, '${summary['present_percentage']?.toStringAsFixed(1) ?? 0}%', Colors.purple)),
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (attendance.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = <String, List<dynamic>>{};
    for (final record in attendance) {
      final date = DateTime.parse(record['date']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      grouped[monthKey] = grouped[monthKey] ?? [];
      grouped[monthKey]!.add(record);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final monthKey = grouped.keys.elementAt(index);
        final records = grouped[monthKey]!;
        return _buildMonthSection(monthKey, records);
      },
    );
  }

  Widget _buildMonthSection(String monthKey, List<dynamic> records) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthNames = ['', 'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr, 'may'.tr, 'june'.tr,
      'july'.tr, 'august'.tr, 'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Text(
            '${monthNames[month]} $year',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...records.map((record) => _buildAttendanceCard(record)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final status = record['status'] as String;
    final date = DateTime.parse(record['date']);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'present'.tr;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'absent'.tr;
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'late'.tr;
        break;
      case 'excused':
        statusColor = Colors.blue;
        statusIcon = Icons.info;
        statusText = 'excused'.tr;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(record['subject'] ?? ''),
        subtitle: Text('${record['teacher'] ?? ''} • ${_formatDate(date)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'attendance_empty'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['', 'monday'.tr, 'tuesday'.tr, 'wednesday'.tr, 'thursday'.tr, 'friday'.tr, 'saturday'.tr, 'sunday'.tr];
    return '${date.day}/${date.month} (${weekdays[date.weekday]})';
  }
}