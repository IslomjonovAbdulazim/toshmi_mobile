import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/loading_widget.dart';
import '../../../../utils/widgets/common/error_widget.dart';
import '../../../../utils/widgets/common/empty_state_widget.dart';
import '../../../../utils/extensions/datetime_extensions.dart';
import '../../controllers/attendance_controller.dart';

class AttendanceMarkingView extends GetView<AttendanceController> {
  const AttendanceMarkingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Davomat belgilash',
        actions: [
          Obx(() => controller.hasUnsavedChanges.value
              ? IconButton(
            onPressed: controller.saveAttendance,
            icon: const Icon(Icons.save),
            tooltip: 'Saqlash',
            color: AppColors.success,
          )
              : IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yangilash',
          )),
        ],
      ),
      body: Column(
        children: [
          // Header section with date and group selection
          _buildHeaderSection(),

          // Statistics section
          Obx(() => controller.attendanceRecords.isNotEmpty
              ? _buildStatisticsSection()
              : const SizedBox.shrink()),

          // Students list
          Expanded(
            child: _buildStudentsList(),
          ),

          // Bottom action bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Group subject selector
          _buildGroupSubjectSelector(),
          const SizedBox(height: 16),

          // Date selector
          _buildDateSelector(),
        ],
      ),
    );
  }

  Widget _buildGroupSubjectSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border.all(color: Get.theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => DropdownButton<int>(
        value: controller.selectedGroupSubjectId.value == 0
            ? null
            : controller.selectedGroupSubjectId.value,
        hint: Row(
          children: [
            Icon(
              Icons.group,
              color: Get.theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Guruh va fanni tanlang'),
          ],
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: controller.groupSubjects.map((gs) {
          return DropdownMenuItem<int>(
            value: gs['group_subject_id'],
            child: Text('${gs['group_name']} • ${gs['subject_name']}'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.setGroupSubject(value);
          }
        },
      )),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surface,
                border: Border.all(color: Get.theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Get.theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => Text(
                      controller.selectedDate.value.formatDate,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ),
                  if (controller.isToday(controller.selectedDate.value))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Bugun',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Quick date buttons
        IconButton(
          onPressed: () => controller.setSelectedDate(DateTime.now()),
          icon: const Icon(Icons.today),
          tooltip: 'Bugun',
          style: IconButton.styleFrom(
            backgroundColor: controller.isToday(controller.selectedDate.value)
                ? AppColors.primaryBlue.withOpacity(0.2)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        final stats = controller.attendanceStats;
        final total = controller.students.length;
        final marked = controller.attendanceRecords.length;

        return Column(
          children: [
            Text(
              'Davomat statistikasi',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar
            LinearProgressIndicator(
              value: total > 0 ? marked / total : 0,
              backgroundColor: Get.theme.colorScheme.outline.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: 8),
            Text(
              '$marked / $total o\'quvchi belgilandi',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Status breakdown
            Row(
              children: [
                _buildStatChip('Bor', stats['present'] ?? 0, AppColors.present),
                const SizedBox(width: 8),
                _buildStatChip('Yo\'q', stats['absent'] ?? 0, AppColors.absent),
                const SizedBox(width: 8),
                _buildStatChip('Kech', stats['late'] ?? 0, AppColors.late),
                const SizedBox(width: 8),
                _buildStatChip('Uzrli', stats['excused'] ?? 0, AppColors.excused),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Obx(() {
      if (controller.selectedGroupSubjectId.value == 0) {
        return const EmptyStateWidget(
          title: 'Guruh tanlang',
          message: 'Davomat belgilash uchun guruh va fanni tanlang',
          icon: Icons.group_outlined,
        );
      }

      if (controller.isLoadingStudents.value) {
        return const LoadingWidget(message: 'O\'quvchilar yuklanmoqda...');
      }

      if (controller.students.isEmpty) {
        return const EmptyStateWidget(
          title: 'O\'quvchilar yo\'q',
          message: 'Bu guruhda o\'quvchilar topilmadi',
          icon: Icons.person_outline,
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.students.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final student = controller.students[index];
          return _buildStudentCard(student);
        },
      );
    });
  }

  Widget _buildStudentCard(dynamic student) {
    final studentId = student['id'] as int;
    final studentName = student['name'] as String;

    return Obx(() {
      final currentStatus = controller.getAttendanceStatus(studentId);

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Text(
                      studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'ID: $studentId',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (currentStatus.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.getStatusColor(currentStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.getStatusText(currentStatus),
                        style: TextStyle(
                          color: controller.getStatusColor(currentStatus),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Attendance status buttons
              Row(
                children: [
                  _buildStatusButton(
                    studentId,
                    'present',
                    'Bor',
                    AppColors.present,
                    Icons.check_circle,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusButton(
                    studentId,
                    'absent',
                    'Yo\'q',
                    AppColors.absent,
                    Icons.cancel,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusButton(
                    studentId,
                    'late',
                    'Kech',
                    AppColors.late,
                    Icons.access_time,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusButton(
                    studentId,
                    'excused',
                    'Uzrli',
                    AppColors.excused,
                    Icons.info,
                  ),
                ],
              ),

              // Clear button
              if (currentStatus.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.removeAttendance(studentId),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Tozalash'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusButton(
      int studentId,
      String status,
      String label,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.getAttendanceStatus(studentId) == status;

        return ElevatedButton.icon(
          onPressed: () => controller.setAttendance(studentId, status),
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color : color.withOpacity(0.1),
            foregroundColor: isSelected ? Colors.white : color,
            elevation: isSelected ? 2 : 0,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      }),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.markAllStudents('present'),
                  icon: Icon(Icons.check_circle, color: AppColors.present),
                  label: const Text('Hammasini bor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.present,
                    side: BorderSide(color: AppColors.present),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.clearAllAttendance,
                  icon: Icon(Icons.clear_all, color: AppColors.error),
                  label: const Text('Hammasini tozala'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Save button
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.attendanceRecords.isNotEmpty && !controller.isSavingAttendance.value
                  ? controller.saveAttendance
                  : null,
              icon: controller.isSavingAttendance.value
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(controller.isSavingAttendance.value ? 'Saqlanmoqda...' : 'Davomatni saqlash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null) {
      controller.setSelectedDate(date);
    }
  }
}