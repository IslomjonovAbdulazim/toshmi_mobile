// Authentication Endpoints
abstract class AuthEndpoints {
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/auth/logout';
}

// Student Endpoints
abstract class StudentEndpoints {
  static const String homework = '/student/homework';
  static const String exams = '/student/exams';
  static const String grades = '/student/grades';
  static const String attendance = '/student/attendance';
  static const String schedule = '/student/schedule';
  static const String payments = '/student/payments';
}

// Teacher Endpoints
abstract class TeacherEndpoints {
  static const String homework = '/teacher/homework';
  static const String exams = '/teacher/exams';
  static const String groups = '/teacher/groups';
  static const String attendance = '/teacher/attendance';
  static const String grades = '/teacher/grades';

  static String homeworkById(int id) => '/teacher/homework/$id';
  static String examById(int id) => '/teacher/exams/$id';
  static String groupStudents(int groupId) => '/teacher/groups/$groupId/students';
}

// Parent Endpoints
abstract class ParentEndpoints {
  static const String children = '/parent/children';
  static const String dashboard = '/parent/dashboard';

  static String childHomework(int childId) => '/parent/children/$childId/homework';
  static String childGrades(int childId) => '/parent/children/$childId/grades';
  static String childAttendance(int childId) => '/parent/children/$childId/attendance';
  static String childPayments(int childId) => '/parent/children/$childId/payments';
}

// File Endpoints
abstract class FileEndpoints {
  static const String profilePicture = '/files/profile-picture';
  static String homeworkUpload(int homeworkId) => '/files/homework/$homeworkId/upload';
  static String examUpload(int examId) => '/files/exam/$examId/upload';
  static String newsImageUpload(int newsId) => '/files/news/$newsId/upload-image';
  static String download(int fileId) => '/files/$fileId';
  static String delete(int fileId) => '/files/$fileId';
}

// Public Endpoints
abstract class PublicEndpoints {
  static const String health = '/health';
  static const String news = '/news';
  static const String notifications = '/notifications';
}

// Query Parameters
abstract class QueryParams {
  static const String skip = 'skip';
  static const String limit = 'limit';
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
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
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
}

// Cache Keys
abstract class CacheKeys {
  static const String userToken = 'user_token';
  static const String userProfile = 'user_profile';
  static const String userRole = 'user_role';
  static const String studentHomework = 'student_homework';
  static const String studentExams = 'student_exams';
  static const String studentGrades = 'student_grades';
  static const String notifications = 'notifications';
  static const String themeMode = 'theme_mode';
}