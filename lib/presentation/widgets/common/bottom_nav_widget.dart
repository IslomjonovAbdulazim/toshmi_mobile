import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_themes.dart';

/// Bottom navigation item model
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final int? badgeCount;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
    this.badgeCount,
  });
}

/// Custom bottom navigation bar with enhanced features
class CustomBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool showLabels;
  final BottomNavigationBarType? type;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.showLabels = true,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: colors.secondaryText.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: type ?? BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor ?? colors.cardBackground,
        selectedItemColor: selectedItemColor ?? colors.info,
        unselectedItemColor: unselectedItemColor ?? colors.secondaryText,
        elevation: elevation ?? 0,
        showSelectedLabels: showLabels,
        showUnselectedLabels: showLabels,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return BottomNavigationBarItem(
            icon: _buildIconWithBadge(
              icon: item.icon,
              badgeCount: item.badgeCount,
              colors: colors,
              isSelected: false,
            ),
            activeIcon: _buildIconWithBadge(
              icon: item.activeIcon ?? item.icon,
              badgeCount: item.badgeCount,
              colors: colors,
              isSelected: true,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIconWithBadge({
    required IconData icon,
    int? badgeCount,
    required AppThemeColors colors,
    required bool isSelected,
  }) {
    Widget iconWidget = Icon(
      icon,
      size: 24,
      color: isSelected
          ? (selectedItemColor ?? colors.info)
          : (unselectedItemColor ?? colors.secondaryText),
    );

    if (badgeCount != null && badgeCount > 0) {
      return Stack(
        children: [
          iconWidget,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }
}

/// Student role bottom navigation
class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const List<BottomNavItem> items = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Bosh sahifa',
      route: '/student',
    ),
    BottomNavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Vazifalar',
      route: '/homework',
    ),
    BottomNavItem(
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      label: 'Imtihonlar',
      route: '/exams',
    ),
    BottomNavItem(
      icon: Icons.grade_outlined,
      activeIcon: Icons.grade,
      label: 'Baholar',
      route: '/grades',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      items: items,
      currentIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          Get.toNamed(items[index].route);
        }
      },
    );
  }
}

/// Teacher role bottom navigation
class TeacherBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const TeacherBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const List<BottomNavItem> items = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/teacher',
    ),
    BottomNavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      label: 'Vazifalar',
      route: '/teacher/homework',
    ),
    BottomNavItem(
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      label: 'Imtihonlar',
      route: '/teacher/exams',
    ),
    BottomNavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Guruhlar',
      route: '/teacher/groups',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      items: items,
      currentIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          Get.toNamed(items[index].route);
        }
      },
    );
  }
}

/// Parent role bottom navigation
class ParentBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final int? notificationCount;

  const ParentBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Bosh sahifa',
        route: '/parent',
      ),
      const BottomNavItem(
        icon: Icons.child_care_outlined,
        activeIcon: Icons.child_care,
        label: 'Bolalarim',
        route: '/parent/children',
      ),
      BottomNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Xabarlar',
        route: '/notifications',
        badgeCount: notificationCount,
      ),
      const BottomNavItem(
        icon: Icons.payment_outlined,
        activeIcon: Icons.payment,
        label: 'To\'lovlar',
        route: '/parent/payments',
      ),
      const BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: '/profile',
      ),
    ];

    return CustomBottomNavBar(
      items: items,
      currentIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          Get.toNamed(items[index].route);
        }
      },
    );
  }
}

/// Floating action button style bottom navigation
class FloatingBottomNav extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final double? borderRadius;

  const FloatingBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        boxShadow: [
          BoxShadow(
            color: colors.secondaryText.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap?.call(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (selectedItemColor ?? colors.info).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    color: isSelected
                        ? (selectedItemColor ?? colors.info)
                        : colors.secondaryText,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? (selectedItemColor ?? colors.info)
                          : colors.secondaryText,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}