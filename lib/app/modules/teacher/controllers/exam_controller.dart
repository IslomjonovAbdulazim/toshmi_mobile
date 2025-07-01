// lib/app/modules/teacher/controllers/exam_controller.dart
import 'package:get/get.dart';

import '../../../data/models/group_subject_model.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/repositories/teacher_repository.dart';

class ExamController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository =
      GroupSubjectRepository();

  final isLoading = false.obs;
  final examsList = <dynamic>[].obs;

  // Group subjects for creating exams
  final groupSubjects = <GroupSubject>[].obs;
  final selectedGroupSubject = Rx<GroupSubject?>(null);

  // External links management
  final externalLinks = <String>[].obs;

  // Add these lines after existing observables
  final selectedFilter = 'near_deadline'.obs;
  final filteredExamsList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadExams();
    loadGroupSubjects();
  }

  // Load teacher's group subjects (for exam creation)
  Future<void> loadGroupSubjects() async {
    try {
      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();
      groupSubjects.value = subjects;
    } catch (e) {
      Get.snackbar('Xato', 'Sinflarni yuklashda xatolik: $e');
    }
  }

  // Add this method
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
      case 'near_deadline': return 'Yaqin sanalar';
      case 'old_deadline': return 'O\'tgan sanalar';
      case 'graded': return 'Baholangan';
      case 'not_graded': return 'Baholanmagan';
      default: return '';
    }
  }

  // Update loadExams method
  Future<void> loadExams() async {
    try {
      isLoading.value = true;
      final exams = await _teacherRepository.getExamsList();
      examsList.value = exams;
      filterExams(); // Add this line
    } catch (e) {
      Get.snackbar('Xato', 'Imtihonlarni yuklashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Select group subject for exam creation
  void selectGroupSubject(GroupSubject groupSubject) {
    selectedGroupSubject.value = groupSubject;
  }

  // Get display name for group subject
  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  // External links management
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

  // Create exam
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
      Get.snackbar('Muvaffaqiyat', 'Imtihon muvaffaqiyatli yaratildi');
      loadExams();
    } catch (e) {
      Get.snackbar('Xato', 'Imtihon yaratishda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update exam
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
      Get.snackbar('Muvaffaqiyat', 'Imtihon muvaffaqiyatli yangilandi');
      loadExams();
    } catch (e) {
      Get.snackbar('Xato', 'Imtihonni yangilashda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete exam
  Future<void> deleteExam(int examId) async {
    try {
      isLoading.value = true;
      await _teacherRepository.deleteExam(examId);
      Get.snackbar('Muvaffaqiyat', 'Imtihon muvaffaqiyatli o\'chirildi');
      loadExams();
    } catch (e) {
      Get.snackbar('Xato', 'Imtihonni o\'chirishda xatolik: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh exam data
  Future<void> refreshExams() async {
    await Future.wait([loadExams(), loadGroupSubjects()]);
  }
}
