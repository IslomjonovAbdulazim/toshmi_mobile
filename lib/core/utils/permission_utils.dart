import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      print('PermissionUtils: Requesting storage permission');
      final status = await Permission.storage.request();
      final granted = status.isGranted;
      print('PermissionUtils: Storage permission ${granted ? 'granted' : 'denied'}');
      return granted;
    } catch (e) {
      print('PermissionUtils: Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      print('PermissionUtils: Requesting camera permission');
      final status = await Permission.camera.request();
      final granted = status.isGranted;
      print('PermissionUtils: Camera permission ${granted ? 'granted' : 'denied'}');
      return granted;
    } catch (e) {
      print('PermissionUtils: Error requesting camera permission: $e');
      return false;
    }
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      print('PermissionUtils: Requesting notification permission');
      final status = await Permission.notification.request();
      final granted = status.isGranted;
      print('PermissionUtils: Notification permission ${granted ? 'granted' : 'denied'}');
      return granted;
    } catch (e) {
      print('PermissionUtils: Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      final granted = status.isGranted;
      print('PermissionUtils: Storage permission status: $granted');
      return granted;
    } catch (e) {
      print('PermissionUtils: Error checking storage permission: $e');
      return false;
    }
  }

  /// Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      final granted = status.isGranted;
      print('PermissionUtils: Camera permission status: $granted');
      return granted;
    } catch (e) {
      print('PermissionUtils: Error checking camera permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      final granted = status.isGranted;
      print('PermissionUtils: Notification permission status: $granted');
      return granted;
    } catch (e) {
      print('PermissionUtils: Error checking notification permission: $e');
      return false;
    }
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      print('PermissionUtils: Opening app settings');
      final opened = await openAppSettings();
      print('PermissionUtils: App settings ${opened ? 'opened' : 'failed to open'}');
      return opened;
    } catch (e) {
      print('PermissionUtils: Error opening app settings: $e');
      return false;
    }
  }

  /// Get permission status in Uzbek
  static String getPermissionStatusUz(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Ruxsat berilgan';
      case PermissionStatus.denied:
        return 'Ruxsat berilmagan';
      case PermissionStatus.restricted:
        return 'Cheklangan';
      case PermissionStatus.limited:
        return 'Cheklangan ruxsat';
      case PermissionStatus.permanentlyDenied:
        return 'Butunlay rad etilgan';
      case PermissionStatus.provisional:
        return 'Vaqtinchalik ruxsat';
      default:
        return 'Noma\'lum holat';
    }
  }

  /// Show permission dialog for storage
  static Future<bool> showStoragePermissionDialog(BuildContext context) async {
    return await _showPermissionDialog(
      context,
      title: 'Fayl saqlash ruxsati',
      message: 'Fayllarni saqlash va yuklash uchun fayl tizimiga kirish ruxsati kerak.',
      permission: Permission.storage,
    );
  }

  /// Show permission dialog for camera
  static Future<bool> showCameraPermissionDialog(BuildContext context) async {
    return await _showPermissionDialog(
      context,
      title: 'Kamera ruxsati',
      message: 'Rasm olish uchun kameraga kirish ruxsati kerak.',
      permission: Permission.camera,
    );
  }

  /// Show permission dialog for notifications
  static Future<bool> showNotificationPermissionDialog(BuildContext context) async {
    return await _showPermissionDialog(
      context,
      title: 'Bildirishnoma ruxsati',
      message: 'Muhim yangiliklar haqida xabar berish uchun bildirishnoma ruxsati kerak.',
      permission: Permission.notification,
    );
  }

  /// Show settings dialog when permission is permanently denied
  static Future<bool> showSettingsDialog(BuildContext context, String permissionName) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ruxsat kerak'),
        content: Text('$permissionName uchun ruxsat kerak. Iltimos, sozlamalarga o\'tib ruxsat bering.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              openAppSettings();
            },
            child: const Text('Sozlamalar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Check multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> checkMultiplePermissions(
      List<Permission> permissions,
      ) async {
    try {
      print('PermissionUtils: Checking multiple permissions: ${permissions.length}');
      final statuses = await permissions.request();

      for (final entry in statuses.entries) {
        print('PermissionUtils: ${entry.key}: ${getPermissionStatusUz(entry.value)}');
      }

      return statuses;
    } catch (e) {
      print('PermissionUtils: Error checking multiple permissions: $e');
      return {};
    }
  }

  /// Request all necessary app permissions
  static Future<bool> requestAllAppPermissions() async {
    try {
      print('PermissionUtils: Requesting all app permissions');

      final permissions = [
        Permission.storage,
        Permission.notification,
      ];

      final statuses = await checkMultiplePermissions(permissions);

      // Check if all permissions are granted
      final allGranted = statuses.values.every((status) => status.isGranted);

      print('PermissionUtils: All permissions granted: $allGranted');
      return allGranted;
    } catch (e) {
      print('PermissionUtils: Error requesting all permissions: $e');
      return false;
    }
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(Permission permission) async {
    try {
      final status = await permission.status;
      final isPermanentlyDenied = status.isPermanentlyDenied;
      print('PermissionUtils: Permission $permission permanently denied: $isPermanentlyDenied');
      return isPermanentlyDenied;
    } catch (e) {
      print('PermissionUtils: Error checking if permission permanently denied: $e');
      return false;
    }
  }

  /// Handle permission result and show appropriate message
  static Future<bool> handlePermissionResult(
      BuildContext context,
      Permission permission,
      String permissionNameUz,
      ) async {
    try {
      final status = await permission.status;

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        return await showSettingsDialog(context, permissionNameUz);
      } else {
        // Try to request permission
        final newStatus = await permission.request();
        return newStatus.isGranted;
      }
    } catch (e) {
      print('PermissionUtils: Error handling permission result: $e');
      return false;
    }
  }

  /// Get permission explanation in Uzbek
  static String getPermissionExplanationUz(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'Bu ruxsat fayllarni yuklab olish va saqlash uchun kerak.';
      case Permission.camera:
        return 'Bu ruxsat profil rasmini yangilash uchun kerak.';
      case Permission.notification:
        return 'Bu ruxsat muhim xabarlar haqida sizni xabardor qilish uchun kerak.';
      default:
        return 'Bu ruxsat ilovaning to\'g\'ri ishlashi uchun kerak.';
    }
  }

  /// Show permission rationale dialog
  static Future<bool> showPermissionRationale(
      BuildContext context,
      Permission permission,
      String title,
      ) async {
    final explanation = getPermissionExplanationUz(permission);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Yo\'q'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ruxsat berish'),
          ),
        ],
      ),
    );

    if (result == true) {
      final status = await permission.request();
      return status.isGranted;
    }

    return false;
  }

  /// Private helper method for showing permission dialog
  static Future<bool> _showPermissionDialog(
      BuildContext context, {
        required String title,
        required String message,
        required Permission permission,
      }) async {
    // First check if permission is already granted
    if (await permission.status.isGranted) {
      return true;
    }

    // If permanently denied, show settings dialog
    if (await permission.status.isPermanentlyDenied) {
      return await showSettingsDialog(context, title);
    }

    // Show rationale dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ruxsat berish'),
          ),
        ],
      ),
    );

    if (result == true) {
      final status = await permission.request();
      return status.isGranted;
    }

    return false;
  }
}