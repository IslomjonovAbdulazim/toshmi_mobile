import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../../core/constants/api_constants.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/services/api_service.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/notification_controller.dart';
import '../../presentation/controllers/student_controller.dart';

/// Student binding for student-related dependencies
///
/// This binding ensures all student-related services, repositories, and controllers
/// are properly initialized and injected when needed for student users.
class StudentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    _ensureCoreDependencies();

    // Initialize student-specific dependencies
    _initializeStudentDependencies();

    print('StudentBinding: Student dependencies initialized');
  }

  void _ensureCoreDependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
  }

  void _initializeStudentDependencies() {
    // Initialize StudentRepository - handles student data management and caching
    Get.lazyPut<StudentRepository>(
          () => StudentRepository(),
      fenix: true,
    );

    // Initialize StudentController - manages student UI state and interactions
    Get.lazyPut<StudentController>(
          () => StudentController(),
      fenix: true,
    );

    // Initialize notifications for students
    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(
            () => NotificationController(),
        fenix: true,
      );
    }
  }
}

/// Permanent student binding for maintaining student data across navigation
///
/// Use this when student data should remain in memory throughout the app session.
/// This is useful for students who navigate between different sections but want
/// to maintain their academic data (homework, grades, schedule, etc.).
class StudentPermanentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Initialize student services with permanent: true
    Get.put<StudentRepository>(
      StudentRepository(),
      permanent: true,
    );

    Get.put<StudentController>(
      StudentController(),
      permanent: true,
    );

    Get.put<NotificationController>(
      NotificationController(),
      permanent: true,
    );

    print('StudentPermanentBinding: Permanent student dependencies initialized');
  }
}

/// Lazy student binding - initializes only when accessed
///
/// This is the most memory-efficient option as dependencies are only created
/// when actually needed. Good for multi-role apps where student functionality
/// might not be used in every session.
class StudentLazyBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - only created when Get.find() is called
    Get.lazyPut<StudentRepository>(() => StudentRepository());
    Get.lazyPut<StudentController>(() => StudentController());
    Get.lazyPut<NotificationController>(() => NotificationController());

    print('StudentLazyBinding: Lazy student dependencies registered');
  }
}

/// Smart student binding that initializes based on user role
///
/// This binding checks the current user's role and only initializes student
/// dependencies if the user is actually a student. This optimizes memory usage
/// and prevents unnecessary initialization for other user types.
class StudentSmartBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // Check if user is a student before initializing
      final authController = Get.find<AuthController>();

      if (authController.isStudent) {
        // User is a student, initialize all dependencies
        Get.lazyPut<StudentRepository>(() => StudentRepository(), fenix: true);
        Get.lazyPut<StudentController>(() => StudentController(), fenix: true);
        Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);

        print('StudentSmartBinding: Student dependencies initialized for student user');
      } else {
        print('StudentSmartBinding: Skipped initialization - user is not a student');
      }
    } catch (e) {
      // AuthController not available, fallback to lazy initialization
      print('StudentSmartBinding: AuthController not found, using fallback lazy initialization');
      Get.lazyPut<StudentRepository>(() => StudentRepository());
      Get.lazyPut<StudentController>(() => StudentController());
      Get.lazyPut<NotificationController>(() => NotificationController());
    }
  }
}

/// Dashboard-focused student binding
///
/// This binding is optimized for student dashboard screens, pre-loading
/// essential data and ensuring smooth dashboard experience.
class StudentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Standard student dependencies
    StudentBinding().dependencies();

    // Pre-load dashboard data after dependencies are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadDashboardData();
    });

    print('StudentDashboardBinding: Dashboard-optimized dependencies initialized');
  }

  void _preloadDashboardData() {
    try {
      final studentController = Get.find<StudentController>();
      // Pre-load essential dashboard data
      studentController.loadDashboard();
      studentController.loadHomework();
      studentController.loadSchedule();
      print('StudentDashboardBinding: Dashboard data pre-loading initiated');
    } catch (e) {
      print('StudentDashboardBinding: Error pre-loading dashboard data - $e');
    }
  }
}

/// Academic-focused student binding
///
/// This binding is optimized for academic screens (homework, exams, grades)
/// and includes pre-loading of academic data.
class StudentAcademicBinding extends Bindings {
  @override
  void dependencies() {
    // Standard student dependencies
    StudentBinding().dependencies();

    // Pre-load academic data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAcademicData();
    });

    print('StudentAcademicBinding: Academic-optimized dependencies initialized');
  }

  void _preloadAcademicData() {
    try {
      final studentController = Get.find<StudentController>();
      // Pre-load academic data
      studentController.loadHomework();
      studentController.loadExams();
      studentController.loadGrades();
      print('StudentAcademicBinding: Academic data pre-loading initiated');
    } catch (e) {
      print('StudentAcademicBinding: Error pre-loading academic data - $e');
    }
  }
}

/// Utility class for managing student dependencies
class StudentDependencyManager {
  /// Check if student dependencies are initialized
  static bool areStudentDependenciesInitialized() {
    return Get.isRegistered<StudentController>() &&
        Get.isRegistered<StudentRepository>();
  }

  /// Initialize student dependencies manually
  static void initializeStudentDependencies({bool permanent = false}) {
    if (permanent) {
      StudentPermanentBinding().dependencies();
    } else {
      StudentBinding().dependencies();
    }
  }

  /// Clean up student dependencies
  static void cleanupStudentDependencies() {
    if (Get.isRegistered<StudentController>()) {
      Get.delete<StudentController>();
    }
    if (Get.isRegistered<StudentRepository>()) {
      Get.delete<StudentRepository>();
    }
    print('StudentDependencyManager: Student dependencies cleaned up');
  }

  /// Reset student dependencies (cleanup and reinitialize)
  static void resetStudentDependencies({bool permanent = false}) {
    cleanupStudentDependencies();
    initializeStudentDependencies(permanent: permanent);
    print('StudentDependencyManager: Student dependencies reset');
  }

  /// Get student dependency status
  static Map<String, bool> getStudentDependencyStatus() {
    return {
      'studentController': Get.isRegistered<StudentController>(),
      'studentRepository': Get.isRegistered<StudentRepository>(),
      'notificationController': Get.isRegistered<NotificationController>(),
      'allInitialized': areStudentDependenciesInitialized(),
    };
  }

  /// Pre-load student data for better UX
  static Future<void> preloadStudentData() async {
    if (!areStudentDependenciesInitialized()) {
      print('StudentDependencyManager: Dependencies not initialized, cannot preload data');
      return;
    }

    try {
      final studentController = Get.find<StudentController>();

      // Load essential data in parallel
      await Future.wait([
        studentController.loadDashboard(),
        studentController.loadHomework(),
        studentController.loadSchedule(),
      ]);

      print('StudentDependencyManager: Essential student data preloaded');
    } catch (e) {
      print('StudentDependencyManager: Error preloading student data - $e');
    }
  }

  /// Refresh all student data
  static Future<void> refreshAllStudentData() async {
    if (!areStudentDependenciesInitialized()) {
      print('StudentDependencyManager: Dependencies not initialized, cannot refresh data');
      return;
    }

    try {
      final studentController = Get.find<StudentController>();
      await studentController.refreshAllData();
      print('StudentDependencyManager: All student data refreshed');
    } catch (e) {
      print('StudentDependencyManager: Error refreshing student data - $e');
    }
  }

  /// Check if user is student and initialize accordingly
  static void initializeIfStudent() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isStudent && !areStudentDependenciesInitialized()) {
        StudentBinding().dependencies();
        print('StudentDependencyManager: Initialized dependencies for student user');
      }
    } catch (e) {
      print('StudentDependencyManager: Error checking student role - $e');
    }
  }
}
//
// /// Student navigation helper
// class StudentNavigationHelper {
//   /// Navigate to student dashboard
//   static void toDashboard() {
//     Get.toNamed('/student/dashboard', binding: StudentDashboardBinding());
//   }
//
//   /// Navigate to homework section
//   static void toHomework() {
//     Get.toNamed('/student/homework', binding: StudentAcademicBinding());
//   }
//
//   /// Navigate to exams section
//   static void toExams() {
//     Get.toNamed('/student/exams', binding: StudentAcademicBinding());
//   }
//
//   /// Navigate to grades section
//   static void toGrades() {
//     Get.toNamed('/student/grades', binding: StudentAcademicBinding());
//   }
//
//   /// Navigate to schedule section
//   static void toSchedule() {
//     Get.toNamed('/student/schedule', binding: StudentBinding());
//   }
//
//   /// Navigate to payments section
//   static void toPayments() {
//     Get.toNamed('/student/payments', binding: StudentBinding());
//   }
// }