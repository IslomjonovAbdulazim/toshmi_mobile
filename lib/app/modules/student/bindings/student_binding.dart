import 'package:get/get.dart';
import '../../../data/repositories/student_repository.dart';
import '../controllers/student_controller.dart';

class StudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentRepository>(() => StudentRepository());
    Get.lazyPut<StudentController>(() => StudentController());
  }
}