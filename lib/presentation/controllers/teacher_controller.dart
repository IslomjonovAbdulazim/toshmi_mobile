import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/models/homework_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/teacher_models.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/student_model.dart';

class TeacherController extends GetxController {
  static TeacherController get to => Get.find();

  final _teacherRepository = Get.find<TeacherRepository>();

  // ===================== REACTIVE STATE =====================

  // Academic content data
  final _homework = <HomeworkModel>[].obs;
  final _exams = <ExamModel>[].obs;
  final _groupStudents = <int, List<StudentModel>>{}.obs;

  // Grading data
  final _homeworkGradingTable = Rxn<GradingTableModel>();
  final _examGradingTable = Rxn<GradingTableModel>();

  // Attendance data
  final _attendanceTable = Rxn<AttendanceTableModel>();

  // Loading states
  final _isHomeworkLoading = false.obs;
  final _isExamsLoading = false.obs;
  final _isStudentsLoading = false.obs;
  final _isGradingTableLoading = false.obs;
  final _isAttendanceTableLoading = false.obs;
  final _isCreatingHomework = false.obs;
  final _isCreatingExam = false.obs;
  final _isSubmittingGrades = false.obs;
  final _isSubmittingAttendance = false.obs;
  final _isRefreshing = false.obs;

  // Form states
  final _selectedGroupSubjectId = Rxn<int>();
  final _selectedGroupId = Rxn<int>();
  final _homeworkFormData = <String, dynamic>{}.obs;
  final _examFormData = <String, dynamic>{}.obs;

  // Filter states
  final _homeworkFilter = 'all'.obs;
  final _examFilter = 'all'.obs;
  final _attendanceDateRange = Rxn<DateTimeRange>();

  // Error states
  final _homeworkError = Rxn<String>();
  final _examsError = Rxn<String>();
  final _studentsError = Rxn<String>();
  final _gradingError = Rxn<String>();
  final _attendanceError = Rxn<String>();

  // UI states
  final _selectedTabIndex = 0.obs;
  final _showCompletedAssignments = false.obs;

  // ===================== GETTERS =====================

  // Data getters
  List<HomeworkModel> get homework => _homework;
  List<ExamModel> get exams => _exams;
  Map<int, List<StudentModel>> get groupStudents => _groupStudents;
  GradingTableModel? get homeworkGradingTable => _homeworkGradingTable.value;
  GradingTableModel? get examGradingTable => _examGradingTable.value;
  AttendanceTableModel? get attendanceTable => _attendanceTable.value;

  // Loading getters
  bool get isHomeworkLoading => _isHomeworkLoading.value;
  bool get isExamsLoading => _isExamsLoading.value;
  bool get isStudentsLoading => _isStudentsLoading.value;
  bool get isGradingTableLoading => _isGradingTableLoading.value;
  bool get isAttendanceTableLoading => _isAttendanceTableLoading.value;
  bool get isCreatingHomework => _isCreatingHomework.value;
  bool get isCreatingExam => _isCreatingExam.value;
  bool get isSubmittingGrades => _isSubmittingGrades.value;
  bool get isSubmittingAttendance => _isSubmittingAttendance.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isAnyLoading => isHomeworkLoading || isExamsLoading || isStudentsLoading ||
      isGradingTableLoading || isAttendanceTableLoading;

  // Form getters
  int? get selectedGroupSubjectId => _selectedGroupSubjectId.value;
  int? get selectedGroupId => _selectedGroupId.value;
  Map<String, dynamic> get homeworkFormData => _homeworkFormData;
  Map<String, dynamic> get examFormData => _examFormData;

  // Filter getters
  String get homeworkFilter => _homeworkFilter.value;
  String get examFilter => _examFilter.value;
  DateTimeRange? get attendanceDateRange => _attendanceDateRange.value;
  bool get showCompletedAssignments => _showCompletedAssignments.value;

  // Error getters
  String? get homeworkError => _homeworkError.value;
  String? get examsError => _examsError.value;
  String? get studentsError => _studentsError.value;
  String? get gradingError => _gradingError.value;
  String? get attendanceError => _attendanceError.value;

  // UI getters
  int get selectedTabIndex => _selectedTabIndex.value;

  // ===================== COMPUTED PROPERTIES =====================

