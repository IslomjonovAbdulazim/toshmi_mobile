// lib/app/modules/teacher/views/grading/grading_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/grading_controller.dart';
import '../../controllers/homework_controller.dart';
import '../../controllers/exam_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/quick_action_card.dart';

class GradingView extends StatelessWidget {
  const GradingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: const TeacherAppBar(
        title: 'Grading',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to grade?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    title: 'Grade Homework',
                    subtitle: 'Grade homework assignments',
                    icon: Icons.assignment_outlined,
                    iconColor: theme.colorScheme.primary,
                    onTap: () => _showHomeworkList(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: QuickActionCard(
                    title: 'Grade Exams',
                    subtitle: 'Grade exam papers',
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
          'Recent Grading',
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
                  'No Recent Grading',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your recent grading activity will appear here',
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
    // Ensure controller is available
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
                    'Select Homework to Grade',
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
                  return const EmptyState(
                    title: 'No Homework',
                    message: 'Create homework assignments to grade them',
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
                        title: Text(homework['title'] ?? 'Untitled'),
                        subtitle: Text('${homework['subject']} • ${homework['group']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.back();
                          Get.snackbar('Info', 'Grade homework feature coming soon');
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
    // Ensure controller is available
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
                    'Select Exam to Grade',
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
                  return const EmptyState(
                    title: 'No Exams',
                    message: 'Create exams to grade them',
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
                        title: Text(exam['title'] ?? 'Untitled'),
                        subtitle: Text('${exam['subject']} • ${exam['group']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Get.back();
                          Get.snackbar('Info', 'Grade exam feature coming soon');
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