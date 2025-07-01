// lib/app/modules/teacher/views/grading/grading_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/homework_controller.dart';
import '../../controllers/exam_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/quick_action_card.dart';
import 'homework_grading_view.dart';
import 'exam_grading_view.dart';

class GradingView extends StatelessWidget {
  const GradingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'grading_title'.tr,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'what_to_grade'.tr,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    title: 'grade_homework_assignments'.tr,
                    subtitle: 'grade_submitted_homework'.tr,
                    icon: Icons.assignment_outlined,
                    iconColor: theme.colorScheme.primary,
                    onTap: () => _showHomeworkList(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    title: 'grade_exams'.tr,
                    subtitle: 'grade_exam_results'.tr,
                    icon: Icons.quiz_outlined,
                    iconColor: theme.colorScheme.secondary,
                    onTap: () => _showExamList(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildRecentGrading(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGrading(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_grading'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.grade_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'no_recent_grading'.tr,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'recent_grading_activity'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showHomeworkList(BuildContext context) {
    if (!Get.isRegistered<HomeworkController>()) {
      Get.lazyPut<HomeworkController>(() => HomeworkController());
    }
    final homeworkController = Get.find<HomeworkController>();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Get.theme.dividerColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'homework_to_grade'.tr,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (homeworkController.homeworkList.isEmpty) {
                  return EmptyState(
                    title: 'no_homework_to_grade'.tr,
                    message: 'create_homework_for_grading'.tr,
                    icon: Icons.assignment_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: homeworkController.homeworkList.length,
                  itemBuilder: (context, index) {
                    final homework = homeworkController.homeworkList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Get.theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.assignment,
                            color: Get.theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(homework['title'] ?? 'untitled'.tr),
                        subtitle: Text('${homework['subject']} • ${homework['group']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.back();
                          Get.to(() => HomeworkGradingView(homework: homework));
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showExamList(BuildContext context) {
    if (!Get.isRegistered<ExamController>()) {
      Get.lazyPut<ExamController>(() => ExamController());
    }
    final examController = Get.find<ExamController>();

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Get.theme.dividerColor.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'exam_to_grade'.tr,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (examController.examsList.isEmpty) {
                  return EmptyState(
                    title: 'no_exams_to_grade'.tr,
                    message: 'create_exams_for_grading'.tr,
                    icon: Icons.quiz_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: examController.examsList.length,
                  itemBuilder: (context, index) {
                    final exam = examController.examsList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Get.theme.colorScheme.secondaryContainer,
                          child: Icon(
                            Icons.quiz,
                            color: Get.theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        title: Text(exam['title'] ?? 'untitled'.tr),
                        subtitle: Text('${exam['subject']} • ${exam['group']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.back();
                          Get.to(() => ExamGradingView(exam: exam));
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}