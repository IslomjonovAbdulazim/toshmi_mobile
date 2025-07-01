// lib/app/modules/teacher/controllers/teacher_home_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/models/group_subject_model.dart';

class TeacherHomeController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository = GroupSubjectRepository();

  final isLoading = false.obs;

  // ONLY REAL BACKEND DATA - NO MOCK DATA
  final groupSubjects = <GroupSubject>[].obs;
  final todaySchedules = <TeacherSchedule>[].obs;
  final totalClasses = 0.obs;
  final totalHomework = 0.obs;
  final totalExams = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllRealData();
  }

  // Load ALL data from real backend endpoints - NO MOCK DATA
  Future<void> loadAllRealData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadGroupSubjects(),
        loadHomeworkCount(),
        loadExamCount(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // Get real teacher's group subjects from backend
  Future<void> loadGroupSubjects() async {
    try {
      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();
      groupSubjects.value = subjects;
      totalClasses.value = subjects.length;

      // Load today's schedules for all subjects from backend
      List<TeacherSchedule> allSchedules = [];
      for (final subject in subjects) {
        try {
          final schedules = await _groupSubjectRepository.getGroupSubjectSchedule(subject.id);
          final todayScheduleList = _groupSubjectRepository.getTodaySchedules(schedules);
          allSchedules.addAll(todayScheduleList);
        } catch (e) {
          // Continue if one subject fails
        }
      }

      // Sort by start time
      allSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      todaySchedules.value = allSchedules;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load classes: $e');
      groupSubjects.value = [];
      totalClasses.value = 0;
      todaySchedules.value = [];
    }
  }

  // Get real homework count from backend
  Future<void> loadHomeworkCount() async {
    try {
      final homework = await _teacherRepository.getHomeworkList();
      totalHomework.value = homework.length;
    } catch (e) {
      totalHomework.value = 0;
    }
  }

  // Get real exam count from backend
  Future<void> loadExamCount() async {
    try {
      final exams = await _teacherRepository.getExamsList();
      totalExams.value = exams.length;
    } catch (e) {
      totalExams.value = 0;
    }
  }

  // Helper methods using real data
  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  String getScheduleDisplayName(TeacherSchedule schedule) {
    return _groupSubjectRepository.getScheduleDisplayName(schedule);
  }

  bool isScheduleActive(TeacherSchedule schedule) {
    return _groupSubjectRepository.isScheduleActive(schedule);
  }

  // Refresh all real data
  Future<void> refreshDashboard() async {
    await loadAllRealData();
  }
}