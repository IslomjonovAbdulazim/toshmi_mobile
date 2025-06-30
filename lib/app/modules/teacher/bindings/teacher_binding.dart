// lib/app/modules/teacher/bindings/teacher_binding.dart
import 'package:get/get.dart';
import '../controllers/teacher_home_controller.dart';
import '../controllers/homework_controller.dart';
import '../controllers/exam_controller.dart';
import '../controllers/grading_controller.dart';
import '../controllers/attendance_controller.dart';
import '../../../data/repositories/teacher_repository.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories first
    Get.lazyPut<TeacherRepository>(() => TeacherRepository());

    // Then controllers that depend on repositories
    Get.lazyPut<TeacherHomeController>(() => TeacherHomeController());
    Get.lazyPut<HomeworkController>(() => HomeworkController());
    Get.lazyPut<ExamController>(() => ExamController());
    Get.lazyPut<GradingController>(() => GradingController());
    Get.lazyPut<AttendanceController>(() => AttendanceController());
  }
}