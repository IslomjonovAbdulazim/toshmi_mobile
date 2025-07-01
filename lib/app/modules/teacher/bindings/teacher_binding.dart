// lib/app/modules/teacher/bindings/teacher_binding.dart
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/teacher_home_controller.dart';
import '../controllers/homework_controller.dart';
import '../controllers/exam_controller.dart';
import '../controllers/grading_controller.dart';
import '../controllers/attendance_controller.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/group_subject_repository.dart';

class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories first - these are needed by controllers
    Get.lazyPut<TeacherRepository>(() => TeacherRepository(), fenix: true);
    Get.lazyPut<GroupSubjectRepository>(() => GroupSubjectRepository(), fenix: true);

    // Then controllers that depend on repositories
    Get.lazyPut<TeacherHomeController>(() => TeacherHomeController(), fenix: true);
    Get.lazyPut<HomeworkController>(() => HomeworkController(), fenix: true);
    Get.lazyPut<ExamController>(() => ExamController(), fenix: true);
    Get.lazyPut<GradingController>(() => GradingController(), fenix: true);
    Get.lazyPut<AttendanceController>(() => AttendanceController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}