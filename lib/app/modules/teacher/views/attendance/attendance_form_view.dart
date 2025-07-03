// lib/app/modules/teacher/views/attendance/attendance_form_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/attendance_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';

class AttendanceFormView extends GetView<AttendanceController> {
  const AttendanceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDate = DateTime.now().obs;
    final attendanceMap = <int, String>{}.obs;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'take_attendance'.tr,
        actions: [
          TextButton(
            onPressed: () => _saveAttendance(selectedDate.value, attendanceMap),
            child: Text('save'.tr),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(theme, selectedDate),
            const SizedBox(height: 16),
            _buildGroupSubjectSelector(theme),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.selectedGroupSubject.value == null) {
                return _buildEmptyState(theme, 'select_class_to_continue'.tr);
              }

              if (controller.groupStudents.isEmpty &&
                  !controller.isLoading.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.selectedGroupSubject.value != null) {
                    controller.loadGroupStudents(
                      controller.selectedGroupSubject.value!.groupId,
                    );
                  }
                });
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.groupStudents.isEmpty) {
                return _buildEmptyState(theme, 'no_students_in_class'.tr);
              }

              return _buildStudentsList(theme, attendanceMap);
            }),
            SizedBox(height: 200),

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
              'date'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => InkWell(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSubjectSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'class'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.groupSubjects.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('no_classes_assigned'.tr),
                );
              }

              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.class_),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                value: controller.selectedGroupSubject.value?.id,
                items: controller.groupSubjects.map((groupSubject) {
                  return DropdownMenuItem(
                    value: groupSubject.id,
                    child: SizedBox(
                      width: Get.size.width * .6,
                      child: Text(
                        controller.getGroupSubjectDisplayName(groupSubject),
                        style: TextStyle(
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  final selectedGroupSubject = controller.groupSubjects
                      .firstWhereOrNull((gs) => gs.id == value);
                  if (selectedGroupSubject != null) {
                    controller.selectedGroupSubject.value =
                        selectedGroupSubject;
                  }
                },
                hint: Text('select_class'.tr),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
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
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList(ThemeData theme, RxMap<int, String> attendanceMap) {
    for (final student in controller.groupStudents) {
      final studentId = student['id'] as int;
      if (!attendanceMap.containsKey(studentId)) {
        attendanceMap[studentId] = 'present';
      }
    }

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
                  '${'students'.tr} (${controller.groupStudents.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: TextButton(
                    onPressed: () => _markAllPresent(attendanceMap),
                    child: Text('all_present'.tr),
                  ),
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
                    (student['name'] as String?)
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'O',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  (student['name'] ?? 'unknown'.tr),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  student['phone'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11),
                ),
                trailing: Obx(
                  () => _buildStatusSelector(
                    theme,
                    attendanceMap[studentId] ?? 'present',
                    (status) => attendanceMap[studentId] = status,
                  ),
                ),
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
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              // const SizedBox(width: 4),
              // Text('present'.tr, style: TextStyle(fontSize: 10),),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'absent',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: theme.colorScheme.error, size: 16),
              // const SizedBox(width: 4),
              // Text('absent'.tr),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'late',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, color: theme.colorScheme.tertiary, size: 16),
              // const SizedBox(width: 4),
              // Text('late'.tr),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'excused',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
              // const SizedBox(width: 4),
              // Text('excused'.tr),
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
      helpText: 'select_date'.tr,
      cancelText: 'cancel'.tr,
      confirmText: 'confirm'.tr,
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

  void _saveAttendance(DateTime date, Map<int, String> attendanceMap) {
    if (controller.selectedGroupSubject.value == null) {
      Get.snackbar('error'.tr, 'please_select_class'.tr);
      return;
    }

    if (attendanceMap.isEmpty) {
      Get.snackbar('error'.tr, 'no_attendance_data_to_save'.tr);
      return;
    }

    final records = attendanceMap.entries
        .map((entry) => {'student_id': entry.key, 'status': entry.value})
        .toList();

    controller.submitBulkAttendance(
      groupSubjectId: controller.selectedGroupSubject.value!.id,
      date: date,
      records: records,
    );

    Get.back();
  }
}
