import 'package:get/get.dart';
import 'package:flutter/material.dart';

abstract class BaseController extends GetxController {
  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  // Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Network state
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    ever(hasError, _handleErrorState);
  }

  // Loading methods
  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  void setRefreshing(bool refreshing) {
    isRefreshing.value = refreshing;
  }

  // Error handling methods
  void setError(String message) {
    errorMessage.value = message;
    hasError.value = true;
    isLoading.value = false;
    isRefreshing.value = false;
  }

  void clearError() {
    errorMessage.value = '';
    hasError.value = false;
  }

  void _handleErrorState(bool hasErrorState) {
    if (hasErrorState && errorMessage.value.isNotEmpty) {
      showError(errorMessage.value);
    }
  }

  // Common UI methods
  void showSuccess(String message) {
    Get.snackbar(
      'Muvaffaqiyat',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  void showError(String message) {
    Get.snackbar(
      'Xatolik',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
  }

  void showWarning(String message) {
    Get.snackbar(
      'Ogohlantirish',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  void showInfo(String message) {
    Get.snackbar(
      'Ma\'lumot',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  // Common navigation methods
  void goBack() {
    Get.back();
  }

  void navigateTo(String route, {dynamic arguments}) {
    Get.toNamed(route, arguments: arguments);
  }

  void navigateAndReplace(String route, {dynamic arguments}) {
    Get.offNamed(route, arguments: arguments);
  }

  void navigateAndClearStack(String route, {dynamic arguments}) {
    Get.offAllNamed(route, arguments: arguments);
  }

  // Common dialog methods
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Tasdiqlash',
    String cancelText = 'Bekor qilish',
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void showLoadingDialog({String message = 'Yuklanmoqda...'}) {
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  // Network handling
  void setNetworkState(bool online) {
    isOnline.value = online;
    if (!online) {
      showError('Internet aloqasi yo\'q');
    }
  }

  // Common data operations
  Future<T?> handleAsyncOperation<T>(
      Future<T> operation, {
        bool showLoading = true,
        String? loadingMessage,
        String? successMessage,
        bool showSuccessMessage = false,
      }) async {
    try {
      if (showLoading) {
        if (loadingMessage != null) {
          showLoadingDialog(message: loadingMessage);
        } else {
          setLoading(true);
        }
      }

      clearError();
      final result = await operation;

      if (showSuccessMessage && successMessage != null) {
        showSuccess(successMessage);
      }

      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      if (showLoading) {
        if (loadingMessage != null) {
          hideLoadingDialog();
        } else {
          setLoading(false);
        }
      }
    }
  }

  // Refresh functionality
  Future<void> onRefresh() async {
    setRefreshing(true);
    try {
      await refreshData();
    } finally {
      setRefreshing(false);
    }
  }

  // Abstract method for child controllers to implement
  Future<void> refreshData();

  @override
  void dispose() {
    // Clean up subscriptions
    super.dispose();
  }
}