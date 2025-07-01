// lib/app/modules/teacher/views/grading/exam_grading_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/grading_controller.dart';
import '../shared/widgets/teacher_app_bar.dart';
import 'widgets/grading_table.dart';

class ExamGradingView extends GetView<GradingController> {
  final Map<String, dynamic> exam;

  const ExamGradingView({
    super.key,
    required this.exam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearData();
      controller.loadExamGradingTable(exam['id']);
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: TeacherAppBar(
        title: 'grade_exam'.tr,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isSaving.value
                ? null
                : () => controller.submitExamGrades(exam['id']),
            child: controller.isSaving.value
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text('save_grades'.tr),
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
