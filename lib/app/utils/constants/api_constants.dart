class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://your-api-domain.com';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String changePassword = '/auth/change-password';
  static const String profile = '/auth/profile';
  static const String notifications = '/auth/notifications';

  // Admin endpoints
  static const String adminStudents = '/admin/students';
  static const String adminTeachers = '/admin/teachers';
  static const String adminParents = '/admin/parents';
  static const String adminGroups = '/admin/groups';
  static const String adminSubjects = '/admin/subjects';
  static const String adminNews = '/admin/news';
  static const String adminSchedule = '/admin/schedule';
  static const String adminAssignTeacher = '/admin/assign-teacher';
  static const String adminPayments = '/admin/payments';

  // Teacher endpoints
  static const String teacherHomework = '/teacher/homework';
  static const String teacherExams = '/teacher/exams';
  static const String teacherBulkGrade = '/teacher/bulk-grade';
  static const String teacherBulkAttendance = '/teacher/bulk-attendance';
  static const String teacherAttendanceTable = '/teacher/attendance-table';

  // Student endpoints
  static const String studentHomework = '/student/homework';
  static const String studentExams = '/student/exams';
  static const String studentGrades = '/student/grades';
  static const String studentAttendance = '/student/attendance';
  static const String studentSchedule = '/student/schedule';
  static const String studentPayments = '/student/payments';
  static const String studentDashboard = '/student/dashboard';

  // Parent endpoints
  static const String parentChildren = '/parent/children';
  static const String parentDashboard = '/parent/dashboard';

  // File endpoints
  static const String filesProfilePicture = '/files/profile-picture';
  static const String filesHomework = '/files/homework';
  static const String filesExam = '/files/exam';
  static const String filesNews = '/files/news';
  static const String files = '/files';

  // System endpoints
  static const String health = '/health';
  static const String stats = '/stats';
  static const String news = '/news';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusServerError = 500;
}