import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/exam_media_controller.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';

class ExamMediaView extends GetView<ExamMediaController> {
  const ExamMediaView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'exam_media'.tr,
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExamHeader(theme),
          _buildUploadSection(theme),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.examImages.isEmpty) {
                return _buildEmptyState(theme);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshImages,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: controller.examImages.length,
                  itemBuilder: (context, index) {
                    final image = controller.examImages[index];
                    return _buildImageCard(image, theme);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExamHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.studentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.studentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.quiz,
            color: AppColors.studentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.exam['title'] ?? 'Exam',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.studentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.exam['subject'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.studentColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(ThemeData theme) {
    return Obx(() => !controller.canEditImages ? const SizedBox.shrink() : Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_upload, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'upload_image'.tr,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${controller.remainingSlots.value} ${'remaining_slots'.tr}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: controller.isUploading.value || controller.remainingSlots.value <= 0 
                  ? null 
                  : controller.pickAndUploadImage,
              icon: controller.isUploading.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Text(
                controller.isUploading.value 
                    ? 'loading'.tr 
                    : 'upload_image'.tr,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildImageCard(Map<String, dynamic> image, ThemeData theme) {
    final imageUrl = '${ApiConstants.baseUrl}${image['image_url']}';
    
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Hero(
                  tag: 'image_${image['id']}',
                  child: GestureDetector(
                    onTap: () => controller.viewImage(image),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 32),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Image details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.storage,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.formatFileSize(image['file_size'] ?? 0),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.canEditImages)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              controller.viewImage(image);
                              break;
                            case 'delete':
                              controller.deleteImage(image);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                const Icon(Icons.visibility, size: 16),
                                const SizedBox(width: 8),
                                Text('view_image'.tr),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: theme.colorScheme.error),
                                const SizedBox(width: 8),
                                Text(
                                  'delete_image'.tr,
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 18,
                        onPressed: () => controller.viewImage(image),
                        icon: const Icon(Icons.visibility),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.formatUploadDate(image['uploaded_at'] ?? ''),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'no_images_uploaded'.tr,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'upload_first_image'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.pickAndUploadImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text('upload_image'.tr),
            ),
          ],
        ),
      ),
    );
  }
}