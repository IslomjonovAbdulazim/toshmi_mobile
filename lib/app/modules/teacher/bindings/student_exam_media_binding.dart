import 'package:get/get.dart';
import '../controllers/student_exam_media_controller.dart';
import '../../../data/repositories/teacher_repository.dart';

class StudentExamMediaBinding extends Bindings {
  @override
  void dependencies() {
    // Register dependencies needed by StudentExamMediaController
    Get.lazyPut<TeacherRepository>(() => TeacherRepository());
    Get.lazyPut<StudentExamMediaController>(
      () => StudentExamMediaController(),
    );
  }
}