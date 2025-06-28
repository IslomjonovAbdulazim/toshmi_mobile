// lib/app/modules/teacher/controllers/attendance_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../utils/constants/app_constants.dart';

class AttendanceController extends BaseController {
  final TeacherRepository _repository = Get.find<TeacherRepository>();

  // Current attendance session
  final RxInt selectedGroupSubjectId = 0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<dynamic> students = <dynamic>[].obs;
  final RxMap<int, String> attendanceRecords = <int, String>{}.obs;

  // Attendance table data
  final RxMap<String, dynamic> attendanceTable = <String, dynamic>{}.obs;
  final RxList<String> tableDates = <String>[].obs;
  final RxList<dynamic> tableStudents = <dynamic>[].obs;

  // Available group-subjects (teacher's assigned classes)
  final RxList<Map<String, dynamic>> groupSubjects = <Map<String, dynamic>>[].obs;

  // Date range for viewing
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // UI state
  final RxBool isMarkingAttendance = false.obs;
  final RxBool isLoadingStudents = false.obs;
  final RxBool isSavingAttendance = false.obs;
  final RxBool hasUnsavedChanges = false.obs;

  // Statistics
  final RxMap<String, int> attendanceStats = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDates();
    loadGroupSubjects();
  }

  void _initializeDates() {
    final now = DateTime.now();
    // Set default range to current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    startDate.value = monday;
    endDate.value = monday.add(const Duration(days: 6));
  }

  // Load teacher's assigned group-subjects
  Future<void> loadGroupSubjects() async {
    try {
      // This would come from an API that returns teacher's assignments
      // For now, we'll use mock data
      groupSubjects.assignAll([
        {
          'id': 1,
          'group_name': '10-A',
          'subject_name': 'Matematika',
          'group_subject_id': 1,
        },
        {
          'id': 2,
          'group_name': '10-B',
          'subject_name': 'Matematika',
          'group_subject_id': 2,
        },
      ]);
    } catch (e) {
      setError('Guruhlar yuklanmadi: $e');
    }
  }

  // Load students for selected group-subject
  Future<void> loadStudents(int groupId) async {
    try {
      isLoadingStudents.value = true;
      clearError();

      final data = await _repository.getGroupStudents(groupId);
      students.assignAll(data);

      // Clear previous attendance records
      attendanceRecords.clear();
      hasUnsavedChanges.value = false;

      print('✅ Loaded ${data.length} students for group $groupId');
    } catch (e) {
      setError('O\'quvchilar yuklanmadi: $e');
    } finally {
      isLoadingStudents.value = false;
    }
  }

  // Set attendance for a student
  void setAttendance(int studentId, String status) {
    if (!AppConstants.attendancePresent.contains(status) &&
        !AppConstants.attendanceAbsent.contains(status) &&
        !AppConstants.attendanceLate.contains(status) &&
        !AppConstants.attendanceExcused.contains(status)) {
      showError('Noto\'g\'ri davomat holati');
      return;
    }

    attendanceRecords[studentId] = status;
    hasUnsavedChanges.value = true;
    _updateAttendanceStats();
  }

  // Remove attendance for a student
  void removeAttendance(int studentId) {
    attendanceRecords.remove(studentId);
    hasUnsavedChanges.value = attendanceRecords.isNotEmpty;
    _updateAttendanceStats();
  }

  // Mark all students with same status
  void markAllStudents(String status) {
    for (var student in students) {
      final studentId = student['id'] as int;
      setAttendance(studentId, status);
    }
    showSuccess('Barcha o\'quvchilar $status deb belgilandi');
  }

  // Clear all attendance records
  void clearAllAttendance() {
    attendanceRecords.clear();
    hasUnsavedChanges.value = false;
    _updateAttendanceStats();
  }

  // Save attendance
  Future<void> saveAttendance() async {
    if (selectedGroupSubjectId.value == 0) {
      showError('Guruh va fanni tanlang');
      return;
    }

    if (attendanceRecords.isEmpty) {
      showError('Kamida bitta o\'quvchining davomatini belgilang');
      return;
    }

    try {
      isSavingAttendance.value = true;

      final records = attendanceRecords.entries.map((entry) => {
        'student_id': entry.key,
        'status': entry.value,
      }).toList();

      await _repository.submitBulkAttendance(
        groupSubjectId: selectedGroupSubjectId.value,
        date: selectedDate.value,
        records: records,
      );

      hasUnsavedChanges.value = false;
      showSuccess('Davomat muvaffaqiyatli saqlandi');

      // Clear the form
      attendanceRecords.clear();
      _updateAttendanceStats();
    } catch (e) {
      showError('Davomat saqlanmadi: $e');
    } finally {
      isSavingAttendance.value = false;
    }
  }

  // Load attendance table
  Future<void> loadAttendanceTable() async {
    if (selectedGroupSubjectId.value == 0) {
      showError('Guruh va fanni tanlang');
      return;
    }

    try {
      setLoading(true);
      clearError();

      final data = await _repository.getAttendanceTable(
        groupSubjectId: selectedGroupSubjectId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );

      attendanceTable.value = data;
      tableDates.assignAll((data['dates'] as List<dynamic>? ?? []).map((d) => d.toString()));
      tableStudents.assignAll(data['students'] ?? []);

      print('✅ Loaded attendance table - Dates: ${tableDates.length}, Students: ${tableStudents.length}');
    } catch (e) {
      setError('Davomat jadvali yuklanmadi: $e');
    } finally {
      setLoading(false);
    }
  }

  // Date selection
  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
    // Clear attendance when date changes
    attendanceRecords.clear();
    hasUnsavedChanges.value = false;
    _updateAttendanceStats();
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    if (selectedGroupSubjectId.value != 0) {
      loadAttendanceTable();
    }
  }

  void setGroupSubject(int groupSubjectId) {
    selectedGroupSubjectId.value = groupSubjectId;

    // Find the group ID from groupSubject
    final groupSubject = groupSubjects.firstWhere(
          (gs) => gs['group_subject_id'] == groupSubjectId,
      orElse: () => <String, dynamic>{},
    );

    if (groupSubject.isNotEmpty) {
      final groupId = groupSubject['id'] as int;
      loadStudents(groupId);
    }
  }

  // Update attendance statistics
  void _updateAttendanceStats() {
    final stats = <String, int>{
      AppConstants.attendancePresent: 0,
      AppConstants.attendanceAbsent: 0,
      AppConstants.attendanceLate: 0,
      AppConstants.attendanceExcused: 0,
    };

    for (final status in attendanceRecords.values) {
      stats[status] = (stats[status] ?? 0) + 1;
    }

    attendanceStats.value = stats;
  }

  // Helper methods
  String getAttendanceStatus(int studentId) {
    return attendanceRecords[studentId] ?? '';
  }

  bool hasAttendanceRecord(int studentId) {
    return attendanceRecords.containsKey(studentId);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.attendancePresent:
        return Colors.green;
      case AppConstants.attendanceAbsent:
        return Colors.red;
      case AppConstants.attendanceLate:
        return Colors.orange;
      case AppConstants.attendanceExcused:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case AppConstants.attendancePresent:
        return 'Bor';
      case AppConstants.attendanceAbsent:
        return 'Yo\'q';
      case AppConstants.attendanceLate:
        return 'Kech';
      case AppConstants.attendanceExcused:
        return 'Uzrli';
      default:
        return '';
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case AppConstants.attendancePresent:
        return Icons.check_circle;
      case AppConstants.attendanceAbsent:
        return Icons.cancel;
      case AppConstants.attendanceLate:
        return Icons.access_time;
      case AppConstants.attendanceExcused:
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  // Get attendance for specific student and date from table
  String getTableAttendance(int studentId, String date) {
    final student = tableStudents.firstWhere(
          (s) => s['student_id'] == studentId,
      orElse: () => <String, dynamic>{},
    );

    if (student.isEmpty) return '';

    final attendanceByDate = student['attendance_by_date'] as Map<String, dynamic>? ?? {};
    return attendanceByDate[date]?.toString() ?? '';
  }

  // Get attendance summary for a student
  Map<String, dynamic> getStudentSummary(int studentId) {
    final student = tableStudents.firstWhere(
          (s) => s['student_id'] == studentId,
      orElse: () => <String, dynamic>{},
    );

    return student['summary'] as Map<String, dynamic>? ?? {};
  }

  // Calculate attendance percentage for a student
  double getAttendancePercentage(int studentId) {
    final summary = getStudentSummary(studentId);
    final totalDays = summary['total_days'] as int? ?? 0;
    final presentDays = summary['present'] as int? ?? 0;

    if (totalDays == 0) return 0.0;
    return (presentDays / totalDays) * 100;
  }

  // Check if date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is in the past
  bool isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  // Quick actions
  void markTodayAttendance() {
    if (!isToday(selectedDate.value)) {
      setSelectedDate(DateTime.now());
    }
    isMarkingAttendance.value = true;
  }

  void viewAttendanceHistory() {
    if (selectedGroupSubjectId.value != 0) {
      loadAttendanceTable();
    }
  }

  @override
  Future<void> refreshData() async {
    if (selectedGroupSubjectId.value != 0) {
      await loadAttendanceTable();
    }
  }
}