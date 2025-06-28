import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../utils/widgets/common/custom_app_bar.dart';
import '../../../../utils/widgets/common/loading_widget.dart';
import '../../../../utils/widgets/common/error_widget.dart';
import '../../../../utils/widgets/common/empty_state_widget.dart';
import '../../../../utils/extensions/datetime_extensions.dart';
import '../../controllers/attendance_controller.dart';

class AttendanceTableView extends GetView<AttendanceController> {
  const AttendanceTableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Davomat jadvali',
        actions: [
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range),
            tooltip: 'Sana oralig\'i',
          ),
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yangilash',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _showExportDialog();
                  break;
                case 'filter':
                  _showFilterDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Eksport'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_alt),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section with group selection and date range
          _buildHeaderSection(),

          // Statistics summary
          Obx(() => controller.attendanceTable.isNotEmpty
              ? _buildStatisticsSummary()
              : const SizedBox.shrink()),

          // Attendance table
          Expanded(
            child: _buildAttendanceTable(),
          ),
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
          Container(
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
                  controller.loadAttendanceTable();
                }
              },
            )),
          ),

          const SizedBox(height: 16),

          // Date range display
          Obx(() => Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    border: Border.all(color: Get.theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Get.theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.startDate.value?.formatDate ?? 'Boshlanish',
                        style: Get.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    border: Border.all(color: Get.theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Get.theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.endDate.value?.formatDate ?? 'Tugash',
                        style: Get.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatisticsSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        final students = controller.tableStudents;
        final dates = controller.tableDates;

        if (students.isEmpty || dates.isEmpty) {
          return const SizedBox.shrink();
        }

        // Calculate overall statistics
        int totalClasses = dates.length;
        int totalStudents = students.length;
        int totalPossibleAttendances = totalClasses * totalStudents;

        int totalPresent = 0;
        int totalAbsent = 0;
        int totalLate = 0;
        int totalExcused = 0;

        for (var student in students) {
          final summary = student['summary'] as Map<String, dynamic>? ?? {};
          totalPresent += (summary['present'] as int? ?? 0);
          totalAbsent += (summary['absent'] as int? ?? 0);
          totalLate += (summary['late'] as int? ?? 0);
          totalExcused += (summary['excused'] as int? ?? 0);
        }

        double overallAttendanceRate = totalPossibleAttendances > 0
            ? (totalPresent / totalPossibleAttendances * 100)
            : 0;

        return Column(
          children: [
            Text(
              'Umumiy statistika',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Overview cards
            Row(
              children: [
                _buildStatCard(
                  'O\'quvchilar',
                  totalStudents.toString(),
                  Icons.group,
                  AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Darslar',
                  totalClasses.toString(),
                  Icons.calendar_today,
                  AppColors.secondaryOrange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Davomat',
                  '${overallAttendanceRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Attendance breakdown
            Row(
              children: [
                _buildAttendanceStatCard('Bor', totalPresent, AppColors.present),
                const SizedBox(width: 8),
                _buildAttendanceStatCard('Yo\'q', totalAbsent, AppColors.absent),
                const SizedBox(width: 8),
                _buildAttendanceStatCard('Kech', totalLate, AppColors.late),
                const SizedBox(width: 8),
                _buildAttendanceStatCard('Uzrli', totalExcused, AppColors.excused),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Get.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Get.textTheme.bodySmall?.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Obx(() {
      if (controller.selectedGroupSubjectId.value == 0) {
        return const EmptyStateWidget(
          title: 'Guruh tanlang',
          message: 'Davomat jadvalini ko\'rish uchun guruh va fanni tanlang',
          icon: Icons.group_outlined,
        );
      }

      if (controller.isLoading.value) {
        return const LoadingWidget(message: 'Davomat jadvali yuklanmoqda...');
      }

      if (controller.hasError.value) {
        return CustomErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.loadAttendanceTable,
        );
      }

      if (controller.tableStudents.isEmpty || controller.tableDates.isEmpty) {
        return const EmptyStateWidget(
          title: 'Ma\'lumot yo\'q',
          message: 'Tanlangan davr uchun davomat ma\'lumotlari topilmadi',
          icon: Icons.table_rows_outlined,
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: _buildDataTable(),
        ),
      );
    });
  }

  Widget _buildDataTable() {
    final students = controller.tableStudents;
    final dates = controller.tableDates;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Get.theme.colorScheme.outline.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        border: TableBorder.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.2),
        ),
        columnSpacing: 8,
        horizontalMargin: 8,
        columns: [
          DataColumn(
            label: Container(
              width: 150,
              child: Text(
                'O\'quvchi',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...dates.map((date) {
            final parsedDate = DateTime.tryParse(date);
            return DataColumn(
              label: Container(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      parsedDate?.day.toString() ?? date,
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      parsedDate?.formatDate.split('.').take(2).join('.') ?? date,
                      style: Get.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          DataColumn(
            label: Container(
              width: 80,
              child: Text(
                'Jami %',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows: students.map((student) {
          final studentId = student['student_id'] as int;
          final studentName = student['name'] as String;
          final summary = controller.getStudentSummary(studentId);
          final attendancePercentage = controller.getAttendancePercentage(studentId);

          return DataRow(
            cells: [
              DataCell(
                Container(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        studentName,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: $studentId',
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...dates.map((date) {
                final attendance = controller.getTableAttendance(studentId, date);
                return DataCell(
                  _buildAttendanceCell(attendance),
                );
              }).toList(),
              DataCell(
                Container(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${attendancePercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getPercentageColor(attendancePercentage),
                        ),
                      ),
                      Text(
                        '${summary['present'] ?? 0}/${summary['total_days'] ?? 0}',
                        style: Get.textTheme.labelSmall?.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttendanceCell(String status) {
    if (status.isEmpty) {
      return Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.remove,
          color: Colors.grey,
          size: 16,
        ),
      );
    }

    final color = controller.getStatusColor(status);
    final icon = controller.getStatusIcon(status);

    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.warning;
    return AppColors.error;
  }

  void _showDateRangePicker() async {
    final dateRange = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
        end: controller.endDate.value ?? DateTime.now(),
      ),
    );

    if (dateRange != null) {
      controller.setDateRange(dateRange.start, dateRange.end);
    }
  }

  void _showExportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Davomat jadvalini eksport qilish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel fayli'),
              subtitle: const Text('(.xlsx format)'),
              onTap: () {
                Get.back();
                // Implement Excel export
                Get.snackbar('Ma\'lumot', 'Excel eksport funksiyasi');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF fayli'),
              subtitle: const Text('Jadval PDF formatida'),
              onTap: () {
                Get.back();
                // Implement PDF export
                Get.snackbar('Ma\'lumot', 'PDF eksport funksiyasi');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter sozlamalari'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Faqat kechikkanlar'),
              value: false,
              onChanged: (value) {
                // Implement filter
              },
            ),
            CheckboxListTile(
              title: const Text('Faqat yo\'qlar'),
              value: false,
              onChanged: (value) {
                // Implement filter
              },
            ),
            CheckboxListTile(
              title: const Text('Past davomat (75% dan kam)'),
              value: false,
              onChanged: (value) {
                // Implement filter
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Apply filters
            },
            child: const Text('Qo\'llash'),
          ),
        ],
      ),
    );
  }
}