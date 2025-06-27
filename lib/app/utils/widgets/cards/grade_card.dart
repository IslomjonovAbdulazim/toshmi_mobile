import 'package:flutter/material.dart';
import 'package:toshmi_mobile/app/utils/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';

class GradeCard extends StatelessWidget {
  final dynamic grade; // HomeworkGrade or ExamGrade
  final String assignmentTitle;
  final String subjectName;
  final int maxPoints;
  final String type; // 'homework' or 'exam'
  final VoidCallback? onTap;

  const GradeCard({
    super.key,
    required this.grade,
    required this.assignmentTitle,
    required this.subjectName,
    required this.maxPoints,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final points = grade.points as int;
    final comment = grade.comment as String;
    final gradedAt = grade.gradedAt as DateTime;
    final percentage = (points / maxPoints * 100);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildGradeCircle(points, maxPoints, percentage),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignmentTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subjectName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildTypeChip(),
                ],
              ),

              const SizedBox(height: 12),

              // Grade details
              Row(
                children: [
                  Icon(
                    Icons.grade,
                    size: 16,
                    color: _getGradeColor(percentage),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$points/$maxPoints ball (${percentage.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getGradeColor(percentage),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildGradeLabel(percentage),
                ],
              ),

              const SizedBox(height: 8),

              // Graded date
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Baholangan: ${gradedAt.formatDate}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              if (comment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.comment,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'O\'qituvchi izohi:',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeCircle(int points, int maxPoints, double percentage) {
    final color = _getGradeColor(percentage);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          '${percentage.toInt()}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    final isHomework = type == 'homework';
    final color = isHomework ? AppColors.info : AppColors.secondaryOrange;
    final icon = isHomework ? Icons.assignment : Icons.quiz;
    final text = isHomework ? 'Vazifa' : 'Imtihon';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeLabel(double percentage) {
    String label;
    Color color = _getGradeColor(percentage);

    if (percentage >= 90) {
      label = 'A\'lo';
    } else if (percentage >= 75) {
      label = 'Yaxshi';
    } else if (percentage >= 60) {
      label = 'Qoniqarli';
    } else {
      label = 'Qoniqarsiz';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getGradeColor(double percentage) {
    return AppColors.getGradeColor(percentage);
  }
}