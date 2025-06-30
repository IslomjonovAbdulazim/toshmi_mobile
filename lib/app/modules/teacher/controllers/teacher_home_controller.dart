// lib/app/modules/teacher/controllers/teacher_home_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';

class TeacherHomeController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();

  final isLoading = false.obs;
  final dashboardData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final data = await _teacherRepository.getDashboardData();
      dashboardData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() => loadDashboard();
}