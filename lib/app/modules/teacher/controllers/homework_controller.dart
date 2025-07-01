// lib/app/modules/teacher/controllers/homework_controller.dart
import 'package:get/get.dart';

import '../../../data/models/group_subject_model.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../utils/validators/url_validator.dart';

class HomeworkController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository = GroupSubjectRepository();

  final isLoading = false.obs;
  final isLoadingGroupSubjects = false.obs;
  final isSaving = false.obs;

  final homeworkList = <dynamic>[].obs;
  final groupSubjects = <GroupSubject>[].obs;
  final selectedGroupSubject = Rx<GroupSubject?>(null);

  final errorMessage = ''.obs;
  final selectedFilter = 'near_deadline'.obs;
  final filteredHomeworkList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([loadHomework(), loadGroupSubjects()]);
  }

  String getFilterDisplayText() {
    switch (selectedFilter.value) {
      case 'near_deadline':
        return 'near_deadline'.tr;
      case 'old_deadline':
        return 'old_deadline'.tr;
      case 'graded':
        return 'graded'.tr;
      case 'not_graded':
        return 'not_graded'.tr;
      default:
        return '';
    }
  }

  void filterHomework() {
    final now = DateTime.now();
    switch (selectedFilter.value) {
      case 'near_deadline':
        filteredHomeworkList.value = homeworkList.where((h) {
          final dueDate = DateTime.parse(h['due_date']);
          return dueDate.isAfter(now);
        }).toList()..sort((a, b) => DateTime.parse(a['due_date']).compareTo(DateTime.parse(b['due_date'])));
        break;
      case 'old_deadline':
        filteredHomeworkList.value = homeworkList.where((h) {
          final dueDate = DateTime.parse(h['due_date']);
          return dueDate.isBefore(now);
        }).toList()..sort((a, b) => DateTime.parse(b['due_date']).compareTo(DateTime.parse(a['due_date'])));
        break;
      case 'graded':
        filteredHomeworkList.value = homeworkList.where((h) =>
        h['graded_count'] != null && h['graded_count'] > 0).toList();
        break;
      case 'not_graded':
        filteredHomeworkList.value = homeworkList.where((h) =>
        h['graded_count'] == null || h['graded_count'] == 0).toList();
        break;
    }
  }

  Future<void> loadHomework() async {
    try {
      isLoading.value = true;
      final homework = await _teacherRepository.getHomeworkList();
      homeworkList.value = homework;
      filterHomework();
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_loading_homework'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupSubjects() async {
    try {
      isLoadingGroupSubjects.value = true;
      errorMessage.value = '';

      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();
      groupSubjects.value = subjects;

      if (selectedGroupSubject.value == null && subjects.isNotEmpty) {
        selectedGroupSubject.value = subjects.first;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load classes: $e';
      Get.snackbar(
        'error'.tr,
        '${'error_loading_classes'.tr}: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingGroupSubjects.value = false;
    }
  }

  void selectGroupSubject(GroupSubject groupSubject) {
    selectedGroupSubject.value = groupSubject;
  }

  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  Future<void> createHomework({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      isSaving.value = true;

      final validationError = _validateHomeworkInput(
        title: title,
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (validationError != null) {
        Get.snackbar('validation_error'.tr, validationError);
        return;
      }

      await _teacherRepository.createHomework(
        groupSubjectId: groupSubjectId,
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      Get.snackbar(
        'success'.tr,
        '${'homework_created_successfully'.tr} "$title"',
        snackPosition: SnackPosition.TOP,
      );

      await loadHomework();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'error_creating_homework'.tr}: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateHomework({
    required int homeworkId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime dueDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      isSaving.value = true;

      final validationError = _validateHomeworkInput(
        title: title,
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (validationError != null) {
        Get.snackbar('validation_error'.tr, validationError);
        return;
      }

      await _teacherRepository.updateHomework(
        homeworkId: homeworkId,
        groupSubjectId: groupSubjectId,
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      Get.snackbar(
        'success'.tr,
        '${'homework_updated_successfully'.tr} "$title"',
        snackPosition: SnackPosition.TOP,
      );

      await loadHomework();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'error_updating_homework'.tr}: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteHomework(int homeworkId) async {
    try {
      isLoading.value = true;

      await _teacherRepository.deleteHomework(homeworkId);

      Get.snackbar(
        'success'.tr,
        'homework_deleted_successfully'.tr,
        snackPosition: SnackPosition.TOP,
      );

      await loadHomework();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'error_deleting_homework'.tr}: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHomework() async {
    await Future.wait([loadHomework(), loadGroupSubjects()]);
  }

  Map<String, dynamic>? getHomeworkById(int homeworkId) {
    try {
      return homeworkList.firstWhere((hw) => hw['id'] == homeworkId);
    } catch (e) {
      return null;
    }
  }

  List<dynamic> getHomeworkByGroupSubject(int groupSubjectId) {
    return homeworkList
        .where((hw) => hw['group_subject_id'] == groupSubjectId)
        .toList();
  }

  List<dynamic> getUpcomingHomework() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return homeworkList.where((hw) {
      final dueDate = DateTime.parse(hw['due_date']);
      return dueDate.isAfter(now) && dueDate.isBefore(nextWeek);
    }).toList();
  }

  List<dynamic> getOverdueHomework() {
    final now = DateTime.now();

    return homeworkList.where((hw) {
      final dueDate = DateTime.parse(hw['due_date']);
      return dueDate.isBefore(now);
    }).toList();
  }

  String? _validateHomeworkInput({
    required String title,
    required DateTime dueDate,
    required int maxPoints,
    required List<String> externalLinks,
  }) {
    if (title.trim().isEmpty) {
      return 'title_cannot_be_empty'.tr;
    }

    if (title.trim().length < 3) {
      return 'title_min_length'.tr;
    }

    if (dueDate.isBefore(DateTime.now())) {
      return 'due_date_cannot_be_past'.tr;
    }

    if (maxPoints <= 0) {
      return 'max_points_must_be_positive'.tr;
    }

    if (maxPoints > 1000) {
      return 'max_points_limit'.tr;
    }

    if (externalLinks.isNotEmpty) {
      final invalidLinks = UrlValidator.validateMultipleUrls(externalLinks);
      if (invalidLinks.isNotEmpty) {
        return '${'invalid_links_found'.tr}: ${invalidLinks.take(2).join(', ')}${invalidLinks.length > 2 ? '...' : ''}';
      }
    }

    return null;
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Network error') || errorStr.contains('SocketException')) {
      return 'check_internet_connection'.tr;
    }

    if (errorStr.contains('Unauthorized')) {
      return 'please_login_again'.tr;
    }

    if (errorStr.contains('Access denied') || errorStr.contains('403')) {
      return 'no_permission'.tr;
    }

    if (errorStr.contains('Not found') || errorStr.contains('404')) {
      return 'item_not_found'.tr;
    }

    if (errorStr.contains(':')) {
      final parts = errorStr.split(':');
      return parts.last.trim();
    }

    return errorStr;
  }

  void clearData() {
    homeworkList.clear();
    groupSubjects.clear();
    selectedGroupSubject.value = null;
    errorMessage.value = '';
    isLoading.value = false;
    isLoadingGroupSubjects.value = false;
    isSaving.value = false;
  }
}