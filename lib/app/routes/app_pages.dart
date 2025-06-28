import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/teacher/views/teacher_home_view.dart';
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
    ),
    GetPage(
      name: Routes.student,
      page: () => const StudentHomeView(),
    ),
    GetPage(
      name: Routes.parent,
      page: () => const ParentHomeView(),
    ),
  ];
}