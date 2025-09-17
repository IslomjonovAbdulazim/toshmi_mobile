import 'package:get/get.dart';
import '../controllers/exam_media_controller.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../services/file_service.dart';

class ExamMediaBinding extends Bindings {
  @override
  void dependencies() {
    // Register dependencies needed by ExamMediaController
    Get.lazyPut<StudentRepository>(() => StudentRepository());
    Get.lazyPut<FileService>(() => FileService());
    Get.lazyPut<ExamMediaController>(
      () => ExamMediaController(),
    );
  }
}