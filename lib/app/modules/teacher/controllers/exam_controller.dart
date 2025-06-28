// FIXED: Updated to match backend API structure exactly
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/base/base_controller.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../utils/helpers/validation_helper.dart';

class ExamController extends BaseController {
  final TeacherRepository _repository = Get.find<TeacherRepository>();

  // Exam list - matches backend response structure
  final RxList<dynamic> examsList = <dynamic>[].obs;
  final RxList<dynamic> filteredExamsList = <dynamic>[].obs;

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final maxPointsController = TextEditingController(text: '100');
  final externalLinksController = TextEditingController();

  // Form state
  final formKey = GlobalKey<FormState>();
  final Rx<DateTime?> selectedExamDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedExamTime = Rx<TimeOfDay?>(null);
  final RxInt selectedGroupSubjectId = 0.obs;
  final RxList<String> externalLinks = <String>[].obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;

  // Available group-subjects (will be loaded from API based on teacher assignments)
  final RxList<Map<String, dynamic>> groupSubjects = <Map<String, dynamic>>[].obs;

  // Search and filter
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, upcoming, past, today

  @override
  void onInit() {
    super.onInit();
    loadExams();
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
      filterExams();
    });
  }

  // Load exams list (matches backend GET /teacher/exams response)
  Future<void> loadExams() async {
    try {
      setLoading(true);
      clearError();

      final data = await _repository.getExamsList();
      examsList.assignAll(data);
      filterExams();

      print('✅ Loaded ${data.length} exams');
    } catch (e) {
      setError('Imtihonlar yuklanmadi: $e');
    } finally {
      setLoading(false);
    }
  }

  // Filter and search exams
  void filterExams() {
    var filtered = List<dynamic>.from(examsList);

    // Apply search (backend returns: id, title, exam_date, max_points, subject, group, group_subject_id)
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((exam) {
        final title = exam['title']?.toString().toLowerCase() ?? '';
        final subject = exam['subject']?.toString().toLowerCase() ?? '';
        final group = exam['group']?.toString().toLowerCase() ?? '';
        final query = searchQuery.value.toLowerCase();

        return title.contains(query) ||
            subject.contains(query) ||
            group.contains(query);
      }).toList();
    }

    // Apply filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (selectedFilter.value) {
      case 'upcoming':
        filtered = filtered.where((exam) {
          final examDate = DateTime.parse(exam['exam_date']);
          return examDate.isAfter(now);
        }).toList();
        break;
      case 'today':
        filtered = filtered.where((exam) {
          final examDate = DateTime.parse(exam['exam_date']);
          final examDay = DateTime(examDate.year, examDate.month, examDate.day);
          return examDay.isAtSameMomentAs(today);
        }).toList();
        break;
      case 'past':
        filtered = filtered.where((exam) {
          final examDate = DateTime.parse(exam['exam_date']);
          return examDate.isBefore(now);
        }).toList();
        break;
    }

    // Sort by exam date
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['exam_date']);
      final dateB = DateTime.parse(b['exam_date']);
      return dateA.compareTo(dateB);
    });

    filteredExamsList.assignAll(filtered);
  }

  // Create exam (matches backend POST /teacher/exams request)
  Future<void> createExam() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedExamDate.value == null) {
      showError('Imtihon sanasini tanlang');
      return;
    }
    if (selectedExamTime.value == null) {
      showError('Imtihon vaqtini tanlang');
      return;
    }
    if (selectedGroupSubjectId.value == 0) {
      showError('Guruh va fanni tanlang');
      return;
    }

    try {
      isCreating.value = true;

      // Combine date and time for DateTime
      final examDateTime = DateTime(
        selectedExamDate.value!.year,
        selectedExamDate.value!.month,
        selectedExamDate.value!.day,
        selectedExamTime.value!.hour,
        selectedExamTime.value!.minute,
      );

      await _repository.createExam(
        groupSubjectId: selectedGroupSubjectId.value,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        examDate: examDateTime,
        maxPoints: int.parse(maxPointsController.text),
        externalLinks: externalLinks.toList(),
      );

      showSuccess('Imtihon muvaffaqiyatli yaratildi');
      clearForm();
      Get.back();
      await loadExams();
    } catch (e) {
      showError('Imtihon yaratishda xatolik: $e');
    } finally {
      isCreating.value = false;
    }
  }

  // Update exam (matches backend PUT /teacher/exams/{exam_id} request)
  Future<void> updateExam(int examId) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedExamDate.value == null) {
      showError('Imtihon sanasini tanlang');
      return;
    }
    if (selectedExamTime.value == null) {
      showError('Imtihon vaqtini tanlang');
      return;
    }

    try {
      isUpdating.value = true;

      // Combine date and time for DateTime
      final examDateTime = DateTime(
        selectedExamDate.value!.year,
        selectedExamDate.value!.month,
        selectedExamDate.value!.day,
        selectedExamTime.value!.hour,
        selectedExamTime.value!.minute,
      );

      await _repository.updateExam(
        examId: examId,
        groupSubjectId: selectedGroupSubjectId.value,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        examDate: examDateTime,
        maxPoints: int.parse(maxPointsController.text),
        externalLinks: externalLinks.toList(),
      );

      showSuccess('Imtihon muvaffaqiyatli yangilandi');
      clearForm();
      Get.back();
      await loadExams();
    } catch (e) {
      showError('Imtihon yangilashda xatolik: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete exam (matches backend DELETE /teacher/exams/{exam_id})
  Future<void> deleteExam(int examId, String title) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Imtihonni o\'chirish'),
        content: Text('\"$title\" imtihonini o\'chirishni tasdiqlaysizmi?'),
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

      await _repository.deleteExam(examId);
      showSuccess('Imtihon o\'chirildi');
      await loadExams();
    } catch (e) {
      showError('Imtihon o\'chirishda xatolik: $e');
    } finally {
      setLoading(false);
    }
  }

  // Navigate to grading (uses exam grading table endpoint)
  void navigateToGrading(int examId, String title) {
    Get.toNamed('/teacher/exam/$examId/grading', arguments: {
      'exam_id': examId,
      'title': title,
      'type': 'exam',
    });
  }

  // Load exam for editing (from backend response structure)
  void loadExamForEdit(dynamic exam) {
    titleController.text = exam['title'] ?? '';
    descriptionController.text = exam['description'] ?? '';
    maxPointsController.text = exam['max_points']?.toString() ?? '100';

    final examDateTime = DateTime.parse(exam['exam_date']);
    selectedExamDate.value = examDateTime;
    selectedExamTime.value = TimeOfDay.fromDateTime(examDateTime);
    selectedGroupSubjectId.value = exam['group_subject_id'] ?? 0;

    // External links would need to be loaded from full exam details
    // For now, clear the list as the list endpoint doesn't include them
    externalLinks.clear();
  }

  // Form management
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    maxPointsController.text = '100';
    externalLinksController.clear();
    selectedExamDate.value = null;
    selectedExamTime.value = null;
    selectedGroupSubjectId.value = 0;
    externalLinks.clear();
  }

  void setExamDate(DateTime date) {
    selectedExamDate.value = date;
  }

  void setExamTime(TimeOfDay time) {
    selectedExamTime.value = time;
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
    filterExams();
  }

  // Validation
  String? validateTitle(String? value) {
    return ValidationHelper.required(value, fieldName: 'Imtihon nomi');
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
  String getStatusText(dynamic exam) {
    final examDate = DateTime.parse(exam['exam_date']);
    final now = DateTime.now();

    // Note: Backend doesn't include graded status in list endpoint
    if (examDate.isBefore(now)) {
      return 'O\'tgan';
    } else if (examDate.difference(now).inDays == 0) {
      return 'Bugun';
    } else if (examDate.difference(now).inDays <= 3) {
      return 'Yaqin';
    } else {
      return 'Kelayotgan';
    }
  }

  Color getStatusColor(dynamic exam) {
    final status = getStatusText(exam);
    switch (status) {
      case 'Baholangan':
        return Colors.green;
      case 'O\'tgan':
        return Colors.grey;
      case 'Bugun':
        return Colors.red;
      case 'Yaqin':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String getTimeUntilExam(dynamic exam) {
    final examDate = DateTime.parse(exam['exam_date']);
    final now = DateTime.now();
    final difference = examDate.difference(now);

    if (difference.isNegative) {
      return 'O\'tib ketgan';
    } else if (difference.inDays == 0) {
      if (difference.inHours > 0) {
        return '${difference.inHours} soat qoldi';
      } else {
        return '${difference.inMinutes} daqiqa qoldi';
      }
    } else if (difference.inDays == 1) {
      return 'Ertaga';
    } else {
      return '${difference.inDays} kun qoldi';
    }
  }

  // Get today's exams
  List<dynamic> get todayExams {
    final today = DateTime.now();
    return examsList.where((exam) {
      final examDate = DateTime.parse(exam['exam_date']);
      return examDate.year == today.year &&
          examDate.month == today.month &&
          examDate.day == today.day;
    }).toList();
  }

  // Get upcoming exams (next 7 days)
  List<dynamic> get upcomingExams {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return examsList.where((exam) {
      final examDate = DateTime.parse(exam['exam_date']);
      return examDate.isAfter(now) && examDate.isBefore(nextWeek);
    }).toList();
  }

  @override
  Future<void> refreshData() async {
    await loadExams();
  }
}