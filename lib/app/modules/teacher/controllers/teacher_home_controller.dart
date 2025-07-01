import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';

class TeacherHomeController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;

  final totalHomework = 0.obs;
  final totalExams = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

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

  Future<void> loadHomeworkCount() async {
    try {
      final homework = await _teacherRepository.getHomeworkList();
      totalHomework.value = homework.length;
    } catch (e) {
      totalHomework.value = 0;
    }
  }

  Future<void> loadExamCount() async {
    try {
      final exams = await _teacherRepository.getExamsList();
      totalExams.value = exams.length;
    } catch (e) {
      totalExams.value = 0;
    }
  }

  Future<void> refreshDashboard() async {
    await loadAllData();
  }
}