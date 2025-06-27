import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionHelper {
  // Check camera permission
  static Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      _showSettingsDialog('Kamera ruxsati');
      return false;
    }
    return status.isGranted;
  }

  // Check storage permission
  static Future<bool> checkStoragePermission() async {
    if (GetPlatform.isAndroid) {
      return await Permission.storage.isGranted;
    }
    return await Permission.photos.isGranted;
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    Permission permission = GetPlatform.isAndroid
        ? Permission.storage
        : Permission.photos;

    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      _showSettingsDialog('Xotira ruxsati');
      return false;
    }
    return status.isGranted;
  }

  // Check notification permission
  static Future<bool> checkNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Check microphone permission
  static Future<bool> checkMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  // Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      _showSettingsDialog('Mikrofon ruxsati');
      return false;
    }
    return status.isGranted;
  }

  // Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Show settings dialog
  static void _showSettingsDialog(String permissionName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Ruxsat kerak'),
        content: Text('$permissionName kerak. Sozlamalarga o\'ting va ruxsat bering.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Sozlamalar'),
          ),
        ],
      ),
    );
  }

  // Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions,
      ) async {
    return await permissions.request();
  }

  // Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
}