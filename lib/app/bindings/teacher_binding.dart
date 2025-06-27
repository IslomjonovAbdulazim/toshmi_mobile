import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../../core/constants/api_constants.dart';
import '../../presentation/controllers/notification_controller.dart';
import '../../presentation/controllers/teacher_controller.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/services/api_service.dart';

/// Teacher binding for teacher-related dependencies
///
/// This binding ensures all teacher-related services, repositories, and controllers
/// are properly initialized and injected when needed for teacher users.
class TeacherBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    _ensureCoreDependencies();

    // Initialize teacher-specific dependencies
    _initializeTeacherDependencies();

    print('TeacherBinding: Teacher dependencies initialized');
  }

  void _ensureCoreDependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
  }

  void _initializeTeacherDependencies() {
    // Initialize TeacherRepository - handles teacher data management and caching
    Get.lazyPut<TeacherRepository>(
          () => TeacherRepository(),
      fenix: true,
    );

    // Initialize TeacherController - manages teacher UI state and interactions
    Get.lazyPut<TeacherController>(
          () => TeacherController(),
      fenix: true,
    );

    // Initialize notifications for teachers
    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(
            () => NotificationController(),
        fenix: true,
      );
    }
  }
}

/// Permanent teacher binding for maintaining teacher data across navigation
///
/// Use this when teacher data should remain in memory throughout the app session.
/// This is useful for teachers who navigate between different sections but want
/// to maintain their teaching data (homework, exams, grading, etc.).
class TeacherPermanentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }

    // Initialize teacher services with permanent: true
    Get.put<TeacherRepository>(
      TeacherRepository(),
      permanent: true,
    );

    Get.put<TeacherController>(
      TeacherController(),
      permanent: true,
    );

    Get.put<NotificationController>(
      NotificationController(),
      permanent: true,
    );

    print('TeacherPermanentBinding: Permanent teacher dependencies initialized');
  }
}

/// Lazy teacher binding - initializes only when accessed
///
/// This is the most memory-efficient option as dependencies are only created
/// when actually needed. Good for multi-role apps where teacher functionality
/// might not be used in every session.
class TeacherLazyBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - only created when Get.find() is called
    Get.lazyPut<TeacherRepository>(() => TeacherRepository());
    Get.lazyPut<TeacherController>(() => TeacherController());
    Get.lazyPut<NotificationController>(() => NotificationController());

    print('TeacherLazyBinding: Lazy teacher dependencies registered');
  }
}

/// Smart teacher binding that initializes based on user role
///
/// This binding checks the current user's role and only initializes teacher
/// dependencies if the user is actually a teacher. This optimizes memory usage
/// and prevents unnecessary initialization for other user types.
class TeacherSmartBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // Check if user is a teacher before initializing
      final authController = Get.find<AuthController>();

      if (authController.isTeacher) {
        // User is a teacher, initialize all dependencies
        Get.lazyPut<TeacherRepository>(() => TeacherRepository(), fenix: true);
        Get.lazyPut<TeacherController>(() => TeacherController(), fenix: true);
        Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);

        print('TeacherSmartBinding: Teacher dependencies initialized for teacher user');
      } else {
        print('TeacherSmartBinding: Skipped initialization - user is not a teacher');
      }
    } catch (e) {
      // AuthController not available, fallback to lazy initialization
      print('TeacherSmartBinding: AuthController not found, using fallback lazy initialization');
      Get.lazyPut<TeacherRepository>(() => TeacherRepository());
      Get.lazyPut<TeacherController>(() => TeacherController());
      Get.lazyPut<NotificationController>(() => NotificationController());
    }
  }
}

/// Homework-focused teacher binding
///
/// This binding is optimized for homework management screens,
/// pre-loading homework data and related dependencies.
class TeacherHomeworkBinding extends Bindings {
  @override
  void dependencies() {
    // Standard teacher dependencies
    TeacherBinding().dependencies();

    // Pre-load homework data after dependencies are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadHomeworkData();
    });

    print('TeacherHomeworkBinding: Homework-optimized dependencies initialized');
  }

  void _preloadHomeworkData() {
    try {
      final teacherController = Get.find<TeacherController>();
      // Pre-load homework data
      teacherController.loadHomework();
      print('TeacherHomeworkBinding: Homework data pre-loading initiated');
    } catch (e) {
      print('TeacherHomeworkBinding: Error pre-loading homework data - $e');
    }
  }
}

