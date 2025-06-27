class AppConstants {
  // App info
  static const String appName = 'Maktab Boshqaruv Tizimi';
  static const String appVersion = '1.0.0';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';
  static const String roleParent = 'parent';

  // Attendance status
  static const String attendancePresent = 'present';
  static const String attendanceAbsent = 'absent';
  static const String attendanceLate = 'late';
  static const String attendanceExcused = 'excused';

  // Payment methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentBank = 'bank';
  static const String paymentOnline = 'online';

  // Notification types
  static const String notificationHomework = 'homework';
  static const String notificationExam = 'exam';
  static const String notificationGrade = 'grade';
  static const String notificationAttendance = 'attendance';
  static const String notificationPayment = 'payment';

  // File types
  static const String fileTypeProfile = 'profile';
  static const String fileTypeHomework = 'homework';
  static const String fileTypeExam = 'exam';
  static const String fileTypeNews = 'news';

  // Days of week
  static const List<String> daysOfWeek = [
    'Dushanba',
    'Seshanba',
    'Chorshanba',
    'Payshanba',
    'Juma',
    'Shanba',
    'Yakshanba'
  ];

  // File size limits (MB)
  static const int maxImageSize = 3;
  static const int maxFileSize = 10;

  // Grade thresholds
  static const double gradeExcellent = 90.0;
  static const double gradeGood = 75.0;
  static const double gradeAverage = 60.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date formats
  static const String dateFormat = 'dd.MM.yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
}