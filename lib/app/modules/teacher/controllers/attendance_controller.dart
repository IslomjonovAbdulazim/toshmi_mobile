// lib/app/modules/teacher/controllers/attendance_controller.dart
import 'package:get/get.dart';

import '../../../data/repositories/teacher_repository.dart';

class AttendanceController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;
  final attendanceData = <String, dynamic>{}.obs;
  final groupStudents = <dynamic>[].obs;

  Future<void> loadAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      final data = await _teacherRepository.getAttendanceTable(
        groupSubjectId: groupSubjectId,
        startDate: startDate,
        endDate: endDate,
      );
      attendanceData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupStudents(int groupId) async {
    try {
      isLoading.value = true;
      final students = await _teacherRepository.getGroupStudents(groupId);
      groupStudents.value = students;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitBulkAttendance({
    required int groupSubjectId,
    required DateTime date,
    required List<Map<String, dynamic>> records,
  }) async {
    try {
      isLoading.value = true;
      await _teacherRepository.submitBulkAttendance(
        groupSubjectId: groupSubjectId,
        date: date,
        records: records,
      );
      Get.snackbar('Success', 'Attendance recorded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to record attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAttendance(int groupSubjectId) async {
    loadAttendanceTable(groupSubjectId: groupSubjectId);
  }
}
