import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/loading_widget.dart';
import '../controllers/parent_controller.dart';

class ParentGradesView extends StatelessWidget {
  const ParentGradesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ParentController>();
    final childId = Get.arguments?['childId'] ?? controller.selectedChildId.value;

    if (childId == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'grades'.tr),
        body: Center(child: Text('child_not_selected'.tr)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '${'grades'.tr} - ${controller.selectedChildName}',
        actions: [
          IconButton(
            onPressed: () => controller.refreshChildGrades(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshChildGrades(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGradesStatistics(controller, childId),
              const SizedBox(height: 24),
              _buildGradesList(controller, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradesStatistics(ParentController controller, int childId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getChildGradeStatistics(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final overallAvg = data['overall_average'] as double;
        final homeworkAvg = data['homework_average'] as double;
        final examAvg = data['exam_average'] as double;
        final totalAssignments = data['total_assignments'] as int;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'grade_statistics'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getGradeColor(overallAvg).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: _getGradeColor(overallAvg),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'overall_average'.tr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${overallAvg.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: _getGradeColor(overallAvg),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getGradeColor(overallAvg),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getGradeLetter(overallAvg),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'homework'.tr,
                        '${homeworkAvg.toStringAsFixed(1)}%',
                        Colors.blue,
                        Icons.assignment,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'exams'.tr,
                        '${examAvg.toStringAsFixed(1)}%',
                        Colors.orange,
                        Icons.quiz,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assessment, color: Get.theme.colorScheme.onSurface),
                      const SizedBox(width: 8),
                      Text(
                        '${'total_grades'.tr}: $totalAssignments',
                        style: TextStyle(
                          color: Get.theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesList(ParentController controller,  BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      final gradesData = controller.currentChildGrades.value;
      if (gradesData == null) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.grade, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'grade_info_not_found'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final homeworkGrades = gradesData['homework_grades'] as List<dynamic>;
      final examGrades = gradesData['exam_grades'] as List<dynamic>;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (homeworkGrades.isNotEmpty) ...[
            _buildGradesSection('homework_grades'.tr, homeworkGrades, Icons.assignment, Colors.blue, context),
            const SizedBox(height: 16),
          ],
          if (examGrades.isNotEmpty) ...[
            _buildGradesSection('exam_grades'.tr, examGrades, Icons.quiz, Colors.orange, context),
          ],
        ],
      );
    });
  }

  Widget _buildGradesSection(String title, List<dynamic> grades, IconData icon, Color color, BuildContext context) {
    final sortedGrades = List.from(grades)
      ..sort((a, b) => DateTime.parse(b['graded_at']).compareTo(DateTime.parse(a['graded_at'])));

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),

                  ),
                ),
              ],
            ),
          ),
          ...sortedGrades.map((grade) => _buildGradeItem(grade)),
        ],
      ),
    );
  }

  Widget _buildGradeItem(Map<String, dynamic> grade) {
    final title = grade['homework_title'] ?? grade['exam_title'] ?? 'Unknown';
    final subject = grade['subject'] as String;
    final points = grade['points'] as int;
    final maxPoints = grade['max_points'] as int;
    final percentage = grade['percentage'] as double;
    final comment = grade['comment'] as String? ?? '';
    final gradedAt = DateTime.parse(grade['graded_at']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!,width: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subject,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getGradeColor(percentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getGradeColor(percentage).withOpacity(0.3)),
                ),
                child: Text(
                  '$points/$maxPoints',
                  style: TextStyle(
                    color: _getGradeColor(percentage),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getGradeColor(percentage),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.comment, size: 14, color: Get.theme.colorScheme.onSurface),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      comment,
                      style: TextStyle(
                        color: Get.theme.colorScheme.onSurface,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            _formatDate(gradedAt),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.blue;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 60) return Colors.deepOrange;
    return Colors.red;
  }

  String _getGradeLetter(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  String _formatDate(DateTime date) {
    final months = [
      'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr, 'may'.tr, 'june'.tr,
      'july'.tr, 'august'.tr, 'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr
    ];

    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}