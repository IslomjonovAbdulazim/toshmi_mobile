// lib/app/data/repositories/student_repository.dart
import '../../../core/base/base_repository.dart';
import '../models/homework_model.dart';
import '../models/exam_model.dart';
import '../models/grade_model.dart';
import '../models/attendance_model.dart';
import '../models/schedule_model.dart';
import '../models/payment_model.dart';
import '../../utils/constants/api_constants.dart';

class StudentRepository extends BaseRepository {

  // ============ HOMEWORK ============

  // Get student homework assignments
  Future<List<dynamic>> getHomework() async {
    try {
      final response = await get(ApiConstants.studentHomework);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load homework: $e');
    }
  }

  // Get homework by status (pending, completed, overdue)
  Future<List<dynamic>> getHomeworkByStatus(String status) async {
    try {
      final homework = await getHomework();
      final now = DateTime.now();

      return homework.where((h) {
        final dueDate = DateTime.parse(h['due_date']);
        final hasGrade = h['grade'] != null;

        switch (status.toLowerCase()) {
          case 'pending':
            return !hasGrade && dueDate.isAfter(now);
          case 'completed':
            return hasGrade;
          case 'overdue':
            return !hasGrade && dueDate.isBefore(now);
          default:
            return true;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter homework: $e');
    }
  }

  // ============ EXAMS ============

  // Get student exams
  Future<List<dynamic>> getExams() async {
    try {
      final response = await get(ApiConstants.studentExams);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load exams: $e');
    }
  }

  // Get upcoming exams
  Future<List<dynamic>> getUpcomingExams() async {
    try {
      final exams = await getExams();
      final now = DateTime.now();

      return exams.where((e) {
        final examDate = DateTime.parse(e['exam_date']);
        return examDate.isAfter(now);
      }).toList()
        ..sort((a, b) => DateTime.parse(a['exam_date']).compareTo(DateTime.parse(b['exam_date'])));
    } catch (e) {
      throw Exception('Failed to load upcoming exams: $e');
    }
  }

  // ============ GRADES ============

  // Get student grades
  Future<Map<String, dynamic>> getGrades() async {
    try {
      final response = await get(ApiConstants.studentGrades);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load grades: $e');
    }
  }

  // Calculate GPA and grade statistics
  Future<Map<String, dynamic>> getGradeStatistics() async {
    try {
      final gradesData = await getGrades();
      final homeworkGrades = gradesData['homework_grades'] as List<dynamic>;
      final examGrades = gradesData['exam_grades'] as List<dynamic>;

      if (homeworkGrades.isEmpty && examGrades.isEmpty) {
        return {
          'overall_average': 0.0,
          'homework_average': 0.0,
          'exam_average': 0.0,
          'total_assignments': 0,
          'completed_assignments': 0,
          'completion_rate': 0.0,
        };
      }

      // Calculate homework average
      double homeworkAvg = 0.0;
      if (homeworkGrades.isNotEmpty) {
        final homeworkTotal = homeworkGrades.fold<double>(0.0, (sum, g) => sum + g['percentage']);
        homeworkAvg = homeworkTotal / homeworkGrades.length;
      }

      // Calculate exam average
      double examAvg = 0.0;
      if (examGrades.isNotEmpty) {
        final examTotal = examGrades.fold<double>(0.0, (sum, g) => sum + g['percentage']);
        examAvg = examTotal / examGrades.length;
      }

      // Overall average (weighted: 40% homework, 60% exams)
      final overallAvg = examGrades.isNotEmpty
          ? (homeworkAvg * 0.4 + examAvg * 0.6)
          : homeworkAvg;

      return {
        'overall_average': double.parse(overallAvg.toStringAsFixed(1)),
        'homework_average': double.parse(homeworkAvg.toStringAsFixed(1)),
        'exam_average': double.parse(examAvg.toStringAsFixed(1)),
        'total_assignments': homeworkGrades.length + examGrades.length,
        'completed_assignments': homeworkGrades.length + examGrades.length,
        'completion_rate': 100.0,
      };
    } catch (e) {
      throw Exception('Failed to calculate grade statistics: $e');
    }
  }

  // ============ ATTENDANCE ============

  // Get student attendance
  Future<List<dynamic>> getAttendance() async {
    try {
      final response = await get(ApiConstants.studentAttendance);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  // Get attendance summary
  Future<Map<String, dynamic>> getAttendanceSummary() async {
    try {
      final attendance = await getAttendance();

      final summary = <String, int>{
        'present': 0,
        'absent': 0,
        'late': 0,
        'excused': 0,
        'total': attendance.length,
      };

      for (final record in attendance) {
        final status = record['status'] as String;
        summary[status] = (summary[status] ?? 0) + 1;
      }

      final presentPercentage = summary['total']! > 0
          ? (summary['present']! / summary['total']! * 100)
          : 0.0;

      return {
        ...summary,
        'present_percentage': double.parse(presentPercentage.toStringAsFixed(1)),
      };
    } catch (e) {
      throw Exception('Failed to calculate attendance summary: $e');
    }
  }

  // ============ SCHEDULE ============

  // Get student schedule
  Future<List<dynamic>> getSchedule() async {
    try {
      final response = await get(ApiConstants.studentSchedule);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load schedule: $e');
    }
  }

  // Get today's schedule
  Future<List<dynamic>> getTodaySchedule() async {
    try {
      final schedule = await getSchedule();
      final today = DateTime.now().weekday - 1; // Convert to 0-6 format (0=Monday)

      return schedule.where((s) => s['day'] == today).toList()
        ..sort((a, b) => a['start_time'].compareTo(b['start_time']));
    } catch (e) {
      throw Exception('Failed to load today\'s schedule: $e');
    }
  }

  // Get schedule by day
  Future<List<dynamic>> getScheduleByDay(int day) async {
    try {
      final schedule = await getSchedule();
      return schedule.where((s) => s['day'] == day).toList()
        ..sort((a, b) => a['start_time'].compareTo(b['start_time']));
    } catch (e) {
      throw Exception('Failed to load schedule for day: $e');
    }
  }

  // ============ PAYMENTS ============

  // Get student payments
  Future<Map<String, dynamic>> getPayments() async {
    try {
      final response = await get(ApiConstants.studentPayments);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  // Calculate payment statistics
  Future<Map<String, dynamic>> getPaymentSummary() async {
    try {
      final paymentsData = await getPayments();
      final paymentRecords = paymentsData['payment_records'] as List<dynamic>;

      if (paymentRecords.isEmpty) {
        return {
          'total_paid': 0,
          'payment_count': 0,
          'average_payment': 0,
          'latest_payment': null,
          'payment_methods': <String, int>{},
        };
      }

      final totalPaid = paymentRecords.fold<int>(0, (sum, p) => sum + (p['amount'] as int));
      final averagePayment = totalPaid / paymentRecords.length;

      // Count payment methods
      final methodCounts = <String, int>{};
      for (final payment in paymentRecords) {
        final method = payment['payment_method'] as String;
        methodCounts[method] = (methodCounts[method] ?? 0) + 1;
      }

      // Get latest payment
      final sortedPayments = List.from(paymentRecords)
        ..sort((a, b) => DateTime.parse(b['payment_date']).compareTo(DateTime.parse(a['payment_date'])));

      return {
        'total_paid': totalPaid,
        'payment_count': paymentRecords.length,
        'average_payment': averagePayment.round(),
        'latest_payment': sortedPayments.isNotEmpty ? sortedPayments.first : null,
        'payment_methods': methodCounts,
      };
    } catch (e) {
      throw Exception('Failed to calculate payment summary: $e');
    }
  }

  // ============ DASHBOARD ============

  // Get student dashboard data
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await get(ApiConstants.studentDashboard);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load dashboard: $e');
    }
  }

  // Get comprehensive dashboard with statistics
  Future<Map<String, dynamic>> getComprehensiveDashboard() async {
    try {
      // Fetch all data in parallel
      final futures = await Future.wait([
        getDashboard(),
        getGradeStatistics(),
        getAttendanceSummary(),
        getPaymentSummary(),
        getTodaySchedule(),
      ]);

      final dashboard = futures[0] as Map<String, dynamic>;
      final gradeStats = futures[1] as Map<String, dynamic>;
      final attendanceStats = futures[2] as Map<String, dynamic>;
      final paymentStats = futures[3] as Map<String, dynamic>;
      final todaySchedule = futures[4] as List<dynamic>;

      return {
        ...dashboard,
        'grade_statistics': gradeStats,
        'attendance_statistics': attendanceStats,
        'payment_statistics': paymentStats,
        'today_schedule': todaySchedule,
        'summary': {
          'overall_average': gradeStats['overall_average'],
          'attendance_percentage': attendanceStats['present_percentage'],
          'upcoming_homework': (dashboard['upcoming_homework'] as List).length,
          'upcoming_exams': (dashboard['upcoming_exams'] as List).length,
          'today_classes': todaySchedule.length,
        }
      };
    } catch (e) {
      throw Exception('Failed to load comprehensive dashboard: $e');
    }
  }

  // ============ UTILITY METHODS ============

  // Get next upcoming deadline
  Future<Map<String, dynamic>?> getNextDeadline() async {
    try {
      final homework = await getHomework();
      final exams = await getExams();
      final now = DateTime.now();

      final upcomingItems = <Map<String, dynamic>>[];

      // Add upcoming homework
      for (final h in homework) {
        final dueDate = DateTime.parse(h['due_date']);
        if (dueDate.isAfter(now) && h['grade'] == null) {
          upcomingItems.add({
            'type': 'homework',
            'title': h['title'],
            'subject': h['subject'],
            'date': dueDate,
            'data': h,
          });
        }
      }

      // Add upcoming exams
      for (final e in exams) {
        final examDate = DateTime.parse(e['exam_date']);
        if (examDate.isAfter(now)) {
          upcomingItems.add({
            'type': 'exam',
            'title': e['title'],
            'subject': e['subject'],
            'date': examDate,
            'data': e,
          });
        }
      }

      if (upcomingItems.isEmpty) return null;

      // Sort by date and return the earliest
      upcomingItems.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      return upcomingItems.first;
    } catch (e) {
      throw Exception('Failed to get next deadline: $e');
    }
  }

  // Search across homework and exams
  Future<Map<String, List<dynamic>>> searchContent(String query) async {
    try {
      final homework = await getHomework();
      final exams = await getExams();

      final lowQuery = query.toLowerCase();

      final matchedHomework = homework.where((h) =>
      h['title'].toString().toLowerCase().contains(lowQuery) ||
          h['description'].toString().toLowerCase().contains(lowQuery) ||
          h['subject'].toString().toLowerCase().contains(lowQuery)
      ).toList();

      final matchedExams = exams.where((e) =>
      e['title'].toString().toLowerCase().contains(lowQuery) ||
          e['description'].toString().toLowerCase().contains(lowQuery) ||
          e['subject'].toString().toLowerCase().contains(lowQuery)
      ).toList();

      return {
        'homework': matchedHomework,
        'exams': matchedExams,
      };
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }

  @override
  void clearCache() {
    // Clear all student-related cached data
  }
}