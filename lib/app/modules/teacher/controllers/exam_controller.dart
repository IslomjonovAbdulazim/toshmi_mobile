// lib/app/modules/teacher/controllers/exam_controller.dart
import 'package:get/get.dart';

import '../../../data/models/group_subject_model.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/repositories/teacher_repository.dart';

class ExamController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository = GroupSubjectRepository();

  final isLoading = false.obs;
  final examsList = <dynamic>[].obs;

  final groupSubjects = <GroupSubject>[].obs;
  final selectedGroupSubject = Rx<GroupSubject?>(null);

  final externalLinks = <String>[].obs;

  final selectedFilter = 'near_deadline'.obs;
  final filteredExamsList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadExams();
    loadGroupSubjects();
  }

  Future<void> loadGroupSubjects() async {
    try {
      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();
      groupSubjects.value = subjects;
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_loading_classes'.tr}: $e');
    }
  }

  void filterExams() {
    final now = DateTime.now();
    switch (selectedFilter.value) {
      case 'near_deadline':
        filteredExamsList.value = examsList.where((e) {
          final examDate = DateTime.parse(e['exam_date']);
          return examDate.isAfter(now);
        }).toList()..sort((a, b) => DateTime.parse(a['exam_date']).compareTo(DateTime.parse(b['exam_date'])));
        break;
      case 'old_deadline':
        filteredExamsList.value = examsList.where((e) {
          final examDate = DateTime.parse(e['exam_date']);
          return examDate.isBefore(now);
        }).toList()..sort((a, b) => DateTime.parse(b['exam_date']).compareTo(DateTime.parse(a['exam_date'])));
        break;
      case 'graded':
        filteredExamsList.value = examsList.where((e) =>
        e['graded_count'] != null && e['graded_count'] > 0).toList();
        break;
      case 'not_graded':
        filteredExamsList.value = examsList.where((e) =>
        e['graded_count'] == null || e['graded_count'] == 0).toList();
        break;
    }
  }

  String getFilterDisplayText() {
    switch (selectedFilter.value) {
      case 'near_deadline': return 'near_dates'.tr;
      case 'old_deadline': return 'old_dates'.tr;
      case 'graded': return 'graded'.tr;
      case 'not_graded': return 'not_graded'.tr;
      default: return '';
    }
  }

  Future<void> loadExams() async {
    try {
      isLoading.value = true;
      final exams = await _teacherRepository.getExamsList();
      examsList.value = exams;
      filterExams();
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_loading_exams'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectGroupSubject(GroupSubject groupSubject) {
    selectedGroupSubject.value = groupSubject;
  }

  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  void addExternalLink(String link) {
    if (link.trim().isNotEmpty && !externalLinks.contains(link.trim())) {
      externalLinks.add(link.trim());
    }
  }

  void removeExternalLink(int index) {
    if (index >= 0 && index < externalLinks.length) {
      externalLinks.removeAt(index);
    }
  }

  void clearExternalLinks() {
    externalLinks.clear();
  }

  void initializeExternalLinks(List<String> links) {
    externalLinks.clear();
    externalLinks.addAll(links);
  }

  Future<void> createExam({
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      isLoading.value = true;
      await _teacherRepository.createExam(
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        examDate: examDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
      Get.snackbar('success'.tr, 'exam_created_successfully'.tr);
      loadExams();
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_creating_exam'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateExam({
    required int examId,
    required int groupSubjectId,
    required String title,
    required String description,
    required DateTime examDate,
    int maxPoints = 100,
    List<String> externalLinks = const [],
  }) async {
    try {
      isLoading.value = true;
      await _teacherRepository.updateExam(
        examId: examId,
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        examDate: examDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
      Get.snackbar('success'.tr, 'exam_updated_successfully'.tr);
      loadExams();
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_updating_exam'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExam(int examId) async {
    try {
      isLoading.value = true;
      await _teacherRepository.deleteExam(examId);
      Get.snackbar('success'.tr, 'exam_deleted_successfully'.tr);
      loadExams();
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_deleting_exam'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshExams() async {
    await Future.wait([loadExams(), loadGroupSubjects()]);
  }
}