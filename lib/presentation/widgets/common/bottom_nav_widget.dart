import 'package:flutter/material.dart';
import 'package:toshmi_mobile/core/themes/app_themes.dart';

/// Navigation item data model
class NavItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;
  final bool showBadge;
  final String? badgeText;

  const NavItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
    this.showBadge = false,
    this.badgeText,
  });
}

/// Custom bottom navigation bar with theming support
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final double? elevation;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = false,
    this.elevation,
    this.margin,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardBackground,
        borderRadius: borderRadius,
        boxShadow: elevation != null ? [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: elevation!,
            offset: const Offset(0, -2),
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor ?? colors.cardBackground,
          selectedItemColor: selectedItemColor ?? colors.info,
          unselectedItemColor: unselectedItemColor ?? colors.secondaryText,
          showSelectedLabels: showSelectedLabels,
          showUnselectedLabels: showUnselectedLabels,
          elevation: 0, // We handle elevation with container
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
          items: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;

            return BottomNavigationBarItem(
              icon: _buildIcon(context, item, isSelected),
              label: item.label,
              tooltip: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, NavItem item, bool isSelected) {
    final colors = context.colors;

    Widget iconWidget = Icon(
      isSelected && item.activeIcon != null ? item.activeIcon! : item.icon,
      size: 24,
      color: isSelected
          ? (selectedItemColor ?? colors.info)
          : (unselectedItemColor ?? colors.secondaryText),
    );

    // Add badge if needed
    if (item.showBadge) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                item.badgeText ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
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

/// Floating bottom navigation bar (Material 3 style)
class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final ValueChanged<int>? onTap;
  final EdgeInsets margin;
  final double borderRadius;

  const FloatingBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.margin = const EdgeInsets.all(16),
    this.borderRadius = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 12,
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

          return Expanded(
            child: InkWell(
              onTap: () => onTap?.call(index),
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIcon(context, item, isSelected),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? colors.info : colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, NavItem item, bool isSelected) {
    final colors = context.colors;

    Widget iconWidget = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? colors.info.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isSelected && item.activeIcon != null ? item.activeIcon! : item.icon,
        size: 24,
        color: isSelected ? colors.info : colors.secondaryText,
      ),
    );

    // Add badge if needed
    if (item.showBadge) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                item.badgeText ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
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

/// Tab navigation widget for page views
class TabNavigation extends StatelessWidget {
  final int currentIndex;
  final List<String> tabs;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final EdgeInsets padding;

  const TabNavigation({
    Key? key,
    required this.currentIndex,
    required this.tabs,
    this.onTap,
    this.isScrollable = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == currentIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onTap?.call(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.info
                        : colors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? colors.info
                          : colors.border,
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : colors.primaryText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Predefined navigation items for different user roles
class NavigationItems {
  // Student navigation items
  static List<NavItem> studentItems = [
    const NavItem(
      label: 'Bosh sahifa',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/student',
    ),
    const NavItem(
      label: 'Vazifalar',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      route: '/student/homework',
      showBadge: true,
      badgeText: '2',
    ),
    const NavItem(
      label: 'Imtihonlar',
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      route: '/student/exams',
    ),
    const NavItem(
      label: 'Baholar',
      icon: Icons.grade_outlined,
      activeIcon: Icons.grade,
      route: '/student/grades',
    ),
    const NavItem(
      label: 'Profil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];

  // Teacher navigation items
  static List<NavItem> teacherItems = [
    const NavItem(
      label: 'Bosh sahifa',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/teacher',
    ),
    const NavItem(
      label: 'Vazifalar',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      route: '/teacher/homework',
    ),
    const NavItem(
      label: 'Imtihonlar',
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      route: '/teacher/exams',
    ),
    const NavItem(
      label: 'Talabalar',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
      route: '/teacher/students',
    ),
    const NavItem(
      label: 'Profil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];

  // Parent navigation items
  static List<NavItem> parentItems = [
    const NavItem(
      label: 'Bosh sahifa',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/parent',
    ),
    const NavItem(
      label: 'Bolalarim',
      icon: Icons.child_care_outlined,
      activeIcon: Icons.child_care,
      route: '/parent/children',
    ),
    const NavItem(
      label: 'Hisobotlar',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      route: '/parent/reports',
    ),
    const NavItem(
      label: 'To\'lovlar',
      icon: Icons.payment_outlined,
      activeIcon: Icons.payment,
      route: '/parent/payments',
    ),
    const NavItem(
      label: 'Profil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile',
    ),
  ];

  /// Get navigation items based on user role
  static List<NavItem> getItemsForRole(String role) {
    switch (role) {
      case 'student':
        return studentItems;
      case 'teacher':
        return teacherItems;
      case 'parent':
        return parentItems;
      default:
        return studentItems;
    }
  }
}