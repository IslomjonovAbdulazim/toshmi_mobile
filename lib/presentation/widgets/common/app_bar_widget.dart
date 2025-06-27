import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:toshmi_mobile/core/themes/app_themes.dart';

/// Custom app bar widget with consistent theming
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showNotificationIcon;
  final bool showSearchIcon;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final Widget? bottom;
  final double? titleSpacing;
  final TextStyle? titleStyle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.showNotificationIcon = false,
    this.showSearchIcon = false,
    this.onNotificationTap,
    this.onSearchTap,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.titleSpacing,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    final defaultActions = <Widget>[];

    // Add search icon if enabled
    if (showSearchIcon) {
      defaultActions.add(
        IconButton(
          icon: Icon(
            Icons.search,
            color: foregroundColor ?? colors.primaryText,
          ),
          onPressed: onSearchTap,
          tooltip: 'Qidirish',
        ),
      );
    }

    // Add notification icon if enabled
    if (showNotificationIcon) {
      defaultActions.add(
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: foregroundColor ?? colors.primaryText,
              ),
              // Notification badge - you can connect this to a notification controller
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
                  child: const Text(
                    '3', // Replace with dynamic count
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: onNotificationTap,
          tooltip: 'Bildirishnomalar',
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      defaultActions.addAll(actions!);
    }

    return AppBar(
      title: Text(
        title,
        style: titleStyle ?? TextStyle(
          color: foregroundColor ?? colors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colors.primaryBackground,
      foregroundColor: foregroundColor ?? colors.primaryText,
      elevation: elevation ?? (isDark ? 0 : 1),
      shadowColor: isDark ? null : colors.border,
      surfaceTintColor: backgroundColor ?? colors.primaryBackground,
      leading: leading ?? (showBackButton && automaticallyImplyLeading
          ? IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: foregroundColor ?? colors.primaryText,
        ),
        onPressed: onBackPressed ?? () => Get.back(),
        tooltip: 'Orqaga',
      )
          : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: defaultActions.isNotEmpty ? defaultActions : null,
      bottom: bottom != null ? PreferredSize(
        preferredSize: Size.fromHeight(bottom is TabBar ? 48 : 56),
        child: bottom!,
      ) : null,
      titleSpacing: titleSpacing,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom != null ? (bottom is TabBar ? 48 : 56) : 0)
  );
}

/// App bar specifically for dashboard pages
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? profileWidget;
  final VoidCallback? onProfileTap;
  final bool showNotifications;
  final VoidCallback? onNotificationTap;

  const DashboardAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.profileWidget,
    this.onProfileTap,
    this.showNotifications = true,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      backgroundColor: colors.primaryBackground,
      foregroundColor: colors.primaryText,
      elevation: context.isDarkMode ? 0 : 1,
      shadowColor: context.isDarkMode ? null : colors.border,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      actions: [
        if (showNotifications)
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: colors.primaryText,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: onNotificationTap,
            tooltip: 'Bildirishnomalar',
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: profileWidget ?? CircleAvatar(
              radius: 18,
              backgroundColor: colors.info,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Search app bar with input field
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClosed;
  final TextEditingController? controller;
  final bool autofocus;

  const SearchAppBar({
    Key? key,
    this.hintText = 'Qidirish...',
    this.onChanged,
    this.onSubmitted,
    this.onClosed,
    this.controller,
    this.autofocus = true,
  }) : super(key: key);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.primaryBackground,
      foregroundColor: colors.primaryText,
      elevation: context.isDarkMode ? 0 : 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: colors.primaryText,
        ),
        onPressed: () {
          widget.onClosed?.call();
          Get.back();
        },
        tooltip: 'Orqaga',
      ),
      title: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        style: TextStyle(
          color: colors.primaryText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: colors.secondaryText,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
      ),
      actions: [
        if (_controller.text.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.clear,
              color: colors.primaryText,
            ),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
            tooltip: 'Tozalash',
          ),
      ],
    );
  }
}

/// Tab app bar with custom tabs
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<String> tabs;
  final TabController? controller;
  final bool isScrollable;
  final ValueChanged<int>? onTap;

  const TabAppBar({
    Key? key,
    required this.title,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: colors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colors.primaryBackground,
      foregroundColor: colors.primaryText,
      elevation: context.isDarkMode ? 0 : 1,
      bottom: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        onTap: onTap,
        labelColor: colors.info,
        unselectedLabelColor: colors.secondaryText,
        indicatorColor: colors.info,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);
}