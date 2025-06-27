import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../../services/file_service.dart';
import '../../helpers/permission_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerBottomSheet extends StatelessWidget {
  final bool allowImages;
  final bool allowDocuments;
  final List<String>? allowedExtensions;

  const FilePickerBottomSheet({
    super.key,
    this.allowImages = true,
    this.allowDocuments = true,
    this.allowedExtensions,
  });

  @override
  Widget build(BuildContext context) {
    final fileService = Get.find<FileService>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fayl tanlash',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (allowImages) ...[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              subtitle: const Text('Rasm olish'),
              onTap: () => _pickImage(ImageSource.camera, fileService),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriya'),
              subtitle: const Text('Rasmni tanlash'),
              onTap: () => _pickImage(ImageSource.gallery, fileService),
            ),
          ],
          if (allowDocuments) ...[
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Hujjat'),
              subtitle: const Text('Fayl tanlash'),
              onTap: () => _pickDocument(fileService),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, FileService fileService) async {
    try {
      // Check permissions
      if (source == ImageSource.camera) {
        final hasPermission = await PermissionHelper.requestCameraPermission();
        if (!hasPermission) return;
      } else {
        final hasPermission = await PermissionHelper.requestStoragePermission();
        if (!hasPermission) return;
      }

      final file = await fileService.pickImage(source: source);
      if (file != null) {
        // Validate file
        if (!fileService.isValidImageFormat(file)) {
          Get.snackbar('Xatolik', 'Noto\'g\'ri fayl formati');
          return;
        }

        if (!fileService.isValidFileSize(file, 3)) { // 3MB limit for images
          Get.snackbar('Xatolik', 'Fayl hajmi 3MB dan oshmasligi kerak');
          return;
        }

        Get.back(result: file);
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'Rasm tanlashda xatolik: $e');
    }
  }

  Future<void> _pickDocument(FileService fileService) async {
    try {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) return;

      final file = await fileService.pickFile(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'],
      );

      if (file != null) {
        // Validate file size
        if (!fileService.isValidFileSize(file, 10)) { // 10MB limit for documents
          Get.snackbar('Xatolik', 'Fayl hajmi 10MB dan oshmasligi kerak');
          return;
        }

        Get.back(result: file);
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'Hujjat tanlashda xatolik: $e');
    }
  }
}