/// Grading-focused teacher binding
///
/// This binding is optimized for grading screens,
/// pre-loading grading tables and student data.
class TeacherGradingBinding extends Bindings {
  @override
  void dependencies() {
    // Standard teacher dependencies
    TeacherBinding().dependencies();

    // Pre-load grading data after dependencies are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadGradingData();
    });

    print('TeacherGradingBinding: Grading-optimized dependencies initialized');
  }

  void _preloadGradingData() {
    try {
      final teacherController = Get.find<TeacherController>();
      // Pre-load homework and exams for grading
      teacherController.loadHomework();
      teacherController.loadExams();
      print('TeacherGradingBinding: Grading data pre-loading initiated');
    } catch (e) {
      print('TeacherGradingBinding: Error pre-loading grading data - $e');
    }
  }
}

/// Attendance-focused teacher binding
///
/// This binding is optimized for attendance management screens,
/// pre-loading student lists and attendance data.
class TeacherAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Standard teacher dependencies
    TeacherBinding().dependencies();

    // Pre-load attendance data after dependencies are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAttendanceData();
    });

    print('TeacherAttendanceBinding: Attendance-optimized dependencies initialized');
  }

  void _preloadAttendanceData() {
    try {
      final teacherController = Get.find<TeacherController>();
      // Pre-load student data for attendance
      teacherController.loadGroupStudents();
      print('TeacherAttendanceBinding: Attendance data pre-loading initiated');
    } catch (e) {
      print('TeacherAttendanceBinding: Error pre-loading attendance data - $e');
    }
  }
}

/// Exam management teacher binding
///
/// This binding is optimized for exam management screens,
/// pre-loading exam data and related information.
class TeacherExamBinding extends Bindings {
  @override
  void dependencies() {
    // Standard teacher dependencies
    TeacherBinding().dependencies();

    // Pre-load exam data after dependencies are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadExamData();
    });

    print('TeacherExamBinding: Exam-optimized dependencies initialized');
  }

  void _preloadExamData() {
    try {
      final teacherController = Get.find<TeacherController>();
      // Pre-load exam data
      teacherController.loadExams();
      print('TeacherExamBinding: Exam data pre-loading initiated');
    } catch (e) {
      print('TeacherExamBinding: Error pre-loading exam data - $e');
    }
  }
}

/// Utility class for managing teacher dependencies
class TeacherDependencyManager {
  /// Check if teacher dependencies are initialized
  static bool areTeacherDependenciesInitialized() {
    return Get.isRegistered<TeacherController>() &&
        Get.isRegistered<TeacherRepository>();
  }

  /// Initialize teacher dependencies manually
  static void initializeTeacherDependencies({bool permanent = false}) {
    if (permanent) {
      TeacherPermanentBinding().dependencies();
    } else {
      TeacherBinding().dependencies();
    }
  }

  /// Clean up teacher dependencies
  static void cleanupTeacherDependencies() {
    if (Get.isRegistered<TeacherController>()) {
      Get.delete<TeacherController>();
    }
    if (Get.isRegistered<TeacherRepository>()) {
      Get.delete<TeacherRepository>();
    }
    print('TeacherDependencyManager: Teacher dependencies cleaned up');
  }

  /// Reset teacher dependencies (cleanup and reinitialize)
  static void resetTeacherDependencies({bool permanent = false}) {
    cleanupTeacherDependencies();
    initializeTeacherDependencies(permanent: permanent);
    print('TeacherDependencyManager: Teacher dependencies reset');
  }

  /// Get teacher dependency status
  static Map<String, bool> getTeacherDependencyStatus() {
    return {
      'teacherController': Get.isRegistered<TeacherController>(),
      'teacherRepository': Get.isRegistered<TeacherRepository>(),
      'notificationController': Get.isRegistered<NotificationController>(),
      'allInitialized': areTeacherDependenciesInitialized(),
    };
  }

  /// Pre-load teacher data for better UX
  static Future<void> preloadTeacherData() async {
    if (!areTeacherDependenciesInitialized()) {
      print('TeacherDependencyManager: Dependencies not initialized, cannot preload data');
      return;
    }

    try {
      final teacherController = Get.find<TeacherController>();

      // Load essential data in parallel
      await Future.wait([
        teacherController.loadHomework(),
        teacherController.loadExams(),
      ]);

      print('TeacherDependencyManager: Essential teacher data preloaded');
    } catch (e) {
      print('TeacherDependencyManager: Error preloading teacher data - $e');
    }
  }

  /// Refresh all teacher data
  static Future<void> refreshAllTeacherData() async {
    if (!areTeacherDependenciesInitialized()) {
      print('TeacherDependencyManager: Dependencies not initialized, cannot refresh data');
      return;
    }

    try {
      final teacherController = Get.find<TeacherController>();
      await teacherController.refreshAllData();
      print('TeacherDependencyManager: All teacher data refreshed');
    } catch (e) {
      print('TeacherDependencyManager: Error refreshing teacher data - $e');
    }
  }

