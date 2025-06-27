import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../data/repositories/parent_repository.dart';
import '../../data/models/student_model.dart';
import '../../data/models/homework_model.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/models/api_response_models.dart';

class ParentController extends GetxController {
  static ParentController get to => Get.find();

  final _parentRepository = Get.find<ParentRepository>();

  // ===================== REACTIVE STATE =====================

  // Children data
  final _children = <ChildModel>[].obs;
  final _selectedChild = Rxn<ChildModel>();
  final _selectedChildId = Rxn<int>();

  // Child academic data
  final _childHomework = <HomeworkModel>[].obs;
  final _childGrades = Rxn<GradesResponseModel>();
  final _childAttendance = <AttendanceModel>[].obs;
  final _childPayments = Rxn<PaymentsResponseModel>();
  final _dashboard = Rxn<ParentDashboardModel>();

  // Loading states
  final _isChildrenLoading = false.obs;
  final _isHomeworkLoading = false.obs;
  final _isGradesLoading = false.obs;
  final _isAttendanceLoading = false.obs;
  final _isPaymentsLoading = false.obs;
  final _isDashboardLoading = false.obs;
  final _isRefreshing = false.obs;

  // Filter and search states
  final _homeworkFilter = 'all'.obs; // all, pending, completed, overdue
  final _gradeFilter = 'all'.obs; // all, recent, bySubject
  final _attendanceFilter = 'all'.obs; // all, present, absent, late
  final _paymentFilter = 'all'.obs; // all, paid, pending, overdue
  final _searchQuery = ''.obs;

  // Date range filters
  final _selectedDateRange = Rxn<DateTimeRange>();
  final _attendanceDateRange = Rxn<DateTimeRange>();
  final _gradeDateRange = Rxn<DateTimeRange>();

  // Error states
  final _childrenError = Rxn<String>();
  final _homeworkError = Rxn<String>();
  final _gradesError = Rxn<String>();
  final _attendanceError = Rxn<String>();
  final _paymentsError = Rxn<String>();
  final _dashboardError = Rxn<String>();

  // UI states
  final _selectedTabIndex = 0.obs;
  final _showFilters = false.obs;
  final _isExpanded = <String, bool>{}.obs;

  // Cache timestamps
  final _childrenLastUpdated = Rxn<DateTime>();
  final _homeworkLastUpdated = <int, DateTime>{}.obs;
  final _gradesLastUpdated = <int, DateTime>{}.obs;
  final _attendanceLastUpdated = <int, DateTime>{}.obs;
  final _paymentsLastUpdated = <int, DateTime>{}.obs;
  final _dashboardLastUpdated = Rxn<DateTime>();

  // ===================== GETTERS =====================

  // Data getters
  List<ChildModel> get children => _children;
  ChildModel? get selectedChild => _selectedChild.value;
  int? get selectedChildId => _selectedChildId.value;
  List<HomeworkModel> get childHomework => _childHomework;
  GradesResponseModel? get childGrades => _childGrades.value;
  List<AttendanceModel> get childAttendance => _childAttendance;
  PaymentsResponseModel? get childPayments => _childPayments.value;
  ParentDashboardModel? get dashboard => _dashboard.value;

  // Loading getters
  bool get isChildrenLoading => _isChildrenLoading.value;
  bool get isHomeworkLoading => _isHomeworkLoading.value;
  bool get isGradesLoading => _isGradesLoading.value;
  bool get isAttendanceLoading => _isAttendanceLoading.value;
  bool get isPaymentsLoading => _isPaymentsLoading.value;
  bool get isDashboardLoading => _isDashboardLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isAnyLoading => isChildrenLoading || isHomeworkLoading || isGradesLoading ||
      isAttendanceLoading || isPaymentsLoading || isDashboardLoading;

  // Filter getters
  String get homeworkFilter => _homeworkFilter.value;
  String get gradeFilter => _gradeFilter.value;
  String get attendanceFilter => _attendanceFilter.value;
  String get paymentFilter => _paymentFilter.value;
  String get searchQuery => _searchQuery.value;
  DateTimeRange? get selectedDateRange => _selectedDateRange.value;
  DateTimeRange? get attendanceDateRange => _attendanceDateRange.value;
  DateTimeRange? get gradeDateRange => _gradeDateRange.value;

  // State getters
  String? get childrenError => _childrenError.value;
  String? get homeworkError => _homeworkError.value;
  String? get gradesError => _gradesError.value;
  String? get attendanceError => _attendanceError.value;
  String? get paymentsError => _paymentsError.value;
  String? get dashboardError => _dashboardError.value;

  // UI getters
  int get selectedTabIndex => _selectedTabIndex.value;
  bool get showFilters => _showFilters.value;
  bool get hasChildren => _children.isNotEmpty;
  bool get hasSelectedChild => _selectedChild.value != null;
  bool get hasActiveFilters => homeworkFilter != 'all' || gradeFilter != 'all' ||
      attendanceFilter != 'all' || paymentFilter != 'all' ||
      searchQuery.isNotEmpty || selectedDateRange != null;

  // Cache getters
  DateTime? get childrenLastUpdated => _childrenLastUpdated.value;
  DateTime? get dashboardLastUpdated => _dashboardLastUpdated.value;

  // Computed getters
  List<HomeworkModel> get filteredHomework {
    var filtered = _childHomework.toList();

    // Apply homework filter
    switch (homeworkFilter) {
      case 'pending':
        filtered = filtered.where((hw) => !hw.hasGrade).toList();
        break;
      case 'completed':
        filtered = filtered.where((hw) => hw.hasGrade).toList();
        break;
      case 'overdue':
        filtered = filtered.where((hw) => hw.isOverdue && !hw.hasGrade).toList();
        break;
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((hw) =>
      hw.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          hw.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          hw.displaySubject.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  List<AttendanceModel> get filteredAttendance {
    var filtered = _childAttendance.toList();

    // Apply attendance filter
    switch (attendanceFilter) {
      case 'present':
        filtered = filtered.where((att) => att.status == AttendanceStatus.present).toList();
        break;
      case 'absent':
        filtered = filtered.where((att) => att.status == AttendanceStatus.absent).toList();
        break;
      case 'late':
        filtered = filtered.where((att) => att.status == AttendanceStatus.late).toList();
        break;
    }

    // Apply date range filter
    if (attendanceDateRange != null) {
      filtered = filtered.where((att) =>
      att.date.isAfter(attendanceDateRange!.start.subtract(const Duration(days: 1))) &&
          att.date.isBefore(attendanceDateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }

    return filtered;
  }

  // Summary getters
  int get totalHomework => _childHomework.length;
  int get pendingHomework => _childHomework.where((hw) => !hw.hasGrade).length;
  int get completedHomework => _childHomework.where((hw) => hw.hasGrade).length;
  int get overdueHomework => _childHomework.where((hw) => hw.isOverdue && !hw.hasGrade).length;

  double get attendancePercentage {
    if (_childAttendance.isEmpty) return 0.0;
    final presentCount = _childAttendance.where((att) => att.status == AttendanceStatus.present).length;
    return (presentCount / _childAttendance.length) * 100;
  }

  // ===================== LIFECYCLE =====================

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onReady() {
    super.onReady();
    _loadInitialData();
  }

  @override
  void onClose() {
    _clearCache();
    super.onClose();
  }

  // ===================== INITIALIZATION =====================

  /// Initialize controller with default values
  void _initializeController() {
    _clearErrors();
    print('ParentController: Initialized');
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    await loadChildren();
    if (hasChildren && selectedChild == null) {
      selectChild(_children.first.id);
    }
    await loadDashboard();
  }

  /// Clear all cached data
  void _clearCache() {
    _children.clear();
    _childHomework.clear();
    _childAttendance.clear();
    _selectedChild.value = null;
    _selectedChildId.value = null;
    _childGrades.value = null;
    _childPayments.value = null;
    _dashboard.value = null;
  }

  // ===================== CHILDREN MANAGEMENT =====================

  /// Load children list
  Future<void> loadChildren({bool forceRefresh = false}) async {
    if (isChildrenLoading) return;

    _isChildrenLoading.value = true;
    _childrenError.value = null;

    try {
      final result = await _parentRepository.getChildren(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _children.assignAll(result.data!);
        _childrenLastUpdated.value = DateTime.now();

        // Auto-select first child if none selected
        if (_children.isNotEmpty && _selectedChild.value == null) {
          _selectedChild.value = _children.first;
          _selectedChildId.value = _children.first.id;
        }

        print('ParentController: Loaded ${_children.length} children');
      } else {
        _childrenError.value = result.error?.messageUz ?? 'Farzandlar ma\'lumotini yuklashda xatolik';
      }
    } catch (e) {
      _childrenError.value = 'Kutilmagan xatolik yuz berdi';
      print('ParentController: Error loading children - $e');
    } finally {
      _isChildrenLoading.value = false;
    }
  }

  /// Select a child by ID
  void selectChild(int childId) {
    final child = _children.firstWhereOrNull((c) => c.id == childId);
    if (child != null) {
      _selectedChild.value = child;
      _selectedChildId.value = childId;

      // Load child's data
      _loadChildData();

      print('ParentController: Selected child ${child.name} (ID: $childId)');
    }
  }

  /// Get child by ID
  ChildModel? getChildById(int childId) {
    return _children.firstWhereOrNull((c) => c.id == childId);
  }

  // ===================== CHILD DATA LOADING =====================

  /// Load all data for selected child
  Future<void> _loadChildData() async {
    if (_selectedChildId.value == null) return;

    await Future.wait([
      loadChildHomework(),
      loadChildGrades(),
      loadChildAttendance(),
      loadChildPayments(),
    ]);
  }

  /// Load child's homework
  Future<void> loadChildHomework({bool forceRefresh = false}) async {
    if (_selectedChildId.value == null || isHomeworkLoading) return;

    _isHomeworkLoading.value = true;
    _homeworkError.value = null;

    try {
      final result = await _parentRepository.getChildHomework(
        _selectedChildId.value!,
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _childHomework.assignAll(result.data!);
        _homeworkLastUpdated[_selectedChildId.value!] = DateTime.now();
        print('ParentController: Loaded ${_childHomework.length} homework items');
      } else {
        _homeworkError.value = result.error?.messageUz ?? 'Uy vazifalarini yuklashda xatolik';
      }
    } catch (e) {
      _homeworkError.value = 'Kutilmagan xatolik yuz berdi';
      print('ParentController: Error loading homework - $e');
    } finally {
      _isHomeworkLoading.value = false;
    }
  }

  /// Load child's grades
  Future<void> loadChildGrades({bool forceRefresh = false}) async {
    if (_selectedChildId.value == null || isGradesLoading) return;

    _isGradesLoading.value = true;
    _gradesError.value = null;

    try {
      final result = await _parentRepository.getChildGrades(
        _selectedChildId.value!,
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _childGrades.value = result.data;
        _gradesLastUpdated[_selectedChildId.value!] = DateTime.now();
        print('ParentController: Loaded grades for child');
      } else {
        _gradesError.value = result.error?.messageUz ?? 'Baholarni yuklashda xatolik';
      }
    } catch (e) {
      _gradesError.value = 'Kutilmagan xatolik yuz berdi';
      print('ParentController: Error loading grades - $e');
    } finally {
      _isGradesLoading.value = false;
    }
  }

  /// Load child's attendance
  Future<void> loadChildAttendance({bool forceRefresh = false}) async {
    if (_selectedChildId.value == null || isAttendanceLoading) return;

    _isAttendanceLoading.value = true;
    _attendanceError.value = null;

    try {
      final result = await _parentRepository.getChildAttendance(
        _selectedChildId.value!,
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _childAttendance.assignAll(result.data!);
        _attendanceLastUpdated[_selectedChildId.value!] = DateTime.now();
        print('ParentController: Loaded ${_childAttendance.length} attendance records');
      } else {
        _attendanceError.value = result.error?.messageUz ?? 'Davomatni yuklashda xatolik';
      }
    } catch (e) {
      _attendanceError.value = 'Kutilmagan xatolik yuz berdi';
      print('ParentController: Error loading attendance - $e');
    } finally {
      _isAttendanceLoading.value = false;
    }
  }

  /// Load child's payments
  Future<void> loadChildPayments({bool forceRefresh = false}) async {
    if (_selectedChildId.value == null || isPaymentsLoading) return;

    _isPaymentsLoading.value = true;
    _paymentsError.value = null;

    try {
      final result = await _parentRepository.getChildPayments(
        _selectedChildId.value!,
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _childPayments.value = result.data;
        _paymentsLastUpdated[_selectedChildId.value!] = DateTime.now();
        print('ParentController: Loaded payments for child');
      } else {
        _paymentsError.value = result.error?.messageUz ?? 'To\'lovlarni yuklashda xatolik';
      }
    } catch (e) {
      _paymentsError.value = 'Kutilmagan xatolik yuz berdi';
      print('ParentController: Error loading payments - $e');
    } finally {
      _isPaymentsLoading.value = false;
    }
  }

  /// Load dashboard data
  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (isDashboardLoading) return;

    _isDashboardLoading.value = true;
    _dashboardError.value = null;

    try {
      final result = await _parentRepository.getDashboard(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _dashboard.value = result.data;
        _dashboardLastUpdated.value = DateTime.now();
        print('ParentController: Loaded dashboard data');
      } else {
        _dashboardError.value = result.error?.messageUz ?? 'Dashboard ma\'lumotlarini yuklashda xatolik';
      }
    } catch (e) {
      _dashboardError.value = 'Kutilmagan xatolik yuz berdi';
      print('ParentController: Error loading dashboard - $e');
    } finally {
      _isDashboardLoading.value = false;
    }
  }

  // ===================== REFRESH & UPDATE =====================

  /// Refresh all data
  Future<void> refreshAll() async {
    if (isRefreshing) return;

    _isRefreshing.value = true;

    try {
      await loadChildren(forceRefresh: true);
      if (hasSelectedChild) {
        await _loadChildData();
      }
      await loadDashboard(forceRefresh: true);

      _showSuccessMessage('Ma\'lumotlar yangilandi');
    } catch (e) {
      _showErrorMessage('Ma\'lumotlarni yangilashda xatolik');
      print('ParentController: Error refreshing all data - $e');
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// Refresh current child's data
  Future<void> refreshChildData() async {
    if (_selectedChildId.value == null) return;

    await _loadChildData();
    _showSuccessMessage('Farzand ma\'lumotlari yangilandi');
  }

  // ===================== FILTERS & SEARCH =====================

  /// Set homework filter
  void setHomeworkFilter(String filter) {
    _homeworkFilter.value = filter;
    print('ParentController: Homework filter set to $filter');
  }

  /// Set grade filter
  void setGradeFilter(String filter) {
    _gradeFilter.value = filter;
    print('ParentController: Grade filter set to $filter');
  }

  /// Set attendance filter
  void setAttendanceFilter(String filter) {
    _attendanceFilter.value = filter;
    print('ParentController: Attendance filter set to $filter');
  }

  /// Set payment filter
  void setPaymentFilter(String filter) {
    _paymentFilter.value = filter;
    print('ParentController: Payment filter set to $filter');
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  /// Set date range filter
  void setDateRange(DateTimeRange? range) {
    _selectedDateRange.value = range;
  }

  /// Set attendance date range
  void setAttendanceDateRange(DateTimeRange? range) {
    _attendanceDateRange.value = range;
  }

  /// Set grade date range
  void setGradeDateRange(DateTimeRange? range) {
    _gradeDateRange.value = range;
  }

  /// Clear all filters
  void clearFilters() {
    _homeworkFilter.value = 'all';
    _gradeFilter.value = 'all';
    _attendanceFilter.value = 'all';
    _paymentFilter.value = 'all';
    _searchQuery.value = '';
    _selectedDateRange.value = null;
    _attendanceDateRange.value = null;
    _gradeDateRange.value = null;
    print('ParentController: All filters cleared');
  }

  /// Toggle filters visibility
  void toggleFilters() {
    _showFilters.value = !_showFilters.value;
  }

  // ===================== UI STATE MANAGEMENT =====================

  /// Set selected tab index
  void setSelectedTabIndex(int index) {
    _selectedTabIndex.value = index;
  }

  /// Toggle expansion state for sections
  void toggleExpansion(String key) {
    _isExpanded[key] = !(_isExpanded[key] ?? false);
  }

  /// Check if section is expanded
  bool isExpanded(String key) {
    return _isExpanded[key] ?? false;
  }

  // ===================== ERROR HANDLING =====================

  /// Clear all errors
  void _clearErrors() {
    _childrenError.value = null;
    _homeworkError.value = null;
    _gradesError.value = null;
    _attendanceError.value = null;
    _paymentsError.value = null;
    _dashboardError.value = null;
  }

  /// Clear specific error
  void clearError(String errorType) {
    switch (errorType) {
      case 'children':
        _childrenError.value = null;
        break;
      case 'homework':
        _homeworkError.value = null;
        break;
      case 'grades':
        _gradesError.value = null;
        break;
      case 'attendance':
        _attendanceError.value = null;
        break;
      case 'payments':
        _paymentsError.value = null;
        break;
      case 'dashboard':
        _dashboardError.value = null;
        break;
    }
  }

  // ===================== UTILITY METHODS =====================

  /// Show success message
  void _showSuccessMessage(String message) {
    Get.showSnackbar(GetSnackBar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    ));
  }

  /// Show error message
  void _showErrorMessage(String message) {
    Get.showSnackbar(GetSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    ));
  }

  /// Format attendance percentage
  String formatAttendancePercentage() {
    return '${attendancePercentage.toStringAsFixed(1)}%';
  }

  /// Get homework status summary
  Map<String, int> getHomeworkSummary() {
    return {
      'total': totalHomework,
      'pending': pendingHomework,
      'completed': completedHomework,
      'overdue': overdueHomework,
    };
  }

  /// Get child's last activity date
  DateTime? getChildLastActivity(int childId) {
    final timestamps = [
      _homeworkLastUpdated[childId],
      _gradesLastUpdated[childId],
      _attendanceLastUpdated[childId],
      _paymentsLastUpdated[childId],
    ].where((t) => t != null).cast<DateTime>();

    if (timestamps.isEmpty) return null;
    return timestamps.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Check if data needs refresh
  bool needsRefresh(String dataType, {Duration? threshold}) {
    threshold ??= const Duration(minutes: 30);
    final now = DateTime.now();

    switch (dataType) {
      case 'children':
        return _childrenLastUpdated.value == null ||
            now.difference(_childrenLastUpdated.value!) > threshold;
      case 'dashboard':
        return _dashboardLastUpdated.value == null ||
            now.difference(_dashboardLastUpdated.value!) > threshold;
      default:
        return true;
    }
  }
}