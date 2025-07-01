// lib/app/modules/teacher/views/attendance/widgets/attendance_table.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'student_attendance_row.dart';

class AttendanceTable extends StatelessWidget {
  final Map<String, dynamic> attendanceData;
  final bool isReadOnly;
  final Function(int studentId, String status)? onStatusChanged;

  const AttendanceTable({
    super.key,
    required this.attendanceData,
    this.isReadOnly = true,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final students = attendanceData['students'] as List<dynamic>? ?? [];
    final dates = attendanceData['dates'] as List<dynamic>? ?? [];

    if (students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'no_students_found'.tr,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dates.isNotEmpty) _buildDateHeader(context, dates),
          _buildStudentList(context, students),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, List<dynamic> dates) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'student'.tr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (dates.length <= 7)
            ...dates.map((date) => Expanded(
              child: Text(
                _formatDateHeader(date),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )),
          if (dates.length > 7)
            Expanded(
              child: Text(
                'summary'.tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, List<dynamic> students) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentAttendanceRow(
          student: student,
          dates: attendanceData['dates'] as List<dynamic>? ?? [],
          isReadOnly: isReadOnly,
          onStatusChanged: onStatusChanged,
        );
      },
    );
  }

  String _formatDateHeader(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}';
    } catch (e) {
      return date;
    }
  }
}