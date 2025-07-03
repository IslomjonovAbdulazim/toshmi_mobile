// lib/app/modules/teacher/views/attendance/attendance_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/attendance_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/stats_card.dart';
import 'attendance_form_view.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'attendance_title'.tr,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.selectedGroupSubject.value == null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupSubjectSelector(theme),
                const SizedBox(height: 24),
                EmptyState(
                  title: 'select_class'.tr,
                  message: 'choose_class'.tr,
                  icon: Icons.class_outlined,
                  actionText: 'take_attendance'.tr,
                ),
              ],
            ),
          );
        }

        if (controller.attendanceData.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupSubjectSelector(theme),
                const SizedBox(height: 24),
                EmptyState(
                  title: 'no_attendance_data'.tr,
                  message: 'no_attendance_records'.tr,
                  icon: Icons.how_to_reg_outlined,
                  actionText: 'take_attendance'.tr,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshAll(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupSubjectSelector(theme),
                const SizedBox(height: 16),
                _buildStatsSection(theme),
                const SizedBox(height: 16),
                _buildAttendanceSection(theme),
                SizedBox(height: 200),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _takeAttendance,
        icon: const Icon(Icons.add_task),
        label: Text('take_attendance'.tr),
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
              'select_class'.tr,
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
                    child: Text(controller.getGroupSubjectDisplayName(groupSubject)),
                  );
                }).toList(),
                onChanged: (value) {
                  final selectedGroupSubject = controller.groupSubjects
                      .firstWhereOrNull((gs) => gs.id == value);
                  if (selectedGroupSubject != null) {
                    controller.selectedGroupSubject.value = selectedGroupSubject;
                    controller.loadAttendanceTable(
                      groupSubjectId: selectedGroupSubject.id,
                    );
                  }
                },
                hint: Text('choose_class'.tr),
              );
            }),
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
          '${groupSubject['subject_name'] ?? ''} - ${groupSubject['group_name'] ?? ''}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'total_days'.tr,
                value: '${dateRange['total_dates'] ?? 0}',
                icon: Icons.calendar_today,
                iconColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'students'.tr,
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
              'attendance_records'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTrueSynchronizedScrollTable(theme),
      ],
    );
  }

  Widget _buildTrueSynchronizedScrollTable(ThemeData theme) {
    final students = controller.attendanceData['students'] as List<dynamic>? ?? [];
    final dates = controller.attendanceData['dates'] as List<dynamic>? ?? [];

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

    final sortedDates = List<String>.from(dates.map((d) => d.toString()));
    sortedDates.sort((a, b) {
      try {
        final dateA = DateTime.parse(a);
        final dateB = DateTime.parse(b);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(
                          'student'.tr,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...sortedDates.map((date) => Container(
                        width: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          _formatDateHeader(date),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
                ...students.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  final attendanceByDate = student['attendance_by_date'] as Map<String, dynamic>? ?? {};
                  final summary = student['summary'] as Map<String, dynamic>? ?? {};

                  return Container(
                    decoration: BoxDecoration(
                      border: index < students.length - 1
                          ? Border(bottom: BorderSide(color: theme.dividerColor, width: 1))
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name'] ?? 'unknown'.tr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              _buildEmojiSummary(summary),
                            ],
                          ),
                        ),
                        ...sortedDates.map((date) => Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Center(
                            child: _getStatusIcon(theme, attendanceByDate[date] ?? 'not_recorded'),
                          ),
                        )).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiSummary(Map<String, dynamic> summary) {
    final present = summary['present'] ?? 0;
    final absent = summary['absent'] ?? 0;
    final late = summary['late'] ?? 0;

    return Row(
      children: [
        Text('✅$present', style: const TextStyle(fontSize: 10, color: Colors.green)),
        const SizedBox(width: 3),
        Text('❌$absent', style: const TextStyle(fontSize: 10, color: Colors.red)),
        const SizedBox(width: 3),
        Text('⏰$late', style: const TextStyle(fontSize: 10, color: Colors.orange)),
      ],
    );
  }

  Widget _getStatusIcon(ThemeData theme, String status) {
    switch (status) {
      case 'present':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.check_circle,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        );
      case 'absent':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.cancel,
            size: 16,
            color: theme.colorScheme.error,
          ),
        );
      case 'late':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.schedule,
            size: 16,
            color: theme.colorScheme.tertiary,
          ),
        );
      case 'excused':
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.event_busy,
            size: 16,
            color: theme.colorScheme.secondary,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.help_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        );
    }
  }

  String _formatDateHeader(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}';
    } catch (e) {
      return date;
    }
  }

  void _takeAttendance() {
    Get.to(() => const AttendanceFormView());
  }
}