  // Homework computations
  List<HomeworkModel> get filteredHomework {
    var filtered = _homework.toList();

    switch (_homeworkFilter.value) {
      case 'pending':
        filtered = filtered.where((h) => h.dueDate.isAfter(DateTime.now())).toList();
        break;
      case 'due_soon':
        filtered = filtered.where((h) => h.isDueToday || h.isDueTomorrow).toList();
        break;
      case 'overdue':
        filtered = filtered.where((h) => h.isOverdue).toList();
        break;
      case 'needs_grading':
      // This would need additional data about grading status
        break;
      default: // 'all'
        if (!_showCompletedAssignments.value) {
          filtered = filtered.where((h) => h.dueDate.isAfter(DateTime.now())).toList();
        }
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    return filtered;
  }

  List<HomeworkModel> get upcomingHomework => _homework.where((h) =>
  h.dueDate.isAfter(DateTime.now()) && h.daysUntilDue <= 7).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<HomeworkModel> get dueSoonHomework => _homework.where((h) =>
  h.isDueToday || h.isDueTomorrow).toList();

  int get activeHomeworkCount => _homework.where((h) => h.dueDate.isAfter(DateTime.now())).length;
  int get dueSoonCount => dueSoonHomework.length;

  // Exam computations
  List<ExamModel> get filteredExams {
    var filtered = _exams.toList();

    switch (_examFilter.value) {
      case 'upcoming':
        filtered = filtered.where((e) => e.examDate.isAfter(DateTime.now())).toList();
        break;
      case 'this_week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        filtered = filtered.where((e) =>
        e.examDate.isAfter(weekStart) && e.examDate.isBefore(weekEnd)).toList();
        break;
      case 'past':
        filtered = filtered.where((e) => e.isPast).toList();
        break;
      case 'needs_grading':
      // This would need additional data about grading status
        break;
      default: // 'all'
    }

    // Sort by exam date
    filtered.sort((a, b) => a.examDate.compareTo(b.examDate));
    return filtered;
  }

  List<ExamModel> get upcomingExams => _exams.where((e) =>
  e.examDate.isAfter(DateTime.now()) && e.daysUntilExam <= 30).toList()
    ..sort((a, b) => a.examDate.compareTo(b.examDate));

  List<ExamModel> get todaysExams => _exams.where((e) => e.isToday).toList();
  List<ExamModel> get tomorrowsExams => _exams.where((e) => e.isTomorrow).toList();

  int get activeExamsCount => _exams.where((e) => e.examDate.isAfter(DateTime.now())).length;

  // Workload computations
  Map<String, dynamic> get workloadSummary {
    final now = DateTime.now();

    // Get subjects and groups taught
    final subjects = <String>{};
    final groups = <String>{};

    subjects.addAll(_homework.map((h) => h.displaySubject));
    subjects.addAll(_exams.map((e) => e.displaySubject));
    groups.addAll(_homework.map((h) => h.displayGroup));
    groups.addAll(_exams.map((e) => e.displayGroup));

    // Get pending work
    final pendingHomework = _homework.where((h) =>
    h.dueDate.isAfter(now) && h.daysUntilDue <= 7).length;
    final upcomingExams = _exams.where((e) =>
    e.examDate.isAfter(now) && e.daysUntilExam <= 7).length;

    final totalPending = pendingHomework + upcomingExams;
    String workloadLevel;
    if (totalPending >= 10) {
      workloadLevel = 'Yuqori';
    } else if (totalPending >= 5) {
      workloadLevel = 'O\'rta';
    } else if (totalPending >= 2) {
      workloadLevel = 'Past';
    } else {
      workloadLevel = 'Engil';
    }

    return {
      'totalSubjects': subjects.length,
      'totalGroups': groups.length,
      'totalHomework': _homework.length,
      'totalExams': _exams.length,
      'activeHomework': activeHomeworkCount,
      'activeExams': activeExamsCount,
      'pendingHomework': pendingHomework,
      'upcomingExams': upcomingExams,
      'workloadLevel': workloadLevel,
      'subjects': subjects.toList(),
      'groups': groups.toList(),
    };
  }

