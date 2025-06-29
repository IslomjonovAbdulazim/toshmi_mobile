// lib/app/modules/teacher/bindings/teacher_binding.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../controllers/teacher_home_controller.dart';
import '../controllers/homework_controller.dart';
import '../controllers/exam_controller.dart';
import '../controllers/grading_controller.dart';
import '../controllers/attendance_controller.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    // Repository - Single instance for all teacher operations
    Get.lazyPut<TeacherRepository>(() => TeacherRepository(), fenix: true);

    // Controllers - Lazy initialization for better performance
    Get.lazyPut<TeacherHomeController>(() => TeacherHomeController());
    Get.lazyPut<HomeworkController>(() => HomeworkController());
    Get.lazyPut<ExamController>(() => ExamController());
    Get.lazyPut<GradingController>(() => GradingController());
    Get.lazyPut<AttendanceController>(() => AttendanceController());
  }
}