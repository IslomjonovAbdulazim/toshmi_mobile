import 'package:flutter/material.dart';
import 'package:toshmi_mobile/core/themes/app_themes.dart';

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
    Key? key,
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
  }) : super(key: key);

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

          // Error title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),

          // Error message
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

          // Error details (expandable)
          if (details != null && details!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: Text(
                'Batafsil ma\'lumot',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.secondaryText,
                ),
              ),
              initiallyExpanded: showDetails,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    details!,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: colors.tertiaryText,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action buttons
          if (onRetry != null || onDismiss != null) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onDismiss != null) ...[
                  TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.secondaryText,
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
    switch (errorType) {
      case ErrorType.network:
        return colors.warning;
      case ErrorType.server:
        return colors.error;
      case ErrorType.validation:
        return colors.warning;
      case ErrorType.permission:
        return colors.error;
      case ErrorType.general:
      default:
        return colors.error;
    }
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off_outlined;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.validation:
        return Icons.warning_outlined;
      case ErrorType.permission:
        return Icons.lock_outline;
      case ErrorType.general:
      default:
        return Icons.error_outline;
    }
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
    Key? key,
    required this.message,
    this.icon,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  }) : super(key: key);

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

/// Snackbar-style error notification
class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    Key? key,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) : super(
    key: key,
    content: Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Colors.red[600],
    duration: duration,
    action: actionLabel != null && onActionPressed != null
        ? SnackBarAction(
      label: actionLabel,
      textColor: Colors.white,
      onPressed: onActionPressed,
    )
        : null,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

/// Predefined error widgets for common scenarios
class ErrorWidgets {
  /// Network connection error
  static Widget networkError({VoidCallback? onRetry}) {
    return CustomErrorWidget(
      title: 'Internet aloqasi yo\'q',
      message: 'Internet aloqasini tekshiring va qayta urinib ko\'ring.',
      errorType: ErrorType.network,
      retryText: 'Qayta urinish',
      onRetry: onRetry,
    );
  }

  /// Server error
  static Widget serverError({VoidCallback? onRetry, String? details}) {
    return CustomErrorWidget(
      title: 'Server xatosi',
      message: 'Serverda muammo yuz berdi. Iltimos, keyinroq qayta urinib ko\'ring.',
      details: details,
      errorType: ErrorType.server,
      retryText: 'Qayta urinish',
      onRetry: onRetry,
    );
  }

  /// Authentication error
  static Widget authError({VoidCallback? onLogin}) {
    return CustomErrorWidget(
      title: 'Autentifikatsiya xatosi',
      message: 'Tizimga kirishda muammo. Iltimos, qayta kiring.',
      errorType: ErrorType.permission,
      retryText: 'Qayta kirish',
      onRetry: onLogin,
    );
  }

  /// Validation error
  static Widget validationError({
    required String message,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Ma\'lumot xatosi',
      message: message,
      errorType: ErrorType.validation,
      retryText: 'Qayta urinish',
      onRetry: onRetry,
    );
  }

  /// Permission denied error
  static Widget permissionDenied() {
    return CustomErrorWidget(
      title: 'Ruxsat berilmagan',
      message: 'Sizda bu amalni bajarish huquqi yo\'q.',
      errorType: ErrorType.permission,
    );
  }

  /// Data loading error
  static Widget loadingError({
    required String dataType,
    VoidCallback? onRetry,
    String? details,
  }) {
    return CustomErrorWidget(
      title: '$dataType yuklanmadi',
      message: 'Ma\'lumotlarni yuklashda xatolik yuz berdi.',
      details: details,
      errorType: ErrorType.general,
      retryText: 'Qayta yuklash',
      onRetry: onRetry,
    );
  }

  /// File upload error
  static Widget uploadError({
    VoidCallback? onRetry,
    String? fileName,
  }) {
    return CustomErrorWidget(
      title: 'Fayl yuklanmadi',
      message: fileName != null
          ? '$fileName faylini yuklashda xatolik yuz berdi.'
          : 'Faylni yuklashda xatolik yuz berdi.',
      errorType: ErrorType.general,
      retryText: 'Qayta yuklash',
      onRetry: onRetry,
    );
  }

  /// Search error
  static Widget searchError({
    required String query,
    VoidCallback? onRetry,
  }) {
    return CustomErrorWidget(
      title: 'Qidiruv xatosi',
      message: '"$query" bo\'yicha qidirishda xatolik yuz berdi.',
      errorType: ErrorType.general,
      retryText: 'Qayta qidirish',
      onRetry: onRetry,
    );
  }

  /// Generic error with custom message
  static Widget generic({
    required String message,
    VoidCallback? onRetry,
    String? details,
  }) {
    return CustomErrorWidget(
      title: 'Xatolik yuz berdi',
      message: message,
      details: details,
      errorType: ErrorType.general,
      retryText: 'Qayta urinish',
      onRetry: onRetry,
    );
  }
}

/// Error boundary widget for catching and displaying widget errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  final void Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() {
          _errorDetails = details;
        });
      }
      widget.onError?.call(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return widget.errorBuilder?.call(_errorDetails!) ??
          ErrorWidgets.generic(
            message: 'Dasturda xatolik yuz berdi',
            details: _errorDetails!.exceptionAsString(),
            onRetry: () {
              setState(() {
                _errorDetails = null;
              });
            },
          );
    }

    return widget.child;
  }
}

/// Utility class for showing error dialogs and snackbars
class ErrorUtils {
  /// Show error dialog
  static Future<void> showErrorDialog(
      BuildContext context, {
        required String title,
        required String message,
        String? details,
        VoidCallback? onRetry,
      }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: CustomErrorWidget(
          title: title,
          message: message,
          details: details,
          onRetry: onRetry,
          onDismiss: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
      BuildContext context, {
        required String message,
        String? actionLabel,
        VoidCallback? onActionPressed,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorSnackBar(
        message: message,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
      ),
    );
  }

  /// Show inline error
  static Widget showInlineError(String message) {
    return InlineErrorWidget(message: message);
  }
}