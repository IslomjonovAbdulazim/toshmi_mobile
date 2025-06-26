import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../data/services/student_service.dart';
import '../../data/services/teacher_service.dart';
import '../../data/services/parent_service.dart';
import '../../data/services/file_service.dart';
import '../../data/services/notification_service.dart';
import '../../presentation/controllers/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    print('AppBindings: Initializing core dependencies');

    // Core API Service - Must be first
    Get.put<ApiService>(
      ApiService(),
      permanent: true,
    );

    // Auth Controller - Must be early for middleware
    // Get.put<AuthController>(
    //   AuthController(),
    //   permanent: true,
    // );

    // Core Services - Permanent throughout app lifecycle
    Get.put<FileService>(
      FileService(),
      permanent: true,
    );

    Get.put<NotificationService>(
      NotificationService(),
      permanent: true,
    );

    // Data Services - Lazy loaded, will initialize when first accessed
    Get.lazyPut<StudentService>(
          () => StudentService(),
      fenix: true, // Will recreate if disposed
    );

    Get.lazyPut<TeacherService>(
          () => TeacherService(),
      fenix: true,
    );

    Get.lazyPut<ParentService>(
          () => ParentService(),
      fenix: true,
    );

    print('AppBindings: Core dependencies initialized successfully');
  }
}