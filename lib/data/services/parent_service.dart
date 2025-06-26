import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/student_model.dart';
import '../models/homework_model.dart';
import '../models/grade_model.dart';
import '../models/attendance_model.dart';
import '../models/payment_model.dart';
import '../models/dashboard_models.dart';
import '../models/api_response_models.dart';
import 'api_service.dart';

class ParentService extends GetxService {
  static ParentService get to => Get.find();

  final _apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  // ===================== CHILDREN MANAGEMENT =====================

  /// Get list of parent's children
  Future<ApiResult<List<ChildModel>>> getChildren({
    bool useCache = true,
  }) async {
    // Try cache first if requested
    if (useCache) {
      final cachedChildren = getCachedChildren();
      if (cachedChildren.isNotEmpty) {
        // Return cached data and refresh in background
        _refreshChildrenInBackground();
        return ApiResult.success(cachedChildren);
      }
    }

    return await _refreshChildren();
  }

  /// Refresh children from API
  Future<ApiResult<List<ChildModel>>> _refreshChildren() async {
    final result = await _apiService.get<List<ChildModel>>(
      ParentEndpoints.children,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ChildModel.fromJson(item)).toList();
        }
        return <ChildModel>[];
      },
    );

    // Cache successful results
    if (result.isSuccess && result.data != null) {
      await _cacheChildren(result.data!);
    }

    return result;
  }

  /// Refresh children in background
  Future<void> _refreshChildrenInBackground() async {
    try {
      await _refreshChildren();
    } catch (e) {
      print('⚠️ Background children refresh failed: $e');
    }
  }

  /// Cache children locally
  Future<void> _cacheChildren(List<ChildModel> children) async {
    final childrenJson = children.map((c) => c.toJson()).toList();
    await _storage.write(CacheKeys.parentChildren, childrenJson);
  }

  /// Get cached children
  List<ChildModel> getCachedChildren() {
    final cachedData = _storage.read<List>(CacheKeys.parentChildren);
    if (cachedData != null) {
      return cachedData
          .map((item) => ChildModel.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Get child by ID
  ChildModel? getChildById(int childId) {
    final children = getCachedChildren();
    return children.where((c) => c.id == childId).firstOrNull;
  }

  // ===================== CHILD HOMEWORK MONITORING =====================

  /// Get specific child's homework
  Future<ApiResult<List<HomeworkModel>>> getChildHomework(int childId) async {
    return await _apiService.get<List<HomeworkModel>>(
      ParentEndpoints.childHomework(childId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => HomeworkModel.fromJson(item)).toList();
        }
        return <HomeworkModel>[];
      },
    );
  }

  /// Get child's upcoming homework (due within 7 days)
  Future<List<HomeworkModel>> getChildUpcomingHomework(int childId) async {
    final result = await getChildHomework(childId);
    if (result.isSuccess && result.data != null) {
      final now = DateTime.now();
      final weekFromNow = now.add(const Duration(days: 7));

      return result.data!
          .where((h) => h.dueDate.isAfter(now) && h.dueDate.isBefore(weekFromNow))
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }
    return [];
  }

  /// Get child's overdue homework
  Future<List<HomeworkModel>> getChildOverdueHomework(int childId) async {
    final result = await getChildHomework(childId);
    if (result.isSuccess && result.data != null) {
      return result.data!
          .where((h) => h.isOverdue && !h.hasGrade)
          .toList()
        ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    }
    return [];
  }

  /// Get homework statistics for child
  Future<Map<String, dynamic>> getChildHomeworkStats(int childId) async {
    final result = await getChildHomework(childId);
    if (result.isSuccess && result.data != null) {
      final homework = result.data!;
      final now = DateTime.now();

      return {
        'total': homework.length,
        'completed': homework.where((h) => h.hasGrade).length,
        'pending': homework.where((h) => !h.hasGrade && h.dueDate.isAfter(now)).length,
        'overdue': homework.where((h) => h.isOverdue && !h.hasGrade).length,
        'dueSoon': homework.where((h) => h.isDueToday || h.isDueTomorrow).length,
        'thisWeek': homework.where((h) =>
        h.dueDate.isAfter(now) && h.dueDate.isBefore(now.add(const Duration(days: 7)))).length,
      };
    }
    return {};
  }

  // ===================== CHILD GRADES MONITORING =====================

  /// Get specific child's grades
  Future<ApiResult<GradesResponseModel>> getChildGrades(int childId) async {
    return await _apiService.get<GradesResponseModel>(
      ParentEndpoints.childGrades(childId),
      fromJson: (data) => GradesResponseModel.fromJson(data),
    );
  }

  /// Get child's grade summary
  Future<Map<String, dynamic>> getChildGradeSummary(int childId) async {
    final result = await getChildGrades(childId);
    if (result.isSuccess && result.data != null) {
      final grades = result.data!;

      // Calculate subject-wise performance
      final subjectPerformance = <String, List<double>>{};

      // Process homework grades
      for (final grade in grades.homeworkGrades) {
        final subject = grade.displaySubject;
        if (!subjectPerformance.containsKey(subject)) {
          subjectPerformance[subject] = [];
        }
        if (grade.isGraded) {
          subjectPerformance[subject]!.add(grade.calculatedPercentage);
        }
      }

      // Process exam grades
      for (final grade in grades.examGrades) {
        final subject = grade.displaySubject;
        if (!subjectPerformance.containsKey(subject)) {
          subjectPerformance[subject] = [];
        }
        if (grade.isGraded) {
          subjectPerformance[subject]!.add(grade.calculatedPercentage);
        }
      }

      // Calculate averages per subject
      final subjectAverages = <String, double>{};
      for (final entry in subjectPerformance.entries) {
        if (entry.value.isNotEmpty) {
          final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
          subjectAverages[entry.key] = average;
        }
      }

      return {
        'overallAverage': grades.averageGrade,
        'overallStatus': grades.averageGradeStatus,
        'totalGrades': grades.totalGradesCount,
        'gradedCount': grades.gradedCount,
        'pendingCount': grades.pendingCount,
        'homeworkGrades': grades.homeworkGrades.length,
        'examGrades': grades.examGrades.length,
        'subjectAverages': subjectAverages,
        'subjectCount': subjectAverages.length,
        'strongestSubject': _findBestSubject(subjectAverages),
        'weakestSubject': _findWorstSubject(subjectAverages),
      };
    }
    return {};
  }

  /// Find best performing subject
  String? _findBestSubject(Map<String, double> subjectAverages) {
    if (subjectAverages.isEmpty) return null;

    String? bestSubject;
    double bestAverage = 0;

    for (final entry in subjectAverages.entries) {
      if (entry.value > bestAverage) {
        bestAverage = entry.value;
        bestSubject = entry.key;
      }
    }

    return bestSubject;
  }

  /// Find worst performing subject
  String? _findWorstSubject(Map<String, double> subjectAverages) {
    if (subjectAverages.isEmpty) return null;

    String? worstSubject;
    double worstAverage = 100;

    for (final entry in subjectAverages.entries) {
      if (entry.value < worstAverage) {
        worstAverage = entry.value;
        worstSubject = entry.key;
      }
    }

    return worstSubject;
  }

  /// Get recent grades for child (last 10)
  Future<List<dynamic>> getChildRecentGrades(int childId) async {
    final result = await getChildGrades(childId);
    if (result.isSuccess && result.data != null) {
      final grades = result.data!;
      final allGrades = <dynamic>[];

      allGrades.addAll(grades.homeworkGrades);
      allGrades.addAll(grades.examGrades);

      // Sort by graded date
      allGrades.sort((a, b) {
        final aDate = a.gradedAt as DateTime?;
        final bDate = b.gradedAt as DateTime?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return allGrades.take(10).toList();
    }
    return [];
  }

  // ===================== CHILD ATTENDANCE MONITORING =====================

  /// Get specific child's attendance
  Future<ApiResult<List<AttendanceModel>>> getChildAttendance(int childId) async {
    return await _apiService.get<List<AttendanceModel>>(
      ParentEndpoints.childAttendance(childId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => AttendanceModel.fromJson(item)).toList();
        }
        return <AttendanceModel>[];
      },
    );
  }

  /// Calculate child's attendance statistics
  Future<AttendanceStats> getChildAttendanceStats(int childId) async {
    final result = await getChildAttendance(childId);
    if (result.isSuccess && result.data != null) {
      final attendance = result.data!;
      final stats = {
        'present': 0,
        'absent': 0,
        'late': 0,
        'excused': 0,
      };

      for (final record in attendance) {
        if (stats.containsKey(record.status)) {
          stats[record.status] = stats[record.status]! + 1;
        }
      }

      return AttendanceStats(
        present: stats['present']!,
        absent: stats['absent']!,
        late: stats['late']!,
        excused: stats['excused']!,
        totalDays: attendance.length,
      );
    }

    return const AttendanceStats(
      present: 0,
      absent: 0,
      late: 0,
      excused: 0,
      totalDays: 0,
    );
  }

  /// Get recent attendance issues (absences/late arrivals in last 30 days)
  Future<List<AttendanceModel>> getChildRecentAttendanceIssues(int childId) async {
    final result = await getChildAttendance(childId);
    if (result.isSuccess && result.data != null) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      return result.data!
          .where((a) =>
      a.date.isAfter(thirtyDaysAgo) &&
          (a.isAbsent || a.isLate))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    return [];
  }

  // ===================== CHILD PAYMENTS MONITORING =====================

  /// Get specific child's payments
  Future<ApiResult<PaymentsResponseModel>> getChildPayments(int childId) async {
    return await _apiService.get<PaymentsResponseModel>(
      ParentEndpoints.childPayments(childId),
      fromJson: (data) => PaymentsResponseModel.fromJson(data),
    );
  }

  /// Get child's payment summary
  Future<Map<String, dynamic>> getChildPaymentSummary(int childId) async {
    final result = await getChildPayments(childId);
    if (result.isSuccess && result.data != null) {
      final payments = result.data!;

      // Calculate monthly payment status
      final monthlyPayments = payments.monthlyStatus;
      final currentMonth = DateTime.now().month;
      final currentYear = DateTime.now().year;

      final currentMonthPayment = monthlyPayments
          .where((m) => m.month == currentMonth && m.year == currentYear)
          .firstOrNull;

      return {
        'totalPaid': payments.totalPaidAmount,
        'formattedTotal': payments.formattedTotal,
        'pendingCount': payments.pendingPaymentsCount,
        'completedCount': payments.completedPaymentsCount,
        'overdueCount': payments.overduePaymentsCount,
        'recentPayments': payments.recentPayments,
        'currentMonthPaid': currentMonthPayment?.isCompleted ?? false,
        'currentMonthAmount': currentMonthPayment?.formattedAmount ?? '0 so\'m',
        'totalPayments': payments.paymentRecords.length,
        'lastPaymentDate': payments.recentPayments.isNotEmpty
            ? payments.recentPayments.first.formattedPaymentDate
            : null,
      };
    }
    return {};
  }

  /// Get overdue payments for child
  Future<List<MonthlyPaymentModel>> getChildOverduePayments(int childId) async {
    final result = await getChildPayments(childId);
    if (result.isSuccess && result.data != null) {
      return result.data!.monthlyStatus
          .where((p) => p.isOverdue)
          .toList();
    }
    return [];
  }

  // ===================== PARENT DASHBOARD =====================

  /// Get parent dashboard with all children summary
  Future<ApiResult<ParentDashboardModel>> getDashboard({
    bool useCache = true,
  }) async {
    return await _apiService.get<ParentDashboardModel>(
      ParentEndpoints.dashboard,
      fromJson: (data) => ParentDashboardModel.fromJson(data),
    );
  }

  /// Get comprehensive dashboard data for all children
  Future<Map<String, dynamic>> getComprehensiveDashboard() async {
    final children = getCachedChildren();
    if (children.isEmpty) return {};

    final childrenData = <Map<String, dynamic>>[];
    int totalHomework = 0;
    int totalPendingPayments = 0;
    int totalAttendanceIssues = 0;
    double totalGradeAverage = 0;
    int childrenWithGrades = 0;

    for (final child in children) {
      try {
        // Get homework stats
        final homeworkStats = await getChildHomeworkStats(child.id);

        // Get grade summary
        final gradeSummary = await getChildGradeSummary(child.id);

        // Get attendance stats
        final attendanceStats = await getChildAttendanceStats(child.id);

        // Get payment summary
        final paymentSummary = await getChildPaymentSummary(child.id);

        // Get recent attendance issues
        final attendanceIssues = await getChildRecentAttendanceIssues(child.id);

        final childData = {
          'child': child,
          'homework': homeworkStats,
          'grades': gradeSummary,
          'attendance': attendanceStats,
          'payments': paymentSummary,
          'attendanceIssues': attendanceIssues,
          'needsAttention': _checkIfChildNeedsAttention(
              homeworkStats, gradeSummary, attendanceIssues, paymentSummary),
        };

        childrenData.add(childData);

        // Aggregate totals
        totalHomework += (homeworkStats['pending'] as int? ?? 0);
        totalPendingPayments += (paymentSummary['pendingCount'] as int? ?? 0);
        totalAttendanceIssues += attendanceIssues.length;

        final gradeAverage = gradeSummary['overallAverage'] as double? ?? 0;
        if (gradeAverage > 0) {
          totalGradeAverage += gradeAverage;
          childrenWithGrades++;
        }

      } catch (e) {
        print('❌ Error getting data for child ${child.id}: $e');
      }
    }

    final overallGradeAverage = childrenWithGrades > 0
        ? totalGradeAverage / childrenWithGrades
        : 0.0;

    return {
      'children': childrenData,
      'summary': {
        'totalChildren': children.length,
        'totalHomework': totalHomework,
        'totalPendingPayments': totalPendingPayments,
        'totalAttendanceIssues': totalAttendanceIssues,
        'overallGradeAverage': overallGradeAverage,
        'childrenNeedingAttention': childrenData.where((c) => c['needsAttention'] == true).length,
        'performanceStatus': _getOverallPerformanceStatus(overallGradeAverage),
      },
    };
  }

  /// Check if child needs attention
  bool _checkIfChildNeedsAttention(
      Map<String, dynamic> homework,
      Map<String, dynamic> grades,
      List<AttendanceModel> attendanceIssues,
      Map<String, dynamic> payments,
      ) {
    // Check for overdue homework
    if ((homework['overdue'] as int? ?? 0) > 0) return true;

    // Check for poor grades
    if ((grades['overallAverage'] as double? ?? 0) < 50) return true;

    // Check for recent attendance issues
    if (attendanceIssues.length > 3) return true;

    // Check for pending payments
    if ((payments['pendingCount'] as int? ?? 0) > 0) return true;

    return false;
  }

  /// Get overall performance status
  String _getOverallPerformanceStatus(double average) {
    if (average >= 90) return 'A\'lo';
    if (average >= 70) return 'Yaxshi';
    if (average >= 50) return 'Qoniqarli';
    if (average > 0) return 'Yaxshilanishi kerak';
    return 'Ma\'lumot yo\'q';
  }

  // ===================== ALERTS & NOTIFICATIONS =====================

  /// Get important alerts for parent
  Future<List<Map<String, dynamic>>> getParentAlerts() async {
    final children = getCachedChildren();
    final alerts = <Map<String, dynamic>>[];

    for (final child in children) {
      try {
        // Check for overdue homework
        final overdueHomework = await getChildOverdueHomework(child.id);
        if (overdueHomework.isNotEmpty) {
          alerts.add({
            'type': 'overdue_homework',
            'title': '${child.name} - Muddat o\'tgan vazifalar',
            'message': '${overdueHomework.length} ta vazifa muddati o\'tgan',
            'priority': 'high',
            'childId': child.id,
            'childName': child.name,
            'count': overdueHomework.length,
            'icon': '⚠️',
            'color': '#F44336',
          });
        }

        // Check for poor grades
        final gradeSummary = await getChildGradeSummary(child.id);
        final average = gradeSummary['overallAverage'] as double? ?? 0;
        if (average > 0 && average < 50) {
          alerts.add({
            'type': 'poor_grades',
            'title': '${child.name} - Past baholar',
            'message': 'O\'rtacha ball: ${average.toStringAsFixed(1)}%',
            'priority': 'medium',
            'childId': child.id,
            'childName': child.name,
            'average': average,
            'icon': '📉',
            'color': '#FF9800',
          });
        }

        // Check for attendance issues
        final attendanceIssues = await getChildRecentAttendanceIssues(child.id);
        if (attendanceIssues.length >= 3) {
          alerts.add({
            'type': 'attendance_issues',
            'title': '${child.name} - Davomat muammolari',
            'message': 'Oxirgi 30 kunda ${attendanceIssues.length} ta muammo',
            'priority': 'medium',
            'childId': child.id,
            'childName': child.name,
            'count': attendanceIssues.length,
            'icon': '📅',
            'color': '#FF9800',
          });
        }

        // Check for overdue payments
        final overduePayments = await getChildOverduePayments(child.id);
        if (overduePayments.isNotEmpty) {
          alerts.add({
            'type': 'overdue_payments',
            'title': '${child.name} - To\'lov qarzi',
            'message': '${overduePayments.length} ta oylik to\'lov qolgan',
            'priority': 'high',
            'childId': child.id,
            'childName': child.name,
            'count': overduePayments.length,
            'icon': '💰',
            'color': '#F44336',
          });
        }

      } catch (e) {
        print('❌ Error getting alerts for child ${child.id}: $e');
      }
    }

    // Sort by priority and return
    alerts.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      final aPriority = priorityOrder[a['priority']] ?? 0;
      final bPriority = priorityOrder[b['priority']] ?? 0;
      return bPriority.compareTo(aPriority);
    });

    return alerts;
  }

  /// Get positive highlights for parent
  Future<List<Map<String, dynamic>>> getPositiveHighlights() async {
    final children = getCachedChildren();
    final highlights = <Map<String, dynamic>>[];

    for (final child in children) {
      try {
        // Check for excellent grades
        final gradeSummary = await getChildGradeSummary(child.id);
        final average = gradeSummary['overallAverage'] as double? ?? 0;
        if (average >= 90) {
          highlights.add({
            'type': 'excellent_grades',
            'title': '${child.name} - A\'lo natija!',
            'message': 'O\'rtacha ball: ${average.toStringAsFixed(1)}%',
            'childId': child.id,
            'childName': child.name,
            'icon': '🌟',
            'color': '#4CAF50',
          });
        }

        // Check for perfect attendance
        final attendanceStats = await getChildAttendanceStats(child.id);
        if (attendanceStats.attendancePercentage >= 95 && attendanceStats.totalDays > 10) {
          highlights.add({
            'type': 'perfect_attendance',
            'title': '${child.name} - Mukammal davomat!',
            'message': 'Davomat: ${attendanceStats.attendancePercentage.toStringAsFixed(1)}%',
            'childId': child.id,
            'childName': child.name,
            'icon': '✅',
            'color': '#4CAF50',
          });
        }

        // Check for recent improvements
        final recentGrades = await getChildRecentGrades(child.id);
        if (recentGrades.length >= 3) {
          final recentAverage = recentGrades.take(3)
              .map((g) => (g.points / g.maxPoints) * 100)
              .reduce((a, b) => a + b) / 3;

          if (recentAverage > average + 10) {
            highlights.add({
              'type': 'improvement',
              'title': '${child.name} - Yaxshilanish!',
              'message': 'Oxirgi baholar: ${recentAverage.toStringAsFixed(1)}%',
              'childId': child.id,
              'childName': child.name,
              'icon': '📈',
              'color': '#2196F3',
            });
          }
        }

      } catch (e) {
        print('❌ Error getting highlights for child ${child.id}: $e');
      }
    }

    return highlights;
  }

  // ===================== UTILITY METHODS =====================

  /// Refresh all parent data
  Future<void> refreshAllData() async {
    try {
      await getChildren(useCache: false);
      await getDashboard(useCache: false);
      print('✅ All parent data refreshed');
    } catch (e) {
      print('❌ Error refreshing parent data: $e');
    }
  }

  /// Clear all cached parent data
  Future<void> clearCache() async {
    await _storage.remove(CacheKeys.parentChildren);
    print('🗑️ Parent cache cleared');
  }

  /// Get quick actions for parent
  List<Map<String, dynamic>> getQuickActions() {
    final children = getCachedChildren();

    return [
      {
        'title': 'Farzandlarim',
        'icon': '👨‍👩‍👧‍👦',
        'color': '#2196F3',
        'action': 'view_children',
        'badge': children.length.toString(),
      },
      {
        'title': 'Vazifalarni kuzatish',
        'icon': '📝',
        'color': '#FF9800',
        'action': 'view_homework',
      },
      {
        'title': 'Baholarni ko\'rish',
        'icon': '🎯',
        'color': '#4CAF50',
        'action': 'view_grades',
      },
      {
        'title': 'Davomatni tekshirish',
        'icon': '📅',
        'color': '#00BCD4',
        'action': 'view_attendance',
      },
      {
        'title': 'To\'lovlar tarixi',
        'icon': '💰',
        'color': '#9C27B0',
        'action': 'view_payments',
      },
    ];
  }

  /// Check if any child needs urgent attention
  Future<bool> hasUrgentIssues() async {
    final alerts = await getParentAlerts();
    return alerts.any((alert) => alert['priority'] == 'high');
  }

  /// Get summary text for parent dashboard
  Future<String> getSummaryText() async {
    final children = getCachedChildren();
    if (children.isEmpty) return 'Farzandlar ro\'yxati bo\'sh';

    final dashboard = await getComprehensiveDashboard();
    final summary = dashboard['summary'] as Map<String, dynamic>? ?? {};

    final needingAttention = summary['childrenNeedingAttention'] as int? ?? 0;

    if (needingAttention == 0) {
      return 'Barcha farzandlaringiz yaxshi o\'qiyapti! 👏';
    } else if (needingAttention == 1) {
      return '1 farzandingizga e\'tibor kerak';
    } else {
      return '$needingAttention farzandingizga e\'tibor kerak';
    }
  }
}