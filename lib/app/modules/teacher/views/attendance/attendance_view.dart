// lib/app/modules/teacher/views/attendance/attendance_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/stats_card.dart';
import 'widgets/attendance_table.dart';
import 'attendance_form_view.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'Attendance',
        actions: [
          IconButton(
            onPressed: _showDateFilter,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.attendanceData.isEmpty) {
          return const EmptyState(
            title: 'No Attendance Data',
            message: 'Select a class and take attendance to get started.',
            icon: Icons.how_to_reg_outlined,
            actionText: 'Take Attendance',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAttendance(1), // Should use actual group subject ID
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClassSelector(theme),
                const SizedBox(height: 16),
                _buildStatsSection(theme),
                const SizedBox(height: 16),
                _buildAttendanceSection(theme),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _takeAttendance,
        icon: const Icon(Icons.add_task),
        label: const Text('Take Attendance'),
      ),
    );
  }

  Widget _buildClassSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Class',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.class_),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Math - Grade 10A')),
                DropdownMenuItem(value: 2, child: Text('Physics - Grade 11B')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.loadAttendanceTable(groupSubjectId: value);
                }
              },
              hint: const Text('Choose a class'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    final groupSubject = controller.attendanceData['group_subject'] as Map<String, dynamic>? ?? {};
    final dateRange = controller.attendanceData['date_range'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${groupSubject['subject_name']} - ${groupSubject['group_name']}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total Days',
                value: '${dateRange['total_dates'] ?? 0}',
                icon: Icons.calendar_today,
                iconColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Students',
                value: '${(controller.attendanceData['students'] as List?)?.length ?? 0}',
                icon: Icons.people,
                iconColor: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendance Records',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _exportAttendance,
              icon: const Icon(Icons.download),
              label: const Text('Export'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AttendanceTable(
          attendanceData: controller.attendanceData,
          isReadOnly: true,
        ),
      ],
    );
  }

  void _takeAttendance() {
    Get.to(() => const AttendanceFormView());
  }

  void _showDateFilter() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Date Range',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.date_range),
                    label: const Text('Start Date'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.date_range),
                    label: const Text('End Date'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Get.back();
                      // Apply filter
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportAttendance() {
    Get.snackbar('Info', 'Export feature coming soon');
  }
}