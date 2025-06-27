import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    print('🔐 AuthBinding: Setting up authentication dependencies...');

    // Ensure AuthController is available for login/authentication
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
            () => AuthController(),
        fenix: true, // Recreate if removed
      );
      print('✅ AuthBinding: AuthController registered');
    } else {
      print('✅ AuthBinding: AuthController already available');
    }

    print('✅ AuthBinding: Authentication dependencies registered');
  }
}