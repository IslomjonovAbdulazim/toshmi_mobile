import 'package:flutter/material.dart';
import 'package:toshmi_mobile/app/utils/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/models/grade_model.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final String? subjectName;
  final String? teacherName;
  final ExamGrade? grade;
  final VoidCallback? onTap;

  const ExamCard({
    super.key,
    required this.exam,
    this.subjectName,
    this.teacherName,
    this.grade,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = exam.examDate.isAfter(DateTime.now());
    final isPast = exam.examDate.isBefore(DateTime.now());

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
                  _buildExamIcon(isUpcoming, isPast),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
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

              // Exam date and time
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: _getDateColor(isUpcoming, isPast),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${exam.examDate.formatDate} ${exam.examDate.formatTime}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getDateColor(isUpcoming, isPast),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(isUpcoming, isPast),
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
                    '${exam.maxPoints} ball',
                    AppColors.primaryBlue,
                  ),
                  if (exam.documentIds.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.attach_file,
                      '${exam.documentIds.length} fayl',
                      AppColors.secondaryOrange,
                    ),
                  ],
                  if (exam.externalLinks.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.link,
                      '${exam.externalLinks.length} havola',
                      AppColors.info,
                    ),
                  ],
                ],
              ),

              if (exam.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  exam.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamIcon(bool isUpcoming, bool isPast) {
    IconData icon;
    Color color;

    if (grade != null) {
      icon = Icons.check_circle;
      color = AppColors.success;
    } else if (isUpcoming) {
      icon = Icons.schedule;
      color = AppColors.warning;
    } else {
      icon = Icons.quiz;
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
    final percentage = (grade!.points / exam.maxPoints * 100);
    final color = AppColors.getGradeColor(percentage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${grade!.points}/${exam.maxPoints}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isUpcoming, bool isPast) {
    String text;
    Color color;

    if (grade != null) {
      text = 'Baholangan';
      color = AppColors.success;
    } else if (isUpcoming) {
      text = exam.examDate.isToday ? 'Bugun' : 'Kelayotgan';
      color = exam.examDate.isToday ? AppColors.error : AppColors.warning;
    } else {
      text = 'O\'tgan';
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

  Color _getDateColor(bool isUpcoming, bool isPast) {
    if (exam.examDate.isToday) return AppColors.error;
    if (isUpcoming) return AppColors.warning;
    return AppColors.info;
  }
}