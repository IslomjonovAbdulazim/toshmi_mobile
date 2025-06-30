// lib/app/modules/teacher/views/attendance/attendance_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import 'widgets/attendance_table.dart';

class AttendanceFormView extends GetView<AttendanceController> {
  const AttendanceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = DateTime.now().obs;
    final selectedGroupSubject = RxnInt();
    final attendanceMap = <int, String>{}.obs;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'Take Attendance',
        actions: [
          TextButton(
            onPressed: () => _saveAttendance(
              selectedGroupSubject.value,
              selectedDate.value,
              attendanceMap,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(theme, selectedDate),
            const SizedBox(height: 16),
            _buildClassSelector(theme, selectedGroupSubject),
            const SizedBox(height: 24),
            Obx(() {
              if (selectedGroupSubject.value == null) {
                return _buildEmptyState(theme);
              }

              if (controller.groupStudents.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildStudentsList(theme, attendanceMap);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme, Rx<DateTime> selectedDate) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => InkWell(
              onTap: () => _selectDate(selectedDate),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(selectedDate.value),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelector(ThemeData theme, RxnInt selectedGroupSubject) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class',
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
                selectedGroupSubject.value = value;
                if (value != null) {
                  controller.loadGroupStudents(1); // Should use actual group ID
                }
              },
              hint: const Text('Select a class'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.class_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a Class',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a class to take attendance',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList(ThemeData theme, RxMap<int, String> attendanceMap) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Students',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _markAllPresent(attendanceMap),
                      child: const Text('All Present'),
                    ),
                    TextButton(
                      onPressed: () => _markAllAbsent(attendanceMap),
                      child: const Text('All Absent'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.groupStudents.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final student = controller.groupStudents[index];
              final studentId = student['id'] as int;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    student['name']?.substring(0, 1).toUpperCase() ?? 'S',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(student['name'] ?? 'Unknown'),
                subtitle: Text(student['phone'] ?? ''),
                trailing: Obx(() => _buildStatusSelector(
                  theme,
                  attendanceMap[studentId] ?? 'present',
                      (status) => attendanceMap[studentId] = status,
                )),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(
      ThemeData theme,
      String currentStatus,
      Function(String) onChanged,
      ) {
    return DropdownButton<String>(
      value: currentStatus,
      underline: const SizedBox(),
      items: [
        DropdownMenuItem(
          value: 'present',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 16),
              const SizedBox(width: 4),
              const Text('Present'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'absent',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: theme.colorScheme.error, size: 16),
              const SizedBox(width: 4),
              const Text('Absent'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'late',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, color: theme.colorScheme.tertiary, size: 16),
              const SizedBox(width: 4),
              const Text('Late'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'excused',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, color: theme.colorScheme.secondary, size: 16),
              const SizedBox(width: 4),
              const Text('Excused'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(Rx<DateTime> selectedDate) async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  void _markAllPresent(RxMap<int, String> attendanceMap) {
    for (final student in controller.groupStudents) {
      attendanceMap[student['id']] = 'present';
    }
  }

  void _markAllAbsent(RxMap<int, String> attendanceMap) {
    for (final student in controller.groupStudents) {
      attendanceMap[student['id']] = 'absent';
    }
  }

  void _saveAttendance(
      int? groupSubjectId,
      DateTime date,
      Map<int, String> attendanceMap,
      ) {
    if (groupSubjectId == null) {
      Get.snackbar('Error', 'Please select a class');
      return;
    }

    if (attendanceMap.isEmpty) {
      Get.snackbar('Error', 'No attendance data to save');
      return;
    }

    final records = attendanceMap.entries.map((entry) => {
      'student_id': entry.key,
      'status': entry.value,
    }).toList();

    controller.submitBulkAttendance(
      groupSubjectId: groupSubjectId,
      date: date,
      records: records,
    );

    Get.back();
  }
}