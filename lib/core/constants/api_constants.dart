class ApiConstants {
  // Base Configuration
  static const String baseUrl = 'https://islomjonovabdulazim-toshmi-backend-0914.twc1.net';
  static const String apiVersion = 'v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Helper Methods
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';

  static Map<String, String> buildHeaders({String? token}) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> buildPaginationParams({int? skip, int? limit}) {
    return {
      if (skip != null) 'skip': skip.toString(),
      if (limit != null) 'limit': limit.toString(),
    };
  }

  static Map<String, dynamic> buildDateRangeParams({DateTime? startDate, DateTime? endDate}) {
    return {
      if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
    };
  }
}

// Authentication Endpoints
abstract class AuthEndpoints {
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String notifications = '/auth/notifications';
  static String notificationRead(int id) => '/auth/notifications/$id/read';
  static const String markAllNotificationsRead = '/auth/notifications/mark-all-read';
  static const String unreadNotificationCount = '/auth/notifications/unread-count';
}

// Student Endpoints
abstract class StudentEndpoints {
  static const String homework = '/student/homework';
  static const String exams = '/student/exams';
  static const String grades = '/student/grades';
  static const String attendance = '/student/attendance';
  static const String schedule = '/student/schedule';
  static const String payments = '/student/payments';
  static const String dashboard = '/student/dashboard';
}

// Teacher Endpoints
abstract class TeacherEndpoints {
  // Homework Management
  static const String homework = '/teacher/homework';
  static String homeworkById(int id) => '/teacher/homework/$id';
  static String homeworkGradingTable(int id) => '/teacher/homework/$id/grading-table';

  // Exam Management
  static const String exams = '/teacher/exams';
  static String examById(int id) => '/teacher/exams/$id';
  static String examGradingTable(int id) => '/teacher/exams/$id/grading-table';

  // Grading
  static const String bulkHomeworkGrades = '/teacher/bulk-homework-grades';
  static const String bulkExamGrades = '/teacher/bulk-exam-grades';

  // Attendance
  static const String bulkAttendance = '/teacher/bulk-attendance';
  static const String attendanceTable = '/teacher/attendance-table';

  // Groups & Students
  static String groupStudents(int groupId) => '/teacher/groups/$groupId/students';
}

// Parent Endpoints
abstract class ParentEndpoints {
  static const String children = '/parent/children';
  static const String dashboard = '/parent/dashboard';

  // Child-specific endpoints
  static String childHomework(int childId) => '/parent/children/$childId/homework';
  static String childGrades(int childId) => '/parent/children/$childId/grades';
  static String childAttendance(int childId) => '/parent/children/$childId/attendance';
  static String childPayments(int childId) => '/parent/children/$childId/payments';
}

// File Management Endpoints
abstract class FileEndpoints {
  static const String profilePicture = '/files/profile-picture';
  static String homeworkUpload(int homeworkId) => '/files/homework/$homeworkId/upload';
  static String examUpload(int examId) => '/files/exam/$examId/upload';
  static String newsImageUpload(int newsId) => '/files/news/$newsId/upload-image';
  static String download(int fileId) => '/files/$fileId';
  static String delete(int fileId) => '/files/$fileId';
}

// Public/System Endpoints
abstract class PublicEndpoints {
  static const String root = '/';
  static const String health = '/health';
  static const String stats = '/stats';
  static const String news = '/news';
}

// Query Parameters
abstract class QueryParams {
  // Pagination
  static const String skip = 'skip';
  static const String limit = 'limit';

  // Date filters
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';

  // Filters
  static const String studentId = 'student_id';
  static const String paymentMethod = 'payment_method';
  static const String groupSubjectId = 'group_subject_id';
}

// HTTP Status Codes
abstract class StatusCodes {
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  static const int serviceUnavailable = 503;
}

// Error Messages
abstract class ErrorMessages {
  static const String networkError = 'Internet aloqasi yo\'q';
  static const String serverError = 'Server xatosi yuz berdi';
  static const String unauthorizedAccess = 'Ruxsat berilmagan kirish';
  static const String invalidCredentials = 'Telefon raqam yoki parol noto\'g\'ri';
  static const String sessionExpired = 'Sessiya muddati tugadi, qayta kiring';
  static const String fileUploadFailed = 'Fayl yuklashda xatolik';
  static const String permissionDenied = 'Ruxsat rad etildi';
  static const String dataNotFound = 'Ma\'lumot topilmadi';
  static const String validationError = 'Noto\'g\'ri ma\'lumot kiritildi';
  static const String connectionTimeout = 'Ulanish vaqti tugadi';
}

// File Upload Constants
abstract class FileUpload {
  static const int maxImageSize = 3 * 1024 * 1024; // 3MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'];
}

// Cache Keys
abstract class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String userToken = 'user_token';
  static const String userRole = 'user_role';
  static const String notifications = 'notifications';
  static const String studentHomework = 'student_homework';
  static const String studentExams = 'student_exams';
  static const String studentGrades = 'student_grades';
  static const String teacherHomework = 'teacher_homework';
  static const String teacherExams = 'teacher_exams';
  static const String parentChildren = 'parent_children';
  static const String appTheme = 'app_theme';
  static const String appLanguage = 'app_language';
}

// Request Types
abstract class RequestTypes {
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String delete = 'DELETE';
  static const String patch = 'PATCH';
}

// Content Types
abstract class ContentTypes {
  static const String json = 'application/json';
  static const String formData = 'multipart/form-data';
  static const String urlEncoded = 'application/x-www-form-urlencoded';
}

// User Roles
abstract class UserRoles {
  static const String admin = 'admin';
  static const String teacher = 'teacher';
  static const String student = 'student';
  static const String parent = 'parent';
}

// Attendance Status
abstract class AttendanceStatus {
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';
  static const String excused = 'excused';
}

// Payment Methods
abstract class PaymentMethods {
  static const String cash = 'cash';
  static const String card = 'card';
  static const String transfer = 'transfer';
  static const String online = 'online';
}

// Notification Types
abstract class NotificationTypes {
  static const String homework = 'homework';
  static const String exam = 'exam';
  static const String grade = 'grade';
  static const String attendance = 'attendance';
  static const String payment = 'payment';
  static const String general = 'general';
}

// Days of Week
abstract class DaysOfWeek {
  static const int monday = 0;
  static const int tuesday = 1;
  static const int wednesday = 2;
  static const int thursday = 3;
  static const int friday = 4;
  static const int saturday = 5;
  static const int sunday = 6;

  static const List<String> dayNames = [
    'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba',
    'Juma', 'Shanba', 'Yakshanba'
  ];
}

// Pagination Defaults
abstract class Pagination {
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
  static const int defaultSkip = 0;
}