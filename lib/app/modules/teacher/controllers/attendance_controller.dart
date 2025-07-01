// lib/app/modules/teacher/controllers/attendance_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/models/group_subject_model.dart';

class AttendanceController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository = GroupSubjectRepository();

  final isLoading = false.obs;
  final isLoadingAttendance = false.obs;
  final isLoadingStudents = false.obs;
  final attendanceData = <String, dynamic>{}.obs;
  final groupStudents = <dynamic>[].obs;

  final groupSubjects = <GroupSubject>[].obs;
  final schedules = <TeacherSchedule>[].obs;
  final selectedGroupSubject = Rx<GroupSubject?>(null);
  final selectedSchedule = Rx<TeacherSchedule?>(null);

  @override
  void onInit() {
    super.onInit();
    loadGroupSubjects();
  }

  @override
  void onReady() {
    super.onReady();
    if (selectedGroupSubject.value != null) {
      refreshAttendanceData();
    }
  }

  void onViewResumed() {
    if (selectedGroupSubject.value != null) {
      refreshAttendanceData();
    }
  }

  Future<void> loadGroupSubjects() async {
    try {
      isLoading.value = true;
      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();
      groupSubjects.value = subjects;
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_to_load_classes'.tr}: $e');
      groupSubjects.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSchedule(GroupSubject groupSubject) async {
    try {
      isLoading.value = true;
      selectedGroupSubject.value = groupSubject;
      final scheduleList = await _groupSubjectRepository.getGroupSubjectSchedule(groupSubject.id);
      schedules.value = scheduleList;
      selectedSchedule.value = null;
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_to_load_classes'.tr}: $e');
      schedules.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void selectSchedule(TeacherSchedule schedule) {
    selectedSchedule.value = schedule;
  }

  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  String getScheduleDisplayName(TeacherSchedule schedule) {
    return _groupSubjectRepository.getScheduleDisplayName(schedule);
  }

  bool isScheduleActive(TeacherSchedule schedule) {
    return _groupSubjectRepository.isScheduleActive(schedule);
  }

  Future<void> loadAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoadingAttendance.value = true;
      final data = await _teacherRepository.getAttendanceTable(
        groupSubjectId: groupSubjectId,
        startDate: startDate,
        endDate: endDate,
      );
      attendanceData.value = data;
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_to_load_attendance'.tr}: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  Future<void> loadGroupStudents(int groupId) async {
    try {
      isLoadingStudents.value = true;
      final students = await _teacherRepository.getGroupStudents(groupId);
      groupStudents.value = students;
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_to_load_students'.tr}: $e');
      groupStudents.value = [];
    } finally {
      isLoadingStudents.value = false;
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
      Get.snackbar('success'.tr, 'attendance_recorded_successfully'.tr);
      await refreshAttendanceData();
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_to_record_attendance'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAttendanceData() async {
    if (selectedGroupSubject.value != null) {
      await loadAttendanceTable(groupSubjectId: selectedGroupSubject.value!.id);
    }
  }

  Future<void> refreshAttendance(int groupSubjectId) async {
    await loadAttendanceTable(groupSubjectId: groupSubjectId);
  }

  Future<void> refreshAll() async {
    await loadGroupSubjects();
    if (selectedGroupSubject.value != null) {
      await loadSchedule(selectedGroupSubject.value!);
      await refreshAttendanceData();
    }
  }

  void clearAttendanceData() {
    attendanceData.clear();
    groupStudents.clear();
  }

  Future<void> selectGroupSubject(GroupSubject groupSubject) async {
    if (selectedGroupSubject.value?.id != groupSubject.id) {
      clearAttendanceData();
      selectedGroupSubject.value = groupSubject;
      await loadAttendanceTable(groupSubjectId: groupSubject.id);
    }
  }
}