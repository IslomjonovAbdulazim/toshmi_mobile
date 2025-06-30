// lib/app/modules/teacher/views/shared/widgets/teacher_drawer.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../services/auth_service.dart';

class TeacherDrawer extends StatelessWidget {
  const TeacherDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Get.find<AuthService>();

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context, authService),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () => Get.back(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Homework',
                  onTap: () {
                    Get.back();
                    // Navigate to homework
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.quiz_outlined,
                  title: 'Exams',
                  onTap: () {
                    Get.back();
                    // Navigate to exams
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.grade_outlined,
                  title: 'Grading',
                  onTap: () {
                    Get.back();
                    // Navigate to grading
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.how_to_reg_outlined,
                  title: 'Attendance',
                  onTap: () {
                    Get.back();
                    // Navigate to attendance
                  },
                ),
                const Divider(height: 32),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Get.back();
                    // Navigate to settings
                  },
                ),
              ],
            ),
          ),
          _buildFooter(context, authService),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthService authService) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              authService.currentUser?.firstName.substring(0, 1).toUpperCase() ?? 'T',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authService.currentUser?.fullName ?? 'Teacher',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Teacher',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AuthService authService) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.logout,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Logout',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            onTap: () {
              Get.back();
              authService.logout();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}