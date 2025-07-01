// lib/app/modules/teacher/views/exams/widgets/exam_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class ExamCard extends StatelessWidget {
  final Map<String, dynamic> exam;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onGrade;

  const ExamCard({
    super.key,
    required this.exam,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final examDate = DateTime.parse(exam['exam_date']);
    final isPast = examDate.isBefore(DateTime.now());
    final daysDiff = examDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: isDark ? 1 : 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['title'] ?? 'untitled_exam'.tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (exam['subject'] != null || exam['group'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.subject,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              if (exam['subject'] != null)
                                Text(
                                  exam['subject'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              if (exam['subject'] != null && exam['group'] != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '•',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (exam['group'] != null) ...[
                                Icon(
                                  Icons.group,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  exam['group'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isPast && daysDiff >= 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDaysColor(daysDiff).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$daysDiff ${'days'.tr}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getDaysColor(daysDiff),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      _buildStatusChip(theme),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: _getDateColor(isPast, daysDiff),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(examDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getDateColor(isPast, daysDiff),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildInfoChip(
                    Icons.star,
                    '${exam['max_points'] ?? 100} ${'points'.tr}',
                    theme.colorScheme.primary,
                  ),
                  if (exam['external_links'] != null && (exam['external_links'] as List).isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.link,
                      '${(exam['external_links'] as List).length} ${'links'.tr}',
                      theme.colorScheme.secondary,
                    ),
                  ],
                ],
              ),

              if (exam['description'] != null && exam['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  exam['description'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text('edit'.tr),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onGrade,
                      icon: const Icon(Icons.star, size: 16),
                      label: Text('grade'.tr),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    style: IconButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    final isGraded = _isGraded();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGraded
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isGraded ? 'graded_status'.tr : 'not_graded_status'.tr,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isGraded ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isGraded() {
    return exam['graded_count'] != null && exam['graded_count'] > 0;
  }

  Color _getDaysColor(int daysDiff) {
    if (daysDiff <= 1) return Colors.red;
    if (daysDiff <= 3) return Colors.orange;
    return Colors.blue;
  }

  Color _getDateColor(bool isPast, int daysDiff) {
    if (isPast) return Colors.red;
    if (daysDiff <= 1) return Colors.orange;
    if (daysDiff <= 7) return Colors.blue;
    return Colors.grey;
  }

  String _formatDateTime(DateTime dateTime) {
    final date = DateFormat('dd.MM.yyyy').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);
    return '$date $time';
  }
}