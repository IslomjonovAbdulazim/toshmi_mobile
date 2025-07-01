import 'package:get/get.dart';
import 'package:toshmi_mobile/app/modules/student/bindings/student_binding.dart';
import 'app_routes.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/teacher/bindings/teacher_binding.dart'; // Add this import
import '../modules/teacher/views/home/teacher_home_view.dart';
import '../modules/student/views/student_home_view.dart';
import '../modules/parent/views/parent_home_view.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.teacher,
      page: () => const TeacherHomeView(),
      binding: TeacherBinding(), // Add this line
    ),
    GetPage(
      name: Routes.student,
      page: () =>  StudentHomeView(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: Routes.parent,
      page: () => const ParentHomeView(),
    ),
  ];
}