// lib/app/modules/teacher/bindings/teacher_binding.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/homework_repository.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../data/repositories/grade_repository.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../controllers/teacher_home_controller.dart';
import '../controllers/homework_controller.dart';
import '../controllers/exam_controller.dart';
import '../controllers/grading_controller.dart';
import '../controllers/attendance_controller.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<TeacherRepository>(() => TeacherRepository());
    Get.lazyPut<HomeworkRepository>(() => HomeworkRepository());
    Get.lazyPut<ExamRepository>(() => ExamRepository());
    Get.lazyPut<GradeRepository>(() => GradeRepository());
    Get.lazyPut<AttendanceRepository>(() => AttendanceRepository());

    // Controllers
    Get.lazyPut<TeacherHomeController>(() => TeacherHomeController());
    Get.lazyPut<HomeworkController>(() => HomeworkController());
    Get.lazyPut<ExamController>(() => ExamController());
    Get.lazyPut<GradingController>(() => GradingController());
    Get.lazyPut<AttendanceController>(() => AttendanceController());
  }
}