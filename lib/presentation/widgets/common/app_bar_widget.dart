import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_themes.dart';

/// Custom app bar with consistent theming and common actions
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
  final int? notificationCount;

  const CustomAppBar({
    super.key,
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
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Get.isDarkMode;

    final appBarActions = <Widget>[];

    // Add search icon
    if (showSearchIcon) {
      appBarActions.add(
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

    // Add notification icon with badge
    if (showNotificationIcon) {
      appBarActions.add(
        IconButton(
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: foregroundColor ?? colors.primaryText,
              ),
              if (notificationCount != null && notificationCount! > 0)
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
                      notificationCount! > 99
                          ? '99+'
                          : notificationCount.toString(),
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
          ),
          onPressed: onNotificationTap,
          tooltip: 'Bildirishnomalar',
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      appBarActions.addAll(actions!);
    }

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor ?? colors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colors.primaryBackground,
      foregroundColor: foregroundColor ?? colors.primaryText,
      elevation: elevation ?? (isDark ? 0 : 2),
      shadowColor: isDark ? null : colors.secondaryText.withOpacity(0.1),
      surfaceTintColor: backgroundColor ?? colors.primaryBackground,
      leading:
          leading ??
          (showBackButton && automaticallyImplyLeading
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
      actions: appBarActions.isNotEmpty ? appBarActions : null,
      // bottom: bottom != null ? PreferredSize(
      //   preferredSize: Size.fromHeight(bottom is TabBar ? kTabsHeight : 56),
      //   child: bottom!,
      // ) : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom != null ? 56 : 0));
}

/// App bar with user profile
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? userName;
  final String? userRole;
  final bool showNotifications;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final Widget? profileWidget;
  final int? notificationCount;

  const ProfileAppBar({
    super.key,
    required this.title,
    this.userName,
    this.userRole,
    this.showNotifications = true,
    this.onNotificationTap,
    this.onProfileTap,
    this.profileWidget,
    this.notificationCount,
  });

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
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (userName != null)
            Text(
              userName!,
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      backgroundColor: colors.primaryBackground,
      foregroundColor: colors.primaryText,
      elevation: Get.isDarkMode ? 0 : 1,
      shadowColor: Get.isDarkMode
          ? null
          : colors.secondaryText.withOpacity(0.1),
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      actions: [
        if (showNotifications)
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, color: colors.primaryText),
                if (notificationCount != null && notificationCount! > 0)
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
            child:
                profileWidget ??
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.info,
                  child: Text(
                    userName?.isNotEmpty == true
                        ? userName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    this.hintText = 'Qidirish...',
    this.onChanged,
    this.onSubmitted,
    this.onClosed,
    this.controller,
    this.autofocus = true,
    this.actions,
  });

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
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
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
      elevation: Get.isDarkMode ? 0 : 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.primaryText),
        onPressed: widget.onClosed ?? () => Get.back(),
      ),
      title: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(color: colors.primaryText),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: colors.secondaryText),
          border: InputBorder.none,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colors.secondaryText),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                )
              : null,
        ),
      ),
      actions: widget.actions,
    );
  }
}

/// Simple app bar with minimal styling
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: colors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colors.primaryBackground,
      foregroundColor: colors.primaryText,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: colors.primaryText),
              onPressed: onBackPressed ?? () => Get.back(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
