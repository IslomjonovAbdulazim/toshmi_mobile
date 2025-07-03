// lib/app/modules/parent/bindings/parent_binding.dart
import 'package:get/get.dart';
import '../controllers/parent_controller.dart';
import '../../../data/repositories/parent_repository.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<ParentRepository>(() => ParentRepository());

    // Controller
    Get.lazyPut<ParentController>(() => ParentController());
  }
}