  // Today's urgent tasks
  List<Map<String, dynamic>> get urgentTasks {
    final tasks = <Map<String, dynamic>>[];

    // Homework due today or tomorrow
    for (final homework in dueSoonHomework.take(3)) {
      tasks.add({
        'type': 'homework',
        'title': homework.title,
        'subtitle': homework.dueStatusText,
        'priority': homework.isDueToday ? 'high' : 'medium',
        'item': homework,
      });
    }

    // Exams today or tomorrow
    for (final exam in [...todaysExams, ...tomorrowsExams].take(3)) {
      tasks.add({
        'type': 'exam',
        'title': exam.title,
        'subtitle': exam.examStatusText,
        'priority': exam.isToday ? 'high' : 'medium',
        'item': exam,
      });
    }

    // Sort by priority
    tasks.sort((a, b) {
      final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
      final aPriority = priorityOrder[a['priority']] ?? 0;
      final bPriority = priorityOrder[b['priority']] ?? 0;
      return bPriority.compareTo(aPriority);
    });

    return tasks.take(5).toList();
  }

  // ===================== LIFECYCLE =====================

  @override
  void onInit() {
    super.onInit();
    _initializeFromCache();
  }

  @override
  void onReady() {
    super.onReady();
    loadAllData();
  }

  // ===================== INITIALIZATION =====================

  /// Initialize data from cache
  void _initializeFromCache() {
    final cachedData = _teacherRepository.getAllCachedData();

    _homework.value = cachedData['homework'] ?? [];
    _exams.value = cachedData['exams'] ?? [];

    print('TeacherController: Initialized from cache');
    print('- Homework: ${_homework.length}');
    print('- Exams: ${_exams.length}');
  }

  // ===================== DATA LOADING =====================

  /// Load all teacher data
  Future<void> loadAllData({bool forceRefresh = false}) async {
    await Future.wait([
      loadHomework(forceRefresh: forceRefresh),
      loadExams(forceRefresh: forceRefresh),
    ]);
  }

  /// Load homework data
  Future<void> loadHomework({bool forceRefresh = false}) async {
    _isHomeworkLoading.value = true;
    _homeworkError.value = null;

    try {
      final result = await _teacherRepository.getMyHomework(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _homework.value = result.data!;
        print('TeacherController: Loaded ${result.data!.length} homework assignments');
      } else {
        _homeworkError.value = result.error?.messageUz ?? 'Vazifalarni yuklab bo\'lmadi';
      }
    } catch (e) {
      _homeworkError.value = 'Kutilmagan xatolik yuz berdi';
      print('TeacherController: Homework load error - $e');
    } finally {
      _isHomeworkLoading.value = false;
    }
  }

  /// Load exams data
  Future<void> loadExams({bool forceRefresh = false}) async {
    _isExamsLoading.value = true;
    _examsError.value = null;

    try {
      final result = await _teacherRepository.getMyExams(
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _exams.value = result.data!;
        print('TeacherController: Loaded ${result.data!.length} exams');
      } else {
        _examsError.value = result.error?.messageUz ?? 'Imtihonlarni yuklab bo\'lmadi';
      }
    } catch (e) {
      _examsError.value = 'Kutilmagan xatolik yuz berdi';
      print('TeacherController: Exams load error - $e');
    } finally {
      _isExamsLoading.value = false;
    }
  }

  /// Load group students
  Future<void> loadGroupStudents(int groupId, {bool forceRefresh = false}) async {
    if (_groupStudents.containsKey(groupId) && !forceRefresh) return;

    _isStudentsLoading.value = true;
    _studentsError.value = null;

    try {
      final result = await _teacherRepository.getGroupStudents(
        groupId,
        useCache: !forceRefresh,
        forceRefresh: forceRefresh,
      );

      if (result.isSuccess && result.data != null) {
        _groupStudents[groupId] = result.data!;
        print('TeacherController: Loaded ${result.data!.length} students for group $groupId');
      } else {
        _studentsError.value = result.error?.messageUz ?? 'Talabalarni yuklab bo\'lmadi';
      }
    } catch (e) {
      _studentsError.value = 'Kutilmagan xatolik yuz berdi';
      print('TeacherController: Students load error - $e');
    } finally {
      _isStudentsLoading.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    _isRefreshing.value = true;

    try {
      await _teacherRepository.refreshAllData();
      await loadAllData(forceRefresh: true);
      _showSuccessMessage('Ma\'lumotlar yangilandi');
      print('TeacherController: All data refreshed');
    } catch (e) {
      _showErrorMessage('Ma\'lumotlarni yangilashda xatolik');
      print('TeacherController: Refresh error - $e');
    } finally {
      _isRefreshing.value = false;
    }
  }

  // ===================== HOMEWORK MANAGEMENT =====================

  /// Create new homework
  Future<bool> createHomework({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    _isCreatingHomework.value = true;

    try {
      final result = await _teacherRepository.createHomework(
        groupSubjectId: groupSubjectId,
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (result.isSuccess) {
        await loadHomework(forceRefresh: true);
        _showSuccessMessage('Vazifa muvaffaqiyatli yaratildi');
        _clearHomeworkForm();
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Vazifa yaratishda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Create homework error - $e');
      return false;
    } finally {
      _isCreatingHomework.value = false;
    }
  }

  /// Update homework
  Future<bool> updateHomework({
    required int homeworkId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    try {
      final result = await _teacherRepository.updateHomework(
        homeworkId: homeworkId,
        groupSubjectId: groupSubjectId,
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (result.isSuccess) {
        await loadHomework(forceRefresh: true);
        _showSuccessMessage('Vazifa muvaffaqiyatli yangilandi');
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Vazifa yangilashda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Update homework error - $e');
      return false;
    }
  }

  /// Delete homework
  Future<bool> deleteHomework(int homeworkId) async {
    try {
      final result = await _teacherRepository.deleteHomework(homeworkId);

      if (result.isSuccess) {
        await loadHomework(forceRefresh: true);
        _showSuccessMessage('Vazifa o\'chirildi');
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Vazifa o\'chirishda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Delete homework error - $e');
      return false;
    }
  }

  // ===================== EXAM MANAGEMENT =====================

  /// Create new exam
  Future<bool> createExam({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    _isCreatingExam.value = true;

    try {
      final result = await _teacherRepository.createExam(
        groupSubjectId: groupSubjectId,
        title: title.trim(),
        description: description.trim(),
        examDate: examDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (result.isSuccess) {
        await loadExams(forceRefresh: true);
        _showSuccessMessage('Imtihon muvaffaqiyatli yaratildi');
        _clearExamForm();
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Imtihon yaratishda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Create exam error - $e');
      return false;
    } finally {
      _isCreatingExam.value = false;
    }
  }

  /// Update exam
  Future<bool> updateExam({
    required int examId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    required int maxPoints,
    List<String> externalLinks = const [],
  }) async {
    try {
      final result = await _teacherRepository.updateExam(
        examId: examId,
        groupSubjectId: groupSubjectId,
        title: title.trim(),
        description: description.trim(),
        examDate: examDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (result.isSuccess) {
        await loadExams(forceRefresh: true);
        _showSuccessMessage('Imtihon muvaffaqiyatli yangilandi');
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Imtihon yangilashda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Update exam error - $e');
      return false;
    }
  }

  /// Delete exam
  Future<bool> deleteExam(int examId) async {
    try {
      final result = await _teacherRepository.deleteExam(examId);

      if (result.isSuccess) {
        await loadExams(forceRefresh: true);
        _showSuccessMessage('Imtihon o\'chirildi');
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Imtihon o\'chirishda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Delete exam error - $e');
      return false;
    }
  }

  // ===================== GRADING =====================

  /// Load homework grading table
  Future<void> loadHomeworkGradingTable(int homeworkId) async {
    _isGradingTableLoading.value = true;
    _gradingError.value = null;

    try {
      final result = await _teacherRepository.getHomeworkGradingTable(homeworkId);

      if (result.isSuccess && result.data != null) {
        _homeworkGradingTable.value = result.data;
        print('TeacherController: Loaded homework grading table');
      } else {
        _gradingError.value = result.error?.messageUz ?? 'Baholash jadvalini yuklab bo\'lmadi';
      }
    } catch (e) {
      _gradingError.value = 'Kutilmagan xatolik yuz berdi';
      print('TeacherController: Grading table load error - $e');
    } finally {
      _isGradingTableLoading.value = false;
    }
  }

  /// Load exam grading table
  Future<void> loadExamGradingTable(int examId) async {
    _isGradingTableLoading.value = true;
    _gradingError.value = null;

    try {
      final result = await _teacherRepository.getExamGradingTable(examId);

      if (result.isSuccess && result.data != null) {
        _examGradingTable.value = result.data;
        print('TeacherController: Loaded exam grading table');
      } else {
        _gradingError.value = result.error?.messageUz ?? 'Baholash jadvalini yuklab bo\'lmadi';
      }
    } catch (e) {
      _gradingError.value = 'Kutilmagan xatolik yuz berdi';
      print('TeacherController: Grading table load error - $e');
    } finally {
      _isGradingTableLoading.value = false;
    }
  }

  /// Submit homework grades
  Future<bool> submitHomeworkGrades({
    required int homeworkId,
    required List<GradeRequest> grades,
  }) async {
    _isSubmittingGrades.value = true;

    try {
      final result = await _teacherRepository.submitHomeworkGrades(
        homeworkId: homeworkId,
        grades: grades,
      );

      if (result.isSuccess) {
        _showSuccessMessage('Baholar muvaffaqiyatli saqlandi');
        await loadHomeworkGradingTable(homeworkId); // Refresh grading table
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Baholarni saqlashda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Submit homework grades error - $e');
      return false;
    } finally {
      _isSubmittingGrades.value = false;
    }
  }

  /// Submit exam grades
  Future<bool> submitExamGrades({
    required int examId,
    required List<GradeRequest> grades,
  }) async {
    _isSubmittingGrades.value = true;

    try {
      final result = await _teacherRepository.submitExamGrades(
        examId: examId,
        grades: grades,
      );

      if (result.isSuccess) {
        _showSuccessMessage('Baholar muvaffaqiyatli saqlandi');
        await loadExamGradingTable(examId); // Refresh grading table
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Baholarni saqlashda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Submit exam grades error - $e');
      return false;
    } finally {
      _isSubmittingGrades.value = false;
    }
  }

  // ===================== ATTENDANCE MANAGEMENT =====================

  /// Load attendance table
  Future<void> loadAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isAttendanceTableLoading.value = true;
    _attendanceError.value = null;

    try {
      final result = await _teacherRepository.getAttendanceTable(
        groupSubjectId: groupSubjectId,
        startDate: startDate,
        endDate: endDate,
      );

      if (result.isSuccess && result.data != null) {
        _attendanceTable.value = result.data;
        print('TeacherController: Loaded attendance table');
      } else {
        _attendanceError.value = result.error?.messageUz ?? 'Davomat jadvalini yuklab bo\'lmadi';
      }
    } catch (e) {
      _attendanceError.value = 'Kutilmagan xatolik yuz berdi';
      print('TeacherController: Attendance table load error - $e');
    } finally {
      _isAttendanceTableLoading.value = false;
    }
  }

  /// Submit attendance
  Future<bool> submitAttendance({
    required int groupSubjectId,
    required DateTime date,
    required List<AttendanceRecord> records,
  }) async {
    _isSubmittingAttendance.value = true;

    try {
      final result = await _teacherRepository.submitAttendance(
        groupSubjectId: groupSubjectId,
        date: date,
        records: records,
      );

      if (result.isSuccess) {
        _showSuccessMessage('Davomat muvaffaqiyatli saqlandi');
        await loadAttendanceTable(groupSubjectId: groupSubjectId); // Refresh table
        return true;
      } else {
        _showErrorMessage(result.error?.messageUz ?? 'Davomatni saqlashda xatolik');
        return false;
      }
    } catch (e) {
      _showErrorMessage('Kutilmagan xatolik yuz berdi');
      print('TeacherController: Submit attendance error - $e');
      return false;
    } finally {
      _isSubmittingAttendance.value = false;
    }
  }

  // ===================== FORM MANAGEMENT =====================

  /// Update homework form data
  void updateHomeworkFormData(String key, dynamic value) {
    _homeworkFormData[key] = value;
  }

  /// Update exam form data
  void updateExamFormData(String key, dynamic value) {
    _examFormData[key] = value;
  }

  /// Clear homework form
  void _clearHomeworkForm() {
    _homeworkFormData.clear();
  }

  /// Clear exam form
  void _clearExamForm() {
    _examFormData.clear();
  }

  /// Validate homework form
  bool validateHomeworkForm() {
    return _homeworkFormData['title']?.toString().trim().isNotEmpty == true &&
        _homeworkFormData['description']?.toString().trim().isNotEmpty == true &&
        _homeworkFormData['dueDate'] != null &&
        _homeworkFormData['maxPoints'] != null &&
        _homeworkFormData['groupSubjectId'] != null;
  }

  /// Validate exam form
  bool validateExamForm() {
    return _examFormData['title']?.toString().trim().isNotEmpty == true &&
        _examFormData['description']?.toString().trim().isNotEmpty == true &&
        _examFormData['examDate'] != null &&
        _examFormData['maxPoints'] != null &&
        _examFormData['groupSubjectId'] != null;
  }

  // ===================== FILTERS & UI CONTROLS =====================

  /// Set homework filter
  void setHomeworkFilter(String filter) {
    _homeworkFilter.value = filter;
    print('TeacherController: Homework filter set to $filter');
  }

  /// Set exam filter
  void setExamFilter(String filter) {
    _examFilter.value = filter;
    print('TeacherController: Exam filter set to $filter');
  }

  /// Set attendance date range
  void setAttendanceDateRange(DateTimeRange? range) {
    _attendanceDateRange.value = range;
    print('TeacherController: Attendance date range set');
  }

  /// Toggle show completed assignments
  void toggleShowCompletedAssignments() {
    _showCompletedAssignments.value = !_showCompletedAssignments.value;
    print('TeacherController: Show completed assignments: ${_showCompletedAssignments.value}');
  }

  /// Set selected tab index
  void setSelectedTabIndex(int index) {
    _selectedTabIndex.value = index;
  }

  /// Set selected group subject ID
  void setSelectedGroupSubjectId(int? id) {
    _selectedGroupSubjectId.value = id;
  }

  /// Set selected group ID
  void setSelectedGroupId(int? id) {
    _selectedGroupId.value = id;
    if (id != null) {
      loadGroupStudents(id);
    }
  }

  // ===================== QUICK ACTIONS =====================

  /// Get quick actions for dashboard
  List<Map<String, dynamic>> getQuickActions() {
    return [
      {
        'title': 'Yangi vazifa',
        'subtitle': 'Vazifa yaratish',
        'icon': Icons.add_task,
        'color': Colors.blue,
        'onTap': () => Get.toNamed('/teacher/homework/create'),
      },
      {
        'title': 'Yangi imtihon',
        'subtitle': 'Imtihon rejalashtirish',
        'icon': Icons.quiz,
        'color': Colors.purple,
        'onTap': () => Get.toNamed('/teacher/exam/create'),
      },
      {
        'title': 'Baholash',
        'subtitle': '${dueSoonCount} ta kerak',
        'icon': Icons.grade,
        'color': dueSoonCount > 0 ? Colors.orange : Colors.green,
        'badge': dueSoonCount > 0 ? dueSoonCount.toString() : null,
        'onTap': () => Get.toNamed('/teacher/grading'),
      },
      {
        'title': 'Davomat',
        'subtitle': 'Davomatni belgilash',
        'icon': Icons.assignment_turned_in,
        'color': Colors.teal,
        'onTap': () => Get.toNamed('/teacher/attendance'),
      },
    ];
  }

  // ===================== UTILITY METHODS =====================

  /// Clear all errors
  void clearErrors() {
    _homeworkError.value = null;
    _examsError.value = null;
    _studentsError.value = null;
    _gradingError.value = null;
    _attendanceError.value = null;
  }

  /// Get homework by ID
  HomeworkModel? getHomeworkById(int id) {
    return _homework.firstWhereOrNull((h) => h.id == id);
  }

  /// Get exam by ID
  ExamModel? getExamById(int id) {
    return _exams.firstWhereOrNull((e) => e.id == id);
  }

  /// Get students for group
  List<StudentModel> getStudentsForGroup(int groupId) {
    return _groupStudents[groupId] ?? [];
  }

  // ===================== MESSAGING =====================

  void _showSuccessMessage(String message) {
    Get.snackbar(
      'Muvaffaqiyat',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ===================== DEBUG =====================

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'homework_count': _homework.length,
      'exams_count': _exams.length,
      'groups_with_students': _groupStudents.keys.length,
      'workload_summary': workloadSummary,
      'urgent_tasks_count': urgentTasks.length,
      'loading_states': {
        'homework': isHomeworkLoading,
        'exams': isExamsLoading,
        'students': isStudentsLoading,
        'grading': isGradingTableLoading,
        'attendance': isAttendanceTableLoading,
      },
      'form_states': {
        'homework_form_valid': validateHomeworkForm(),
        'exam_form_valid': validateExamForm(),
        'selected_group_subject': selectedGroupSubjectId,
        'selected_group': selectedGroupId,
      },
      'repository_cache_info': _teacherRepository.getCacheInfo(),
    };
  }
}