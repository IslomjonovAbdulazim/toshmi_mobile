import 'package:get/get.dart';
import '../../../data/repositories/student_repository.dart';

class StudentController extends GetxController {
  final StudentRepository _repository = Get.find<StudentRepository>();

  final isLoading = false.obs;
  final dashboardData = <String, dynamic>{}.obs;
  final homework = <dynamic>[].obs;
  final exams = <dynamic>[].obs;
  final grades = <String, dynamic>{}.obs;
  final attendance = <dynamic>[].obs;
  final schedule = <dynamic>[].obs;
  final payments = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final data = await _repository.getComprehensiveDashboard();
      dashboardData.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHomework() async {
    try {
      final data = await _repository.getHomework();
      homework.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load homework: $e');
    }
  }

  Future<void> loadExams() async {
    try {
      final data = await _repository.getExams();
      exams.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load exams: $e');
    }
  }

  Future<void> loadGrades() async {
    try {
      final data = await _repository.getGrades();
      grades.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load grades: $e');
    }
  }

  Future<void> loadAttendance() async {
    try {
      final data = await _repository.getAttendance();
      attendance.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load attendance: $e');
    }
  }

  Future<void> loadSchedule() async {
    try {
      final data = await _repository.getSchedule();
      schedule.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load schedule: $e');
    }
  }

  Future<void> loadPayments() async {
    try {
      final data = await _repository.getPayments();
      payments.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load payments: $e');
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadHomework(),
      loadExams(),
      loadGrades(),
      loadAttendance(),
      loadSchedule(),
      loadPayments(),
    ]);
  }
}