  /// Check if user is teacher and initialize accordingly
  static void initializeIfTeacher() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isTeacher && !areTeacherDependenciesInitialized()) {
        TeacherBinding().dependencies();
        print('TeacherDependencyManager: Initialized dependencies for teacher user');
      }
    } catch (e) {
      print('TeacherDependencyManager: Error checking teacher role - $e');
    }
  }

  /// Get teacher's assigned groups and subjects
  static Future<List<Map<String, dynamic>>> getTeacherAssignments() async {
    if (!areTeacherDependenciesInitialized()) {
      return [];
    }

    try {
      final teacherController = Get.find<TeacherController>();
      // This would need to be implemented in the controller
      // return await teacherController.getAssignments();
      return [];
    } catch (e) {
      print('TeacherDependencyManager: Error getting teacher assignments - $e');
      return [];
    }
  }
}

/// Teacher navigation helper
class TeacherNavigationHelper {
  /// Navigate to teacher dashboard
  static void toDashboard() {
    Get.toNamed('/teacher/dashboard', binding: TeacherBinding());
  }

  /// Navigate to homework management
  static void toHomework() {
    Get.toNamed('/teacher/homework', binding: TeacherHomeworkBinding());
  }

  /// Navigate to exam management
  static void toExams() {
    Get.toNamed('/teacher/exams', binding: TeacherExamBinding());
  }

  /// Navigate to grading section
  static void toGrading() {
    Get.toNamed('/teacher/grading', binding: TeacherGradingBinding());
  }

  /// Navigate to attendance management
  static void toAttendance() {
    Get.toNamed('/teacher/attendance', binding: TeacherAttendanceBinding());
  }

  /// Navigate to specific homework grading
  static void toHomeworkGrading(int homeworkId) {
    Get.toNamed(
      '/teacher/homework/$homeworkId/grading',
      binding: TeacherGradingBinding(),
      arguments: {'homeworkId': homeworkId},
    );
  }

  /// Navigate to specific exam grading
  static void toExamGrading(int examId) {
    Get.toNamed(
      '/teacher/exam/$examId/grading',
      binding: TeacherGradingBinding(),
      arguments: {'examId': examId},
    );
  }

  /// Navigate to group students
  static void toGroupStudents(int groupId) {
    Get.toNamed(
      '/teacher/group/$groupId/students',
      binding: TeacherBinding(),
      arguments: {'groupId': groupId},
    );
  }
}

/// Teacher action helper for common operations
class TeacherActionHelper {
  /// Quick create homework
  static Future<bool> quickCreateHomework({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
  }) async {
    try {
      if (!TeacherDependencyManager.areTeacherDependenciesInitialized()) {
        TeacherBinding().dependencies();
        // Wait a frame for dependencies to initialize
        await Future.delayed(Duration.zero);
      }

      final teacherController = Get.find<TeacherController>();
      return await teacherController.createHomework(
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        dueDate: dueDate,
        maxPoints: maxPoints,
      );
    } catch (e) {
      print('TeacherActionHelper: Error creating homework - $e');
      return false;
    }
  }

  /// Quick create exam
  static Future<bool> quickCreateExam({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    required int maxPoints,
  }) async {
    try {
      if (!TeacherDependencyManager.areTeacherDependenciesInitialized()) {
        TeacherBinding().dependencies();
        await Future.delayed(Duration.zero);
      }

      final teacherController = Get.find<TeacherController>();
      return await teacherController.createExam(
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        examDate: examDate,
        maxPoints: maxPoints,
      );
    } catch (e) {
      print('TeacherActionHelper: Error creating exam - $e');
      return false;
    }
  }

  /// Quick submit attendance for all students
  static Future<bool> quickSubmitAttendance({
    required int groupSubjectId,
    required DateTime date,
    required Map<int, String> studentAttendance, // studentId -> status
  }) async {
    try {
      if (!TeacherDependencyManager.areTeacherDependenciesInitialized()) {
        TeacherBinding().dependencies();
        await Future.delayed(Duration.zero);
      }

      final teacherController = Get.find<TeacherController>();
      return await teacherController.submitBulkAttendance(
        groupSubjectId: groupSubjectId,
        date: date,
        attendance: studentAttendance,
      );
    } catch (e) {
      print('TeacherActionHelper: Error submitting attendance - $e');
      return false;
    }
  }
}