// lib/app/modules/teacher/views/attendance/widgets/student_attendance_row.dart
import 'package:flutter/material.dart';

class StudentAttendanceRow extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> dates;
  final bool isReadOnly;
  final Function(int studentId, String status)? onStatusChanged;

  const StudentAttendanceRow({
    super.key,
    required this.student,
    required this.dates,
    this.isReadOnly = true,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attendanceByDate = student['attendance_by_date'] as Map<String, dynamic>? ?? {};
    final summary = student['summary'] as Map<String, dynamic>? ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _buildSummaryText(summary),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (dates.length <= 7)
            ...dates.map((date) => Expanded(
              child: _buildAttendanceStatus(
                context,
                attendanceByDate[date] ?? 'not_recorded',
                student['student_id'],
              ),
            )),
          if (dates.length > 7)
            Expanded(
              child: _buildSummaryChip(context, summary),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatus(BuildContext context, String status, int studentId) {
    final theme = Theme.of(context);

    if (isReadOnly) {
      return Center(
        child: _getStatusIcon(theme, status),
      );
    }

    return Center(
      child: PopupMenuButton<String>(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(theme, status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _getStatusIcon(theme, status),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'present',
            child: Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Present'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'absent',
            child: Row(
              children: [
                Icon(Icons.cancel, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                const Text('Absent'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'late',
            child: Row(
              children: [
                Icon(Icons.schedule, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                const Text('Late'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'excused',
            child: Row(
              children: [
                Icon(Icons.event_busy, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                const Text('Excused'),
              ],
            ),
          ),
        ],
        onSelected: (newStatus) {
          onStatusChanged?.call(studentId, newStatus);
        },
      ),
    );
  }

  Widget _buildSummaryChip(BuildContext context, Map<String, dynamic> summary) {
    final theme = Theme.of(context);
    final present = summary['present'] ?? 0;
    final total = summary['total_days'] ?? 1;
    final percentage = total > 0 ? (present / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPercentageColor(theme, percentage).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percentage%',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getPercentageColor(theme, percentage),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _getStatusIcon(ThemeData theme, String status) {
    switch (status) {
      case 'present':
        return Icon(
          Icons.check_circle,
          size: 20,
          color: theme.colorScheme.primary,
        );
      case 'absent':
        return Icon(
          Icons.cancel,
          size: 20,
          color: theme.colorScheme.error,
        );
      case 'late':
        return Icon(
          Icons.schedule,
          size: 20,
          color: theme.colorScheme.tertiary,
        );
      case 'excused':
        return Icon(
          Icons.event_busy,
          size: 20,
          color: theme.colorScheme.secondary,
        );
      default:
        return Icon(
          Icons.help_outline,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        );
    }
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'present':
        return theme.colorScheme.primary;
      case 'absent':
        return theme.colorScheme.error;
      case 'late':
        return theme.colorScheme.tertiary;
      case 'excused':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Color _getPercentageColor(ThemeData theme, int percentage) {
    if (percentage >= 90) return theme.colorScheme.primary;
    if (percentage >= 75) return theme.colorScheme.tertiary;
    return theme.colorScheme.error;
  }

  String _buildSummaryText(Map<String, dynamic> summary) {
    final present = summary['present'] ?? 0;
    final absent = summary['absent'] ?? 0;
    final late = summary['late'] ?? 0;
    return 'P:$present A:$absent L:$late';
  }
}