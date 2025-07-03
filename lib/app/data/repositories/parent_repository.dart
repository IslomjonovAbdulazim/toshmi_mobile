// lib/app/data/repositories/parent_repository.dart
import '../../../core/base/base_repository.dart';
import '../../utils/constants/api_constants.dart';

class ParentRepository extends BaseRepository {

  // ============ CHILDREN ============

  // Get parent's children list
  Future<List<dynamic>> getChildren() async {
    try {
      final response = await get(ApiConstants.parentChildren);
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load children: $e');
    }
  }

  // Get child by ID (validate ownership)
  Future<Map<String, dynamic>?> getChildById(int childId) async {
    try {
      final children = await getChildren();
      return children.cast<Map<String, dynamic>>()
          .where((child) => child['id'] == childId)
          .firstOrNull;
    } catch (e) {
      throw Exception('Failed to find child: $e');
    }
  }

  // ============ CHILD HOMEWORK ============

  // Get child's homework assignments
  Future<List<dynamic>> getChildHomework(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildHomework}/$childId/homework');
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load child homework: $e');
    }
  }

  // Get child homework by status
  Future<List<dynamic>> getChildHomeworkByStatus(int childId, String status) async {
    try {
      final homework = await getChildHomework(childId);
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
      throw Exception('Failed to filter child homework: $e');
    }
  }

  // ============ CHILD GRADES ============

  // Get child's grades
  Future<Map<String, dynamic>> getChildGrades(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildGrades}/$childId/grades');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load child grades: $e');
    }
  }

  // Calculate child's grade statistics
  Future<Map<String, dynamic>> getChildGradeStatistics(int childId) async {
    try {
      final gradesData = await getChildGrades(childId);
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
      throw Exception('Failed to calculate child grade statistics: $e');
    }
  }

  // ============ CHILD ATTENDANCE ============

  // Get child's attendance
  Future<List<dynamic>> getChildAttendance(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildAttendance}/$childId/attendance');
      return response.body as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load child attendance: $e');
    }
  }

  // Get child's attendance summary
  Future<Map<String, dynamic>> getChildAttendanceSummary(int childId) async {
    try {
      final attendance = await getChildAttendance(childId);

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
      throw Exception('Failed to calculate child attendance summary: $e');
    }
  }

  // ============ CHILD PAYMENTS ============

  // Get child's payments
  Future<Map<String, dynamic>> getChildPayments(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildPayments}/$childId/payments');
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load child payments: $e');
    }
  }

  // Calculate child's payment summary
  Future<Map<String, dynamic>> getChildPaymentSummary(int childId) async {
    try {
      final paymentsData = await getChildPayments(childId);
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
      throw Exception('Failed to calculate child payment summary: $e');
    }
  }

  // ============ PARENT DASHBOARD ============

  // Get parent dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await get(ApiConstants.parentDashboard);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load parent dashboard: $e');
    }
  }

  // Get comprehensive child dashboard
  Future<Map<String, dynamic>> getChildComprehensiveDashboard(int childId) async {
    try {
      // Fetch all child data in parallel
      final futures = await Future.wait([
        getChildGradeStatistics(childId),
        getChildAttendanceSummary(childId),
        getChildPaymentSummary(childId),
        getChildHomework(childId),
      ]);

      final gradeStats = futures[0] as Map<String, dynamic>;
      final attendanceStats = futures[1] as Map<String, dynamic>;
      final paymentStats = futures[2] as Map<String, dynamic>;
      final homework = futures[3] as List<dynamic>;

      final now = DateTime.now();
      final upcomingHomework = homework.where((h) {
        final dueDate = DateTime.parse(h['due_date']);
        return dueDate.isAfter(now) && h['grade'] == null;
      }).toList();

      return {
        'grade_statistics': gradeStats,
        'attendance_statistics': attendanceStats,
        'payment_statistics': paymentStats,
        'upcoming_homework': upcomingHomework,
        'summary': {
          'overall_average': gradeStats['overall_average'],
          'attendance_percentage': attendanceStats['present_percentage'],
          'pending_homework': upcomingHomework.length,
          'total_paid': paymentStats['total_paid'],
        }
      };
    } catch (e) {
      throw Exception('Failed to load child comprehensive dashboard: $e');
    }
  }

  // ============ UTILITY METHODS ============

  // Get child's next upcoming deadline
  Future<Map<String, dynamic>?> getChildNextDeadline(int childId) async {
    try {
      final homework = await getChildHomework(childId);
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

      if (upcomingItems.isEmpty) return null;

      // Sort by date and return the earliest
      upcomingItems.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      return upcomingItems.first;
    } catch (e) {
      throw Exception('Failed to get child next deadline: $e');
    }
  }

  // Search child's homework
  Future<List<dynamic>> searchChildHomework(int childId, String query) async {
    try {
      final homework = await getChildHomework(childId);
      final lowQuery = query.toLowerCase();

      return homework.where((h) =>
      h['title'].toString().toLowerCase().contains(lowQuery) ||
          h['description'].toString().toLowerCase().contains(lowQuery) ||
          h['subject'].toString().toLowerCase().contains(lowQuery)
      ).toList();
    } catch (e) {
      throw Exception('Failed to search child homework: $e');
    }
  }

  // Get all children summary data
  Future<List<Map<String, dynamic>>> getAllChildrenSummary() async {
    try {
      final children = await getChildren();
      final summaries = <Map<String, dynamic>>[];

      for (final child in children) {
        final childId = child['id'] as int;
        try {
          final dashboard = await getChildComprehensiveDashboard(childId);
          summaries.add({
            'child': child,
            'summary': dashboard['summary'],
          });
        } catch (e) {
          // If child data fails, add basic info
          summaries.add({
            'child': child,
            'summary': {
              'overall_average': 0.0,
              'attendance_percentage': 0.0,
              'pending_homework': 0,
              'total_paid': 0,
            },
          });
        }
      }

      return summaries;
    } catch (e) {
      throw Exception('Failed to load children summary: $e');
    }
  }

  @override
  void clearCache() {
    // Clear all parent-related cached data
  }
}