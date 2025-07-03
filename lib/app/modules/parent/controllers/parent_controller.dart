import 'package:get/get.dart';
import '../../../data/repositories/parent_repository.dart';
import '../views/parent_attendance_view.dart';
import '../views/parent_grades_view.dart';
import '../views/parent_homework_view.dart';
import '../views/parent_payments_view.dart';

class ParentController extends GetxController {
  final ParentRepository _repository = ParentRepository();

  final isLoading = false.obs;
  final selectedChildId = Rxn<int>();
  final children = <Map<String, dynamic>>[].obs;
  final dashboardData = Rxn<Map<String, dynamic>>();
  final childrenSummary = <Map<String, dynamic>>[].obs;

  final currentChildHomework = <Map<String, dynamic>>[].obs;
  final currentChildGrades = Rxn<Map<String, dynamic>>();
  final currentChildAttendance = <Map<String, dynamic>>[].obs;
  final currentChildPayments = Rxn<Map<String, dynamic>>();

  Map<String, dynamic>? get selectedChild {
    if (selectedChildId.value == null) return null;
    return children.firstWhereOrNull((child) => child['id'] == selectedChildId.value);
  }

  String get selectedChildName {
    return selectedChild?['name'] ?? 'Unknown';
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadChildren(),
      loadDashboard(),
    ]);
  }

  Future<Map<String, dynamic>> getChildComprehensiveDashboard(int childId) async {
    try {
      return await _repository.getChildComprehensiveDashboard(childId);
    } catch (e) {
      return {
        'grade_statistics': {},
        'attendance_statistics': {},
        'payment_statistics': {},
        'upcoming_homework': [],
        'summary': {
          'overall_average': 0.0,
          'attendance_percentage': 0.0,
          'pending_homework': 0,
          'total_paid': 0,
        }
      };
    }
  }

  Future<void> loadChildren() async {
    try {
      isLoading.value = true;
      final result = await _repository.getChildren();
      children.assignAll(result.cast<Map<String, dynamic>>());

      if (children.length == 1) {
        selectChild(children.first['id']);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDashboard() async {
    try {
      final result = await _repository.getDashboard();
      dashboardData.value = result;

      final summary = await _repository.getAllChildrenSummary();
      childrenSummary.assignAll(summary);
    } catch (e) {
      // Handle error silently
    }
  }

  void selectChild(int childId) {
    if (selectedChildId.value == childId) return;

    selectedChildId.value = childId;
    loadChildData(childId);
  }

  Future<void> loadChildData(int childId) async {
    await Future.wait([
      loadChildHomework(childId),
      loadChildGrades(childId),
      loadChildAttendance(childId),
      loadChildPayments(childId),
    ]);
  }

  Future<void> loadChildHomework(int childId) async {
    try {
      final result = await _repository.getChildHomework(childId);
      currentChildHomework.assignAll(result.cast<Map<String, dynamic>>());
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<Map<String, dynamic>>> getChildHomeworkByStatus(int childId, String status) async {
    try {
      final result = await _repository.getChildHomeworkByStatus(childId, status);
      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> loadChildGrades(int childId) async {
    try {
      final result = await _repository.getChildGrades(childId);
      currentChildGrades.value = result;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<Map<String, dynamic>> getChildGradeStatistics(int childId) async {
    try {
      return await _repository.getChildGradeStatistics(childId);
    } catch (e) {
      return {};
    }
  }

  Future<void> loadChildAttendance(int childId) async {
    try {
      final result = await _repository.getChildAttendance(childId);
      currentChildAttendance.assignAll(result.cast<Map<String, dynamic>>());
    } catch (e) {
      // Handle error silently
    }
  }

  Future<Map<String, dynamic>> getChildAttendanceSummary(int childId) async {
    try {
      return await _repository.getChildAttendanceSummary(childId);
    } catch (e) {
      return {};
    }
  }

  Future<void> loadChildPayments(int childId) async {
    try {
      final result = await _repository.getChildPayments(childId);
      currentChildPayments.value = result;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<Map<String, dynamic>> getChildPaymentSummary(int childId) async {
    try {
      return await _repository.getChildPaymentSummary(childId);
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> searchChildHomework(int childId, String query) async {
    try {
      final result = await _repository.searchChildHomework(childId, query);
      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getChildNextDeadline(int childId) async {
    try {
      return await _repository.getChildNextDeadline(childId);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshAll() async {
    await loadInitialData();
    if (selectedChildId.value != null) {
      await loadChildData(selectedChildId.value!);
    }
  }

  Future<void> refreshChild() async {
    if (selectedChildId.value != null) {
      await loadChildData(selectedChildId.value!);
    }
  }

  Future<void> refreshChildHomework() async {
    if (selectedChildId.value != null) {
      await loadChildHomework(selectedChildId.value!);
    }
  }

  Future<void> refreshChildGrades() async {
    if (selectedChildId.value != null) {
      await loadChildGrades(selectedChildId.value!);
    }
  }

  Future<void> refreshChildAttendance() async {
    if (selectedChildId.value != null) {
      await loadChildAttendance(selectedChildId.value!);
    }
  }

  Future<void> refreshChildPayments() async {
    if (selectedChildId.value != null) {
      await loadChildPayments(selectedChildId.value!);
    }
  }

  void navigateToChildHomework(int childId) {
    selectChild(childId);
    Get.to(() => const ParentHomeworkView(), arguments: {'childId': childId});
  }

  void navigateToChildGrades(int childId) {
    selectChild(childId);
    Get.to(() => const ParentGradesView(), arguments: {'childId': childId});
  }

  void navigateToChildAttendance(int childId) {
    selectChild(childId);
    Get.to(() => const ParentAttendanceView(), arguments: {'childId': childId});
  }

  void navigateToChildPayments(int childId) {
    selectChild(childId);
    Get.to(() => const ParentPaymentsView(), arguments: {'childId': childId});
  }

  @override
  void onClose() {
    _repository.clearCache();
    super.onClose();
  }
}