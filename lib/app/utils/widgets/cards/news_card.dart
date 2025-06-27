import 'package:flutter/material.dart';
import 'package:toshmi_mobile/app/utils/extensions/datetime_extensions.dart';
import 'package:toshmi_mobile/app/utils/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../data/models/news_model.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final String? authorName;
  final VoidCallback? onTap;
  final bool showFullContent;

  const NewsCard({
    super.key,
    required this.news,
    this.authorName,
    this.onTap,
    this.showFullContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and publication status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      news.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!news.isPublished)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Qoralama',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Author and date info
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    authorName ?? 'Noma\'lum muallif',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    news.createdAt.relativeTime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Content
              Text(
                showFullContent ? news.content : news.content.truncate(150),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              // Show "Read more" if content is truncated
              if (!showFullContent && news.content.length > 150) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Batafsil o\'qish...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Additional info (links, images)
              Row(
                children: [
                  if (news.imageIds.isNotEmpty) ...[
                    _buildInfoChip(
                      Icons.image,
                      '${news.imageIds.length} rasm',
                      AppColors.success,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (news.externalLinks.isNotEmpty) ...[
                    _buildInfoChip(
                      Icons.link,
                      '${news.externalLinks.length} havola',
                      AppColors.info,
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Text(
                    news.createdAt.formatDate,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Show first image if available
              if (news.imageIds.isNotEmpty && showFullContent) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ],

              // External links
              if (news.externalLinks.isNotEmpty && showFullContent) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foydali havolalar:',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...news.externalLinks.take(3).map((link) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: GestureDetector(
                        onTap: () {
                          // Handle link tap
                        },
                        child: Text(
                          link.truncate(50),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ],
          ),
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
}