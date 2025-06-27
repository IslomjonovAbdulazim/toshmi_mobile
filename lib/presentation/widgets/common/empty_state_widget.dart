import 'package:flutter/material.dart';
import '../../../core/themes/app_themes.dart';

/// Generic empty state widget for various scenarios
class EmptyStateWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsets padding;
  final bool showAnimation;
  final Color? backgroundColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.padding = const EdgeInsets.all(32),
    this.showAnimation = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        if (showAnimation)
          _AnimatedIcon(child: icon)
        else
          icon,

        const SizedBox(height: 24),

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

        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: colors.secondaryText,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        if (actionText != null && onActionPressed != null) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onActionPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(actionText!),
          ),
        ],
      ],
    );

    if (backgroundColor != null) {
      content = Container(
        color: backgroundColor,
        child: content,
      );
    }

    return Center(
      child: Padding(
        padding: padding,
        child: content,
      ),
    );
  }
}

/// Animated icon wrapper for empty states
class _AnimatedIcon extends StatefulWidget {
  final Widget child;

  const _AnimatedIcon({required this.child});

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Pre-configured empty states for common scenarios
class EmptyStates {
  /// No homework found
  static Widget noHomework({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.assignment_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Vazifalar yo\'q',
      subtitle: 'Hozircha sizga berilgan vazifalar mavjud emas.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
      showAnimation: true,
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
      title: 'Imtihonlar yo\'q',
      subtitle: 'Hozircha rejalashtirilingan imtihonlar mavjud emas.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
      showAnimation: true,
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
      title: 'Baholar yo\'q',
      subtitle: 'Hozircha sizga qo\'yilgan baholar mavjud emas.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
      showAnimation: true,
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
      subtitle: 'Barcha bildirishnomalar o\'qilgan yoki yangi xabarlar yo\'q.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
      showAnimation: true,
    );
  }

  /// No attendance records
  static Widget noAttendance({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.event_busy_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Davomat ma\'lumotlari yo\'q',
      subtitle: 'Tanlangan muddat uchun davomat ma\'lumotlari topilmadi.',
      actionText: onRefresh != null ? 'Yangilash' : null,
      onActionPressed: onRefresh,
    );
  }

  /// No children for parent
  static Widget noChildren({VoidCallback? onAddChild}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.child_care_outlined,
        size: 64,
        color: Colors.grey[400],
      ),
      title: 'Bolalar ro\'yxati bo\'sh',
      subtitle: 'Hozircha sizning farzandlaringiz ro\'yxatga olinmagan.',
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
      subtitle: 'Tanlangan sana uchun dars jadvali mavjud emas.',
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
      showAnimation: true,
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
      subtitle: '"$query" bo\'yicha hech narsa topilmadi.\nBoshqa so\'zlar bilan qidiring.',
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
      subtitle: 'Bu xususiyat ustida ishlamoqdamiz.\nTez orada mavjud bo\'ladi.',
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
      subtitle: 'Hozirda tizimda texnik ishlar olib borilmoqda.\nIltimos, keyinroq qaytib keling.',
      showAnimation: true,
    );
  }

  /// Access denied
  static Widget accessDenied({VoidCallback? onContactSupport}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.lock_outlined,
        size: 64,
        color: Colors.red[400],
      ),
      title: 'Ruxsat rad etildi',
      subtitle: 'Bu sahifaga kirish uchun sizda yetarli ruxsat yo\'q.',
      actionText: onContactSupport != null ? 'Yordam so\'rash' : null,
      onActionPressed: onContactSupport,
    );
  }

  /// Data loading failed
  static Widget loadingFailed({VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icon(
        Icons.error_outline,
        size: 64,
        color: Colors.red[400],
      ),
      title: 'Ma\'lumot yuklanmadi',
      subtitle: 'Ma\'lumotlarni yuklashda xatolik yuz berdi.',
      actionText: onRetry != null ? 'Qayta yuklash' : null,
      onActionPressed: onRetry,
    );
  }
}