// lib/app/modules/teacher/views/grading/widgets/grading_table.dart
import 'package:flutter/material.dart';
import 'grade_input_cell.dart';

class GradingTable extends StatelessWidget {
  final Map<String, dynamic> gradingData;
  final bool isReadOnly;
  final Map<int, Map<String, dynamic>> grades;
  final Function(int studentId, int? points, String comment)? onGradeChanged;

  const GradingTable({
    super.key,
    required this.gradingData,
    this.isReadOnly = false,
    required this.grades,
    this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final students = gradingData['students'] as List<dynamic>? ?? [];
    final assignment = gradingData['homework'] ?? gradingData['exam'] ?? {};

    if (students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No Students Found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme, assignment, students.length),
        const SizedBox(height: 16),
        _buildGradingProgress(theme, students.length),
        const SizedBox(height: 16),
        _buildStudentsList(students),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, Map<String, dynamic> assignment, int studentCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assignment['title'] ?? 'Assignment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Max Points: ${assignment['max_points'] ?? 0}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Students: $studentCount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradingProgress(ThemeData theme, int totalStudents) {
    final gradedCount = grades.values.where((grade) => grade['points'] != null).length;
    final progress = totalStudents > 0 ? gradedCount / totalStudents : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grading Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$gradedCount/$totalStudents',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList(List<dynamic> students) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final studentId = student['student_id'] as int;

        // Merge existing grade with current changes
        final existingGrade = student['grade'] as Map<String, dynamic>? ?? {};
        final currentGrade = grades[studentId] ?? {};
        final Map<String, dynamic> mergedStudent = {
          ...student,
          'grade': {...existingGrade, ...currentGrade},
        };

        return GradeInputCell(
          student: mergedStudent,
          maxPoints: (gradingData['homework'] ?? gradingData['exam'])['max_points'] ?? 100,
          isReadOnly: isReadOnly,
          onChanged: onGradeChanged,
        );
      },
    );
  }
}