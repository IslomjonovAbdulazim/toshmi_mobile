import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../controllers/file_controller.dart';

class FileViewer extends GetView<FileController> {
  final File file;
  final String title;

  const FileViewer({
    super.key,
    required this.file,
    this.title = 'Fayl ko\'rish',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareFile(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadFile(),
          ),
        ],
      ),
      body: _buildFileContent(),
    );
  }

  Widget _buildFileContent() {
    final extension = file.path.split('.').last.toLowerCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // File icon and info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildFileIcon(extension),
                const SizedBox(height: 16),
                Text(
                  file.path.split('/').last,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  controller.getFileSize(file),
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // File actions
          if (_isImage(extension)) ...[
            ElevatedButton.icon(
              onPressed: () => _previewImage(),
              icon: const Icon(Icons.visibility),
              label: const Text('Rasmni ko\'rish'),
            ),
            const SizedBox(height: 16),
          ],

          OutlinedButton.icon(
            onPressed: () => _openFile(),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Tashqi dasturda ochish'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String extension) {
    IconData icon;
    Color color;

    if (_isImage(extension)) {
      icon = Icons.image;
      color = AppColors.success;
    } else if (_isDocument(extension)) {
      icon = Icons.description;
      color = AppColors.primaryBlue;
    } else if (_isPdf(extension)) {
      icon = Icons.picture_as_pdf;
      color = AppColors.error;
    } else {
      icon = Icons.insert_drive_file;
      color = AppColors.secondaryOrange;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }

  bool _isImage(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  bool _isDocument(String extension) {
    return ['doc', 'docx', 'txt'].contains(extension);
  }

  bool _isPdf(String extension) {
    return extension == 'pdf';
  }

  void _shareFile() {
    // Implement file sharing
    Get.snackbar('Ma\'lumot', 'Fayl ulashish funksiyasi');
  }

  void _downloadFile() {
    // Implement file download
    Get.snackbar('Ma\'lumot', 'Fayl yuklab olish funksiyasi');
  }

  void _previewImage() {
    // Implement image preview
    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: Image.file(file, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _openFile() {
    // Implement open in external app
    Get.snackbar('Ma\'lumot', 'Tashqi dasturda ochish funksiyasi');
  }
}