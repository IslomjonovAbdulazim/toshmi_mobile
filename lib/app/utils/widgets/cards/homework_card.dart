import 'package:flutter/material.dart';
import '../../extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/models/homework_model.dart';

class HomeworkCard extends StatelessWidget {
  final Homework homework;
  final String? subjectName;
  final String? teacherName;
  final HomeworkGrade? grade;
  final VoidCallback? onTap;

  const HomeworkCard({
    super.key,
    required this.homework,
    this.subjectName,
    this.teacherName,
    this.grade,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = homework.dueDate.isBefore(DateTime.now());
    final isDueSoon = homework.dueDate.difference(DateTime.now()).inDays <= 1 && !isOverdue;

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
                  _buildHomeworkIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homework.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subjectName != null)
                          Text(
                            subjectName!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (grade != null) _buildGradeChip(),
                ],
              ),

              const SizedBox(height: 12),

              // Due date
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: _getDueDateColor(isOverdue, isDueSoon),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Muddati: ${homework.dueDate.formatDate} ${homework.dueDate.formatTime}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getDueDateColor(isOverdue, isDueSoon),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(isOverdue, isDueSoon),
                ],
              ),

              if (teacherName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      teacherName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Additional info
              Row(
                children: [
                  _buildInfoChip(
                    Icons.star,
                    '${homework.maxPoints} ball',
                    AppColors.primaryBlue,
                  ),
                  if (homework.documentIds.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.attach_file,
                      '${homework.documentIds.length} fayl',
                      AppColors.secondaryOrange,
                    ),
                  ],
                  if (homework.externalLinks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.link,
                      '${homework.externalLinks.length} havola',
                      AppColors.info,
                    ),
                  ],
                ],
              ),

              if (homework.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  homework.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Relative time indicator
              const SizedBox(height: 8),
              Text(
                homework.dueDate.relativeTime,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _getDueDateColor(isOverdue, isDueSoon),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeworkIcon() {
    IconData icon;
    Color color;

    if (grade != null) {
      icon = Icons.check_circle;
      color = AppColors.success;
    } else if (homework.dueDate.isBefore(DateTime.now())) {
      icon = Icons.warning;
      color = AppColors.error;
    } else {
      icon = Icons.assignment;
      color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildGradeChip() {
    final percentage = (grade!.points / homework.maxPoints * 100);
    final color = AppColors.getGradeColor(percentage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${grade!.points}/${homework.maxPoints}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isOverdue, bool isDueSoon) {
    String text;
    Color color;

    if (grade != null) {
      text = 'Baholangan';
      color = AppColors.success;
    } else if (isOverdue) {
      text = 'Muddati o\'tgan';
      color = AppColors.error;
    } else if (isDueSoon) {
      text = homework.dueDate.isToday ? 'Bugun' : 'Ertaga';
      color = AppColors.warning;
    } else {
      text = 'Kelayotgan';
      color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDueDateColor(bool isOverdue, bool isDueSoon) {
    if (isOverdue) return AppColors.error;
    if (isDueSoon) return AppColors.warning;
    return AppColors.info;
  }
}