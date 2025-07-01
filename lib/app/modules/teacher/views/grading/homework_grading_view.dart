// lib/app/modules/teacher/views/grading/homework_grading_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/grading_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import 'widgets/grading_table.dart';

class HomeworkGradingView extends GetView<GradingController> {
  final Map<String, dynamic> homework;

  const HomeworkGradingView({
    super.key,
    required this.homework,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Load grading data when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearData();
      controller.loadHomeworkGradingTable(homework['id']);
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'Uy vazifasini baholash',
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isSaving.value
                ? null
                : () => controller.submitHomeworkGrades(homework['id']),
            child: controller.isSaving.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('Saqlash'),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: const GradingTable(),
      ),
    );
  }
}