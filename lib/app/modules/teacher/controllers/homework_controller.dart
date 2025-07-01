// lib/app/modules/teacher/controllers/homework_controller.dart
import 'package:get/get.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/group_subject_repository.dart';
import '../../../data/models/group_subject_model.dart';
import '../../../utils/validators/url_validator.dart';

class HomeworkController extends GetxController {
  final TeacherRepository _teacherRepository = Get.find<TeacherRepository>();
  final GroupSubjectRepository _groupSubjectRepository = GroupSubjectRepository();

  // Loading states
  final isLoading = false.obs;
  final isLoadingGroupSubjects = false.obs;
  final isSaving = false.obs;

  // Data observables
  final homeworkList = <dynamic>[].obs;
  final groupSubjects = <GroupSubject>[].obs;
  final selectedGroupSubject = Rx<GroupSubject?>(null);

  // Error handling
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  /// Initialize all required data
  Future<void> _initializeData() async {
    await Future.wait([
      loadHomework(),
      loadGroupSubjects(),
    ]);
  }

  /// Load teacher's group subjects (classes they teach)
  Future<void> loadGroupSubjects() async {
    try {
      isLoadingGroupSubjects.value = true;
      errorMessage.value = '';

      print('🔄 HomeworkController: Loading group subjects...');
      final subjects = await _groupSubjectRepository.getTeacherGroupSubjects();

      groupSubjects.value = subjects;
      print('✅ Loaded ${subjects.length} group subjects');

      // Auto-select first group subject if none selected and list is not empty
      if (selectedGroupSubject.value == null && subjects.isNotEmpty) {
        selectedGroupSubject.value = subjects.first;
        print('🎯 Auto-selected first group subject: ${subjects.first.displayName}');
      }

    } catch (e) {
      print('❌ Error loading group subjects: $e');
      errorMessage.value = 'Failed to load classes: $e';
      Get.snackbar(
        'Xato',
        'Sinflarni yuklashda xatolik: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingGroupSubjects.value = false;
    }
  }

  /// Select a group subject for homework creation
  void selectGroupSubject(GroupSubject groupSubject) {
    selectedGroupSubject.value = groupSubject;
    print('🎯 Selected group subject: ${groupSubject.displayName}');
  }

  /// Get display name for group subject
  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return _groupSubjectRepository.getGroupSubjectDisplayName(groupSubject);
  }

  /// Load homework list
  Future<void> loadHomework() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔄 HomeworkController: Loading homework...');
      final homework = await _teacherRepository.getHomeworkList();

      homeworkList.value = homework;
      print('✅ Loaded ${homework.length} homework items');

    } catch (e) {
      print('❌ Error loading homework: $e');
      errorMessage.value = 'Failed to load homework: $e';
      Get.snackbar(
        'Xato',
        'Uy vazifalarini yuklashda xatolik: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new homework with validation
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

      // Validate inputs
      final validationError = _validateHomeworkInput(
        title: title,
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (validationError != null) {
        Get.snackbar('Tekshirish xatosi', validationError);
        return;
      }

      print('🔄 Creating homework: $title');
      print('📝 Description: "${description}"');
      print('📅 Due date: $dueDate');
      print('⭐ Max points: $maxPoints');
      print('🔗 External links: $externalLinks');

      await _teacherRepository.createHomework(
        groupSubjectId: groupSubjectId,
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      Get.snackbar(
        'Muvaffaqiyat',
        'Uy vazifasi "$title" muvaffaqiyatli yaratildi',
        snackPosition: SnackPosition.TOP,
      );

      // Reload homework list
      await loadHomework();

    } catch (e) {
      print('❌ Error creating homework: $e');
      Get.snackbar(
        'Xato',
        'Uy vazifasi yaratishda xatolik: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Update existing homework with validation
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

      // Validate inputs
      final validationError = _validateHomeworkInput(
        title: title,
        dueDate: dueDate,
        maxPoints: maxPoints,
        externalLinks: externalLinks,
      );

      if (validationError != null) {
        Get.snackbar('Tekshirish xatosi', validationError);
        return;
      }

      print('🔄 Updating homework: $title (ID: $homeworkId)');
      print('📝 Description: "${description}"');
      print('📅 Due date: $dueDate');
      print('⭐ Max points: $maxPoints');
      print('🔗 External links: $externalLinks');

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
        'Muvaffaqiyat',
        'Uy vazifasi "$title" muvaffaqiyatli yangilandi',
        snackPosition: SnackPosition.TOP,
      );

      // Reload homework list
      await loadHomework();

    } catch (e) {
      print('❌ Error updating homework: $e');
      Get.snackbar(
        'Xato',
        'Uy vazifasini yangilashda xatolik: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete homework with confirmation
  Future<void> deleteHomework(int homeworkId) async {
    try {
      isLoading.value = true;

      print('🔄 Deleting homework: $homeworkId');

      await _teacherRepository.deleteHomework(homeworkId);

      Get.snackbar(
        'Muvaffaqiyat',
        'Uy vazifasi muvaffaqiyatli o\'chirildi',
        snackPosition: SnackPosition.TOP,
      );

      // Reload homework list
      await loadHomework();

    } catch (e) {
      print('❌ Error deleting homework: $e');
      Get.snackbar(
        'Xato',
        'Uy vazifasini o\'chirishda xatolik: ${_getErrorMessage(e)}',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshHomework() async {
    print('🔄 Refreshing homework data...');
    await Future.wait([
      loadHomework(),
      loadGroupSubjects(),
    ]);
  }

  /// Get homework by ID from current list
  Map<String, dynamic>? getHomeworkById(int homeworkId) {
    try {
      return homeworkList.firstWhere((hw) => hw['id'] == homeworkId);
    } catch (e) {
      return null;
    }
  }

  /// Filter homework by group subject
  List<dynamic> getHomeworkByGroupSubject(int groupSubjectId) {
    return homeworkList.where((hw) => hw['group_subject_id'] == groupSubjectId).toList();
  }

  /// Get upcoming homework (due in next 7 days)
  List<dynamic> getUpcomingHomework() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return homeworkList.where((hw) {
      final dueDate = DateTime.parse(hw['due_date']);
      return dueDate.isAfter(now) && dueDate.isBefore(nextWeek);
    }).toList();
  }

  /// Get overdue homework
  List<dynamic> getOverdueHomework() {
    final now = DateTime.now();

    return homeworkList.where((hw) {
      final dueDate = DateTime.parse(hw['due_date']);
      return dueDate.isBefore(now);
    }).toList();
  }

  /// Validate homework input data
  String? _validateHomeworkInput({
    required String title,
    required DateTime dueDate,
    required int maxPoints,
    required List<String> externalLinks,
  }) {
    // Title validation
    if (title.trim().isEmpty) {
      return 'Sarlavha bo\'sh bo\'lishi mumkin emas';
    }

    if (title.trim().length < 3) {
      return 'Sarlavha kamida 3 ta belgidan iborat bo\'lishi kerak';
    }

    // Due date validation
    if (dueDate.isBefore(DateTime.now())) {
      return 'Topshirish sanasi o\'tmishda bo\'lishi mumkin emas';
    }

    // Max points validation
    if (maxPoints <= 0) {
      return 'Maksimal ball 0 dan katta bo\'lishi kerak';
    }

    if (maxPoints > 1000) {
      return 'Maksimal ball 1000 dan oshmasligi kerak';
    }

    // External links validation
    if (externalLinks.isNotEmpty) {
      final invalidLinks = UrlValidator.validateMultipleUrls(externalLinks);
      if (invalidLinks.isNotEmpty) {
        return 'Noto\'g\'ri havolalar topildi: ${invalidLinks.take(2).join(', ')}${invalidLinks.length > 2 ? '...' : ''}';
      }
    }

    return null; // All validations passed
  }

  /// Extract user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Network error') || errorStr.contains('SocketException')) {
      return 'Internet aloqasini tekshiring';
    }

    if (errorStr.contains('Unauthorized')) {
      return 'Qaytadan tizimga kiring';
    }

    if (errorStr.contains('Access denied') || errorStr.contains('403')) {
      return 'Bu amal uchun ruxsatingiz yo\'q';
    }

    if (errorStr.contains('Not found') || errorStr.contains('404')) {
      return 'So\'ralgan element topilmadi';
    }

    // Extract the main error message after the colon
    if (errorStr.contains(':')) {
      final parts = errorStr.split(':');
      return parts.last.trim();
    }

    return errorStr;
  }

  /// Clear all data (useful for logout)
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