// FIXED: Updated to match backend API structure exactly
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../utils/helpers/validation_helper.dart';

class HomeworkController extends BaseController {
  final TeacherRepository _repository = Get.find<TeacherRepository>();

  // Homework list - matches backend response structure
  final RxList<dynamic> homeworkList = <dynamic>[].obs;
  final RxList<dynamic> filteredHomeworkList = <dynamic>[].obs;

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final maxPointsController = TextEditingController(text: '100');
  final externalLinksController = TextEditingController();

  // Form state
  final formKey = GlobalKey<FormState>();
  final Rx<DateTime?> selectedDueDate = Rx<DateTime?>(null);
  final RxInt selectedGroupSubjectId = 0.obs;
  final RxList<String> externalLinks = <String>[].obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;

  // Available group-subjects (will be loaded from API based on teacher assignments)
  final RxList<Map<String, dynamic>> groupSubjects = <Map<String, dynamic>>[].obs;

  // Search and filter
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, upcoming, overdue, completed

  @override
  void onInit() {
    super.onInit();
    loadHomework();
    setupSearchListener();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    maxPointsController.dispose();
    externalLinksController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterHomework();
    });
  }

  // Load homework list (matches backend GET /teacher/homework response)
  Future<void> loadHomework() async {
    try {
      setLoading(true);
      clearError();

      final data = await _repository.getHomeworkList();
      homeworkList.assignAll(data);
      filterHomework();

      print('✅ Loaded ${data.length} homework assignments');
    } catch (e) {
      setError('Vazifalar yuklanmadi: $e');
    } finally {
      setLoading(false);
    }
  }

  // Filter and search homework
  void filterHomework() {
    var filtered = List<dynamic>.from(homeworkList);

    // Apply search (backend returns: id, title, due_date, max_points, subject, group, group_subject_id)
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((homework) {
        final title = homework['title']?.toString().toLowerCase() ?? '';
        final subject = homework['subject']?.toString().toLowerCase() ?? '';
        final group = homework['group']?.toString().toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();

        return title.contains(query) ||
            subject.contains(query) ||
            group.contains(query);
      }).toList();
    }

    // Apply filter
    switch (selectedFilter.value) {
      case 'upcoming':
        filtered = filtered.where((homework) {
          final dueDate = DateTime.parse(homework['due_date']);
          return dueDate.isAfter(DateTime.now());
        }).toList();
        break;
      case 'overdue':
        filtered = filtered.where((homework) {
          final dueDate = DateTime.parse(homework['due_date']);
          return dueDate.isBefore(DateTime.now());
        }).toList();
        break;
      case 'completed':
      // This would need additional field from backend to know if homework is graded
      // For now, we'll filter by past due date
        filtered = filtered.where((homework) {
          final dueDate = DateTime.parse(homework['due_date']);
          return dueDate.isBefore(DateTime.now());
        }).toList();
        break;
    }

    filteredHomeworkList.assignAll(filtered);
  }

  // Create homework (matches backend POST /teacher/homework request)
  Future<void> createHomework() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDueDate.value == null) {
      showError('Muddat tanlang');
      return;
    }
    if (selectedGroupSubjectId.value == 0) {
      showError('Guruh va fanni tanlang');
      return;
    }

    try {
      isCreating.value = true;

      await _repository.createHomework(
        groupSubjectId: selectedGroupSubjectId.value,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        dueDate: selectedDueDate.value!,
        maxPoints: int.parse(maxPointsController.text),
        externalLinks: externalLinks.toList(),
      );

      showSuccess('Vazifa muvaffaqiyatli yaratildi');
      clearForm();
      Get.back();
      await loadHomework();
    } catch (e) {
      showError('Vazifa yaratishda xatolik: $e');
    } finally {
      isCreating.value = false;
    }
  }

  // Update homework (matches backend PUT /teacher/homework/{homework_id} request)
  Future<void> updateHomework(int homeworkId) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDueDate.value == null) {
      showError('Muddat tanlang');
      return;
    }

    try {
      isUpdating.value = true;

      await _repository.updateHomework(
        homeworkId: homeworkId,
        groupSubjectId: selectedGroupSubjectId.value,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        dueDate: selectedDueDate.value!,
        maxPoints: int.parse(maxPointsController.text),
        externalLinks: externalLinks.toList(),
      );

      showSuccess('Vazifa muvaffaqiyatli yangilandi');
      clearForm();
      Get.back();
      await loadHomework();
    } catch (e) {
      showError('Vazifa yangilashda xatolik: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete homework (matches backend DELETE /teacher/homework/{homework_id})
  Future<void> deleteHomework(int homeworkId, String title) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Vazifani o\'chirish'),
        content: Text('\"$title\" vazifasini o\'chirishni tasdiqlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setLoading(true);

      await _repository.deleteHomework(homeworkId);
      showSuccess('Vazifa o\'chirildi');
      await loadHomework();
    } catch (e) {
      showError('Vazifa o\'chirishda xatolik: $e');
    } finally {
      setLoading(false);
    }
  }

  // Navigate to grading (uses homework grading table endpoint)
  void navigateToGrading(int homeworkId, String title) {
    Get.toNamed('/teacher/homework/$homeworkId/grading', arguments: {
      'homework_id': homeworkId,
      'title': title,
      'type': 'homework',
    });
  }

  // Load homework for editing (from backend response structure)
  void loadHomeworkForEdit(dynamic homework) {
    titleController.text = homework['title'] ?? '';
    descriptionController.text = homework['description'] ?? '';
    maxPointsController.text = homework['max_points']?.toString() ?? '100';
    selectedDueDate.value = DateTime.parse(homework['due_date']);
    selectedGroupSubjectId.value = homework['group_subject_id'] ?? 0;

    // External links would need to be loaded from full homework details
    // For now, clear the list as the list endpoint doesn't include them
    externalLinks.clear();
  }

  // Form management
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    maxPointsController.text = '100';
    externalLinksController.clear();
    selectedDueDate.value = null;
    selectedGroupSubjectId.value = 0;
    externalLinks.clear();
  }

  void setDueDate(DateTime date) {
    selectedDueDate.value = date;
  }

  void setGroupSubject(int groupSubjectId) {
    selectedGroupSubjectId.value = groupSubjectId;
  }

  void addExternalLink() {
    final link = externalLinksController.text.trim();
    if (link.isNotEmpty && !externalLinks.contains(link)) {
      externalLinks.add(link);
      externalLinksController.clear();
    }
  }

  void removeExternalLink(int index) {
    externalLinks.removeAt(index);
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    filterHomework();
  }

  // Validation
  String? validateTitle(String? value) {
    return ValidationHelper.required(value, fieldName: 'Vazifa nomi');
  }

  String? validateDescription(String? value) {
    return ValidationHelper.required(value, fieldName: 'Tavsif');
  }

  String? validateMaxPoints(String? value) {
    if (ValidationHelper.required(value, fieldName: 'Maksimal ball') != null) {
      return ValidationHelper.required(value, fieldName: 'Maksimal ball');
    }
    return ValidationHelper.number(value, fieldName: 'Maksimal ball');
  }

  // Helper methods based on backend response structure
  String getStatusText(dynamic homework) {
    final dueDate = DateTime.parse(homework['due_date']);
    final now = DateTime.now();

    // Note: Backend doesn't include graded status in list endpoint
    // This would need to be added to backend or fetched separately
    if (dueDate.isBefore(now)) {
      return 'Muddati o\'tgan';
    } else if (dueDate.difference(now).inDays <= 1) {
      return 'Yaqin muddat';
    } else {
      return 'Kelayotgan';
    }
  }

  Color getStatusColor(dynamic homework) {
    final status = getStatusText(homework);
    switch (status) {
      case 'Baholangan':
        return Colors.green;
      case 'Muddati o\'tgan':
        return Colors.red;
      case 'Yaqin muddat':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Future<void> refreshData() async {
    await loadHomework();
  }
}