import 'package:flutter/material.dart';
import 'package:toshmi_mobile/core/themes/app_themes.dart';

/// Empty state widget with customizable content
class EmptyStateWidget extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsets padding;
  final double spacing;
  final bool showAnimation;

  const EmptyStateWidget({
    Key? key,
    this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.padding = const EdgeInsets.all(32),
    this.spacing = 16,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              if (showAnimation)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: icon!,
                      ),
                    );
                  },
                )
              else
                icon!,
              SizedBox(height: spacing),
            ],

            // Title
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: showAnimation ? 600 : 0),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, showAnimation ? (1 - value) * 20 : 0),
                  child: Opacity(
                    opacity: value,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),

            // Subtitle
            if (subtitle != null) ...[
              SizedBox(height: spacing / 2),
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: showAnimation ? 800 : 0),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, showAnimation ? (1 - value) * 20 : 0),
                    child: Opacity(
                      opacity: value,
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.secondaryText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],

            // Action button
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: spacing * 1.5),
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: showAnimation ? 1000 : 0),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, showAnimation ? (1 - value) * 20 : 0),
                    child: Opacity(
                      opacity: value,
                      child: ElevatedButton(
                        onPressed: onActionPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.info,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(actionText!),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  /// No homework found
  static Widget noHomework({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.assignment_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Vazifalar topilmadi',
      subtitle: 'Hozircha sizga tayinlangan vazifalar yo\'q. Yangi vazifalar uchun muntazam tekshirib turing.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No exams found
  static Widget noExams({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.quiz_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Imtihonlar topilmadi',
      subtitle: 'Hozircha sizga tayinlangan imtihonlar yo\'q.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No grades found
  static Widget noGrades({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.grade_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Baholar topilmadi',
      subtitle: 'Hozircha sizning baholaringiz yo\'q.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No notifications found
  static Widget noNotifications({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.notifications_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Bildirishnomalar yo\'q',
      subtitle: 'Sizda yangi bildirishnomalar yo\'q.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No students found (for teachers)
  static Widget noStudents({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.groups_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Talabalar topilmadi',
      subtitle: 'Hozircha sizning guruhlaringizda talabalar yo\'q.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No children found (for parents)
  static Widget noChildren({VoidCallback? onAddChild}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.child_care_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Bolalar ro\'yxati bo\'sh',
      subtitle: 'Hozircha sizning hisobingizga bog\'langan bolalar yo\'q.',
      actionText: onAddChild != null ? 'Bola qo\'shish' : null,
      onActionPressed: onAddChild,
    );
  }

  /// No payments found
  static Widget noPayments({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.payment_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'To\'lovlar tarixi bo\'sh',
      subtitle: 'Hozircha to\'lovlar amalga oshirilmagan.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No news found
  static Widget noNews({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.article_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Yangiliklar yo\'q',
      subtitle: 'Hozircha yangiliklar e\'lon qilinmagan.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No schedule found
  static Widget noSchedule({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.schedule_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Dars jadvali yo\'q',
      subtitle: 'Hozircha dars jadvali tuzilmagan.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// Network error state
  static Widget networkError({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.wifi_off_outlined,
        size: 64,
        color: Colors.red[400],
      ),
      title: 'Internet aloqasi yo\'q',
      subtitle: 'Internet aloqasini tekshiring va qayta urinib ko\'ring.',
      actionText: onRetry != null ? 'Qayta urinish' : null,
      onActionPressed: onRetry,
    );
  }

  /// Search no results
  static Widget noSearchResults({
    required String query,
    VoidCallback? onClearSearch,
  }) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.search_off_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Qidiruv natijalari topilmadi',
      subtitle: '"$query" bo\'yicha hech narsa topilmadi. Boshqa so\'zlar bilan qidiring.',
      actionText: onClearSearch != null ? 'Qidiruvni tozalash' : null,
      onActionPressed: onClearSearch,
    );
  }

  /// Coming soon state
  static Widget comingSoon() {
    return EmptyStateWidget(
      icon: Icon(
        Icons.timer_outlined,
        size: 64,
        color: Colors.blue[400],
      ),
      title: 'Tez orada...',
      subtitle: 'Bu xususiyat ustida ishlamoqdamiz. Tez orada mavjud bo\'ladi.',
      showAnimation: true,
    );
  }

  /// Maintenance mode
  static Widget maintenance() {
    return EmptyStateWidget(
      icon: Icon(
        Icons.build_outlined,
        size: 64,
        color: Colors.orange[400],
      ),
      title: 'Texnik ishlar',
      subtitle: 'Hozirda tizimda texnik ishlar olib borilmoqda. Iltimos, keyinroq qaytib keling.',
      showAnimation: true,
    );
  }

  /// Access denied
  static Widget accessDenied() {
    return EmptyStateWidget(
      icon: Icon(
        Icons.lock_outlined,
        size: 64,
        color: Colors.red[400],
      ),
      title: 'Ruxsat berilmagan',
      subtitle: 'Sizda bu sahifaga kirish huquqi yo\'q.',
      showAnimation: true,
    );
  }
}

/// Empty state with custom illustration
class IllustratedEmptyState extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double imageHeight;

  const IllustratedEmptyState({
    Key? key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.imageHeight = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Image.asset(
        imagePath,
        height: imageHeight,
        fit: BoxFit.contain,
      ),
      title: title,
      subtitle: subtitle,
      actionText: actionText,
      onActionPressed: onActionPressed,
    );
  }
}

/// Animated empty state with floating elements
class AnimatedEmptyState extends StatefulWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const AnimatedEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<Offset> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: SlideTransition(
        position: _floatingAnimation,
        child: widget.icon,
      ),
      title: widget.title,
      subtitle: widget.subtitle,
      actionText: widget.actionText,
      onActionPressed: widget.onActionPressed,
      showAnimation: true,
    );
  }
}