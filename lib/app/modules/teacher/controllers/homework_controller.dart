// lib/app/modules/teacher/controllers/homework_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/models/group_subject_model.dart';

class HomeworkController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository = GroupSubjectRepository();

  final isLoading = false.obs;
  final homeworkList = <dynamic>[].obs;

  // NEW: Group subjects for creating homework
  final groupSubjects = <GroupSubject>[].obs;
  final selectedGroupSubject = Rx<GroupSubject?>(null);

  @override
  void onInit() {
    super.onInit();
    loadHomework();
    loadGroupSubjects();
  }

  // NEW: Load teacher's group subjects (for homework creation)
  Future<void> loadGroupSubjects() async {
    try {
      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();
      groupSubjects.value = subjects;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load classes: $e');
    }
  }

  // NEW: Select group subject for homework creation
  void selectGroupSubject(GroupSubject groupSubject) {
    selectedGroupSubject.value = groupSubject;
  }

  // NEW: Get display name for group subject
  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  // EXISTING METHODS (keep as they are)
  Future<void> loadHomework() async {
    try {
      isLoading.value = true;
      final homework = await _teacherRepository.getHomeworkList();
      homeworkList.value = homework;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load homework: $e');
    } finally {
      isLoading.value = false;
    }
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
      isLoading.value = true;
      await _teacherRepository.createHomework(
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
      Get.snackbar('Success', 'Homework created successfully');
      loadHomework();
    } catch (e) {
      Get.snackbar('Error', 'Failed to create homework: $e');
    } finally {
      isLoading.value = false;
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
      isLoading.value = true;
      await _teacherRepository.updateHomework(
        homeworkId: homeworkId,
        groupSubjectId: groupSubjectId,
        title: title,
        description: description,
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );
      Get.snackbar('Success', 'Homework updated successfully');
      loadHomework();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update homework: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHomework(int homeworkId) async {
    try {
      isLoading.value = true;
      await _teacherRepository.deleteHomework(homeworkId);
      Get.snackbar('Success', 'Homework deleted successfully');
      loadHomework();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete homework: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHomework() async {
    await Future.wait([
      loadHomework(),
      loadGroupSubjects(),
    ]);
  }
}