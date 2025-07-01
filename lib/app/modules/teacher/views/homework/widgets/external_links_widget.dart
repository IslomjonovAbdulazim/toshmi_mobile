// lib/app/modules/teacher/views/homework/widgets/external_links_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utils/validators/url_validator.dart';

class ExternalLinksWidget extends StatelessWidget {
  final List<String> links;
  final bool isEditable;
  final Function(List<String>)? onLinksChanged;
  final String title;
  final String emptyMessage;

  const ExternalLinksWidget({
    super.key,
    required this.links,
    this.isEditable = false,
    this.onLinksChanged,
    this.title = 'Tashqi havolalar',
    this.emptyMessage = 'Tashqi havolalar qo\'shilmagan',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.link,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            if (links.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${links.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Links content
        if (links.isEmpty)
          _buildEmptyState(context)
        else
          _buildLinksList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            emptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksList(BuildContext context) {
    return Column(
      children: links.asMap().entries.map((entry) {
        final index = entry.key;
        final link = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildLinkItem(context, link, index),
        );
      }).toList(),
    );
  }

  Widget _buildLinkItem(BuildContext context, String link, int index) {
    final theme = Theme.of(context);
    final validationResult = UrlValidator.getValidationResult(link);
    final isValid = validationResult.isValid;
    final domain = validationResult.domain ?? UrlValidator.getUrlDomain(link);
    final isEducational = validationResult.isEducational;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? (isEducational
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2))
              : theme.colorScheme.error.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: _buildLinkIcon(theme, isValid, isEducational),
        title: Text(
          domain,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isValid
                ? theme.colorScheme.onSurface
                : theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              link,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isValid && validationResult.error != null) ...[
              const SizedBox(height: 2),
              Text(
                validationResult.error!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (isEducational) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Educational resource',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Copy link button
            IconButton(
              onPressed: () => _copyLink(context, link),
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Havolani nusxalash',
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
            ),

            // Open link button
            if (isValid)
              IconButton(
                onPressed: () => _launchUrl(context, link),
                icon: const Icon(Icons.open_in_new, size: 18),
                tooltip: 'Havolani ochish',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),

            // Remove link button (if editable)
            if (isEditable)
              IconButton(
                onPressed: () => _removeLink(index),
                icon: const Icon(Icons.delete_outline, size: 18),
                tooltip: 'Havolani o\'chirish',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLinkIcon(ThemeData theme, bool isValid, bool isEducational) {
    IconData iconData;
    Color iconColor;

    if (!isValid) {
      iconData = Icons.link_off;
      iconColor = theme.colorScheme.error;
    } else if (isEducational) {
      iconData = Icons.school;
      iconColor = theme.colorScheme.primary;
    } else {
      iconData = Icons.link;
      iconColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  void _copyLink(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Havola nusxalandi'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar(context, 'Bu havolani ochib bo\'lmadi');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Havolani ochishda xatolik: $e');
    }
  }

  void _removeLink(int index) {
    if (onLinksChanged != null) {
      final updatedLinks = List<String>.from(links);
      updatedLinks.removeAt(index);
      onLinksChanged!(updatedLinks);
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Compact version for use in cards
class CompactExternalLinksWidget extends StatelessWidget {
  final List<String> links;
  final int maxVisible;
  final VoidCallback? onViewAll;

  const CompactExternalLinksWidget({
    super.key,
    required this.links,
    this.maxVisible = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (links.isEmpty) return const SizedBox.shrink();

    final visibleLinks = links.take(maxVisible).toList();
    final hasMore = links.length > maxVisible;

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
              'Havolalar (${links.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: visibleLinks.map((link) => _buildCompactLinkChip(context, link)).toList(),
        ),
        if (hasMore) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onViewAll,
            child:             Text(
              '+${links.length - maxVisible} yana havolalar',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLinkChip(BuildContext context, String link) {
    final theme = Theme.of(context);
    final isValid = UrlValidator.isValidUrl(link);
    final domain = UrlValidator.getUrlDomain(link);
    final isEducational = UrlValidator.isEducationalDomain(link);

    return GestureDetector(
      onTap: isValid ? () => _launchUrl(context, link) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isValid
              ? (isEducational
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.secondaryContainer)
              : theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
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
            Text(
              domain.length > 15 ? '${domain.substring(0, 15)}...' : domain,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isValid
                    ? (isEducational
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSecondaryContainer)
                    : theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}