// lib/app/modules/teacher/views/homework/widgets/homework_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utils/validators/url_validator.dart';

class HomeworkCard extends StatelessWidget {
  final Map<String, dynamic> homework;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onGrade;

  const HomeworkCard({
    super.key,
    required this.homework,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onGrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dueDate = DateTime.parse(homework['due_date']);
    final isOverdue = dueDate.isBefore(DateTime.now());
    final daysDiff = dueDate.difference(DateTime.now()).inDays;

    final externalLinks = homework['external_links'] as List<dynamic>? ?? [];

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
              // Header with title and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homework['title'] ?? 'Untitled',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${homework['subject']} • ${homework['group']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(context, isOverdue, daysDiff),
                ],
              ),

              // Description (if exists)
              if (homework['description'] != null && homework['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  homework['description'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Due date and points info
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Muddati: ${DateFormat('MMM dd, yyyy HH:mm').format(dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.star_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${homework['max_points']} pts',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // External links section
              if (externalLinks.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildExternalLinksSection(context, externalLinks),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child:                     OutlinedButton.icon(
                      onPressed: onGrade,
                      icon: const Icon(Icons.grade, size: 18),
                      label: const Text('Baholash'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Uy vazifasini tahrirlash',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Uy vazifasini o\'chirish',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
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

  Widget _buildStatusChip(BuildContext context, bool isOverdue, int daysDiff) {
    final theme = Theme.of(context);

    String text;
    Color backgroundColor;
    Color textColor;

    if (isOverdue) {
      text = 'Muddati o\'tgan';
      backgroundColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.error;
    } else if (daysDiff <= 1) {
      text = 'Tez topshirish';
      backgroundColor = theme.colorScheme.tertiaryContainer;
      textColor = theme.colorScheme.onTertiaryContainer;
    } else if (daysDiff <= 7) {
      text = '$daysDiff kun';
      backgroundColor = theme.colorScheme.secondaryContainer;
      textColor = theme.colorScheme.onSecondaryContainer;
    } else {
      text = '$daysDiff kun';
      backgroundColor = theme.colorScheme.surfaceVariant;
      textColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExternalLinksSection(BuildContext context, List<dynamic> links) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.link,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Tashqi havolalar (${links.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: links.take(3).map((link) => _buildLinkChip(context, link.toString())).toList(),
        ),
        if (links.length > 3) ...[
          const SizedBox(height: 4),
          Text(
            '+${links.length - 3} yana havolalar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLinkChip(BuildContext context, String link) {
    final theme = Theme.of(context);
    final isValid = UrlValidator.isValidUrl(link);
    final domain = UrlValidator.getUrlDomain(link);
    final isEducational = UrlValidator.isEducationalDomain(link);

    return GestureDetector(
      onTap: isValid ? () => _launchUrl(link) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isValid
              ? (isEducational
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer)
              : theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isValid
                ? (isEducational
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary)
                : theme.colorScheme.error,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isValid
                  ? (isEducational ? Icons.school : Icons.link)
                  : Icons.link_off,
              size: 12,
              color: isValid
                  ? (isEducational
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSecondaryContainer)
                  : theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                domain.length > 20 ? '${domain.substring(0, 20)}...' : domain,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isValid
                      ? (isEducational
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSecondaryContainer)
                      : theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // Could show a snackbar here if needed
    }
  }
}