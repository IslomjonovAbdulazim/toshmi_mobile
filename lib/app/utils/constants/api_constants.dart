class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://islomjonovabdulazim-toshmi-backend-0914.twc1.net';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String changePassword = '/auth/change-password';
  static const String profile = '/auth/profile';
  static const String notifications = '/auth/notifications';
  static const String notificationRead = '/auth/notifications'; // /{notification_id}/read
  static const String notificationMarkAllRead = '/auth/notifications/mark-all-read';
  static const String notificationUnreadCount = '/auth/notifications/unread-count';

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
  static const String adminMonthlyPaymentStatus = '/admin/monthly-payment-status';
  static const String adminAssignments = '/admin/assignments'; // /{group_subject_id}

  // Teacher endpoints
  static const String teacherHomework = '/teacher/homework';
  static const String teacherExams = '/teacher/exams';
  static const String teacherBulkHomeworkGrades = '/teacher/bulk-homework-grades';
  static const String teacherBulkExamGrades = '/teacher/bulk-exam-grades';
  static const String teacherBulkAttendance = '/teacher/bulk-attendance';
  static const String teacherAttendanceTable = '/teacher/attendance-table';
  static const String teacherGroups = '/teacher/groups'; // /{group_id}/students

  // NEW: Teacher group-subjects and schedule endpoints
  static const String teacherGroupSubjects = '/teacher/group-subjects';
  static const String teacherGroupSubjectSchedule = '/teacher/group-subjects'; // /{group_subject_id}/schedule

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
  static const String parentChildHomework = '/parent/children'; // /{child_id}/homework
  static const String parentChildGrades = '/parent/children'; // /{child_id}/grades
  static const String parentChildAttendance = '/parent/children'; // /{child_id}/attendance
  static const String parentChildPayments = '/parent/children'; // /{child_id}/payments
  static const String parentDashboard = '/parent/dashboard';

  // File endpoints
  static const String filesProfilePicture = '/files/profile-picture';
  static const String filesHomework = '/files/homework'; // /{homework_id}/upload
  static const String filesExam = '/files/exam'; // /{exam_id}/upload
  static const String filesNews = '/files/news'; // /{news_id}/upload-image
  static const String files = '/files'; // /{file_id}

  // System endpoints
  static const String health = '/health';
  static const String stats = '/stats';
  static const String news = '/news';
  static const String initDb = '/init-db';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusServerError = 500;
}