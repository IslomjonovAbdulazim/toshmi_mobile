import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_themes.dart';

/// Custom error widget with theming support
class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String? message;
  final String? details;
  final Widget? icon;
  final String? retryText;
  final VoidCallback? onRetry;
  final String? dismissText;
  final VoidCallback? onDismiss;
  final EdgeInsets padding;
  final bool showDetails;
  final Color? backgroundColor;
  final ErrorType errorType;

  const CustomErrorWidget({
    super.key,
    required this.title,
    this.message,
    this.details,
    this.icon,
    this.retryText,
    this.onRetry,
    this.dismissText,
    this.onDismiss,
    this.padding = const EdgeInsets.all(24),
    this.showDetails = false,
    this.backgroundColor,
    this.errorType = ErrorType.general,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getErrorColor(colors).withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getErrorColor(colors).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: icon ?? Icon(
              _getErrorIcon(),
              size: 48,
              color: _getErrorColor(colors),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),

          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Expandable details
          if (details != null && showDetails) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text(
                'Texnik ma\'lumotlar',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    details!,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: colors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action buttons
          if (onRetry != null || onDismiss != null) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onDismiss != null) ...[
                  OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.secondaryText,
                      side: BorderSide(color: colors.secondaryText),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(dismissText ?? 'Yopish'),
                  ),
                  if (onRetry != null) const SizedBox(width: 12),
                ],
                if (onRetry != null) ...[
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getErrorColor(colors),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(retryText ?? 'Qayta urinish'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getErrorColor(AppThemeColors colors) {
    return switch (errorType) {
      ErrorType.network => colors.warning,
      ErrorType.server => colors.error,
      ErrorType.validation => colors.warning,
      ErrorType.permission => colors.error,
      ErrorType.general => colors.error,
    };
  }

  IconData _getErrorIcon() {
    return switch (errorType) {
      ErrorType.network => Icons.wifi_off_outlined,
      ErrorType.server => Icons.error_outline,
      ErrorType.validation => Icons.warning_outlined,
      ErrorType.permission => Icons.lock_outline,
      ErrorType.general => Icons.error_outline,
    };
  }
}

/// Error types for different scenarios
enum ErrorType {
  general,
  network,
  server,
  validation,
  permission,
}

/// Inline error widget for forms and small spaces
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;
  final EdgeInsets padding;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.icon,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final errorColor = color ?? colors.error;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 16,
            color: errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen error page
class ErrorPage extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorPage({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: colors.error,
                ),

                const SizedBox(height: 24),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.secondaryText,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onGoHome != null) ...[
                      OutlinedButton(
                        onPressed: onGoHome,
                        child: const Text('Bosh sahifa'),
                      ),
                      if (onRetry != null) const SizedBox(width: 16),
                    ],
                    if (onRetry != null) ...[
                      ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.info,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Qayta urinish'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pre-configured error widgets for common scenarios
class ErrorWidgets {
  /// Network connection error
  static Widget networkError({VoidCallback? onRetry}) {
    return CustomErrorWidget(
      title: 'Internet aloqasi yo\'q',
      message: 'Internet aloqasini tekshiring va qayta urinib ko\'ring.',
      errorType: ErrorType.network,
      onRetry: onRetry,
      retryText: 'Qayta urinish',
    );
  }

  /// Server error
  static Widget serverError({VoidCallback? onRetry}) {
    return CustomErrorWidget(
      title: 'Server xatosi',
      message: 'Serverda muammo yuz berdi. Iltimos, keyinroq qayta urinib ko\'ring.',
      errorType: ErrorType.server,
      onRetry: onRetry,
      retryText: 'Qayta yuklash',
    );
  }

  /// Authentication error
  static Widget authError({VoidCallback? onLogin}) {
    return CustomErrorWidget(
      title: 'Avtorizatsiya xatosi',
      message: 'Hisobingizga kirishda muammo yuz berdi. Qayta kirish talab etiladi.',
      errorType: ErrorType.permission,
      onRetry: onLogin,
      retryText: 'Qayta kirish',
    );
  }

  /// Validation error
  static Widget validationError(String message, {VoidCallback? onDismiss}) {
    return CustomErrorWidget(
      title: 'Ma\'lumot xatosi',
      message: message,
      errorType: ErrorType.validation,
      onDismiss: onDismiss,
      dismissText: 'Tushundim',
    );
  }

  /// Permission denied error
  static Widget permissionDenied({VoidCallback? onContactSupport}) {
    return CustomErrorWidget(
      title: 'Ruxsat rad etildi',
      message: 'Bu amalni bajarish uchun sizda yetarli ruxsat yo\'q.',
      errorType: ErrorType.permission,
      onRetry: onContactSupport,
      retryText: 'Yordam so\'rash',
    );
  }

  /// File operation error
  static Widget fileError({VoidCallback? onRetry}) {
    return CustomErrorWidget(
      title: 'Fayl xatosi',
      message: 'Faylni yuklash yoki saqlashda xatolik yuz berdi.',
      errorType: ErrorType.general,
      onRetry: onRetry,
      retryText: 'Qayta urinish',
    );
  }
}

/// Error snackbar helper
class ErrorSnackBar {
  static void show(String message, {String? title, VoidCallback? onRetry}) {
    Get.snackbar(
      title ?? 'Xatolik',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
      mainButton: onRetry != null
          ? TextButton(
        onPressed: onRetry,
        child: const Text(
          'Qayta urinish',
          style: TextStyle(color: Colors.white),
        ),
      )
          : null,
    );
  }
}