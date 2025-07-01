// lib/app/modules/teacher/controllers/teacher_home_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';

class TeacherHomeController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;

  // Only homework and exam data
  final totalHomework = 0.obs;
  final totalExams = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  // Load homework and exam data only
  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadHomeworkCount(),
        loadExamCount(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // Get homework count from backend
  Future<void> loadHomeworkCount() async {
    try {
      final homework = await _teacherRepository.getHomeworkList();
      totalHomework.value = homework.length;
    } catch (e) {
      totalHomework.value = 0;
      print('Vazifalar yuklanmadi: $e'); // Uzbek: Failed to load homework
    }
  }

  // Get exam count from backend
  Future<void> loadExamCount() async {
    try {
      final exams = await _teacherRepository.getExamsList();
      totalExams.value = exams.length;
    } catch (e) {
      totalExams.value = 0;
      print('Imtihonlar yuklanmadi: $e'); // Uzbek: Failed to load exams
    }
  }

  // Refresh all data
  Future<void> refreshDashboard() async {
    await loadAllData();
  }
}