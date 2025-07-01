// lib/app/modules/teacher/controllers/attendance_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/models/group_subject_model.dart';

class AttendanceController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository = GroupSubjectRepository();

  final isLoading = false.obs;
  final attendanceData = <String, dynamic>{}.obs;
  final groupStudents = <dynamic>[].obs;

  // NEW: Group subjects and schedules
  final groupSubjects = <GroupSubject>[].obs;
  final schedules = <TeacherSchedule>[].obs;
  final selectedGroupSubject = Rx<GroupSubject?>(null);
  final selectedSchedule = Rx<TeacherSchedule?>(null);

  @override
  void onInit() {
    super.onInit();
    loadGroupSubjects();
  }

  // Load teacher's group subjects (classes they teach)
  Future<void> loadGroupSubjects() async {
    try {
      isLoading.value = true;
      print('🔄 Loading group subjects...');
      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();
      print('✅ Loaded ${subjects.length} group subjects');
      groupSubjects.value = subjects;

      // Debug: Print the subjects
      for (final subject in subjects) {
        print('📚 Subject: ${subject.subjectName} - Group: ${subject.groupName}');
      }
    } catch (e) {
      print('❌ Error loading group subjects: $e');
      Get.snackbar('Error', 'Failed to load classes: $e');
      groupSubjects.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Load schedule for selected group subject
  Future<void> loadSchedule(GroupSubject groupSubject) async {
    try {
      isLoading.value = true;
      print('🔄 Loading schedule for group subject: ${groupSubject.id}');
      selectedGroupSubject.value = groupSubject;
      final scheduleList = await _groupSubjectRepository.getGroupSubjectSchedule(groupSubject.id);
      print('✅ Loaded ${scheduleList.length} schedules');
      schedules.value = scheduleList;
      selectedSchedule.value = null; // Reset selected schedule

      // Debug: Print the schedules
      for (final schedule in scheduleList) {
        print('⏰ Schedule: ${schedule.dayName} ${schedule.timeRange} - Room: ${schedule.room}');
      }
    } catch (e) {
      print('❌ Error loading schedule: $e');
      Get.snackbar('Error', 'Failed to load schedule: $e');
      schedules.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Select a specific schedule time
  void selectSchedule(TeacherSchedule schedule) {
    selectedSchedule.value = schedule;
    print('✅ Selected schedule: ${schedule.dayName} ${schedule.timeRange}');
  }

  // Get display name for group subject
  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  // Get display name for schedule
  String getScheduleDisplayName(TeacherSchedule schedule) {
    return _groupSubjectRepository.getScheduleDisplayName(schedule);
  }

  // Check if schedule is currently active
  bool isScheduleActive(TeacherSchedule schedule) {
    return _groupSubjectRepository.isScheduleActive(schedule);
  }

  // EXISTING METHODS (keep as they are)
  Future<void> loadAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      print('🔄 Loading attendance table for group subject: $groupSubjectId');
      final data = await _teacherRepository.getAttendanceTable(
        groupSubjectId: groupSubjectId,
        startDate: startDate,
        endDate: endDate,
      );
      attendanceData.value = data;
      print('✅ Loaded attendance data');
    } catch (e) {
      print('❌ Error loading attendance: $e');
      Get.snackbar('Error', 'Failed to load attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupStudents(int groupId) async {
    try {
      isLoading.value = true;
      print('🔄 Loading students for group: $groupId');
      final students = await _teacherRepository.getGroupStudents(groupId);
      groupStudents.value = students;
      print('✅ Loaded ${students.length} students');

      // Debug: Print students
      for (final student in students) {
        print('👨‍🎓 Student: ${student['name']} - ID: ${student['id']}');
      }
    } catch (e) {
      print('❌ Error loading students: $e');
      Get.snackbar('Error', 'Failed to load students: $e');
      groupStudents.value = [];
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
      print('🔄 Submitting attendance for ${records.length} students');
      await _teacherRepository.submitBulkAttendance(
        groupSubjectId: groupSubjectId,
        date: date,
        records: records,
      );
      print('✅ Attendance submitted successfully');
      Get.snackbar('Success', 'Attendance recorded successfully');
    } catch (e) {
      print('❌ Error submitting attendance: $e');
      Get.snackbar('Error', 'Failed to record attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAttendance(int groupSubjectId) async {
    loadAttendanceTable(groupSubjectId: groupSubjectId);
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await loadGroupSubjects();
    if (selectedGroupSubject.value != null) {
      await loadSchedule(selectedGroupSubject.value!);
    }
  }
}