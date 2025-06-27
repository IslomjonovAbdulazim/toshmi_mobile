import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_themes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/loading_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: CustomAppBar(
        title: 'Profil',
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colors.primaryText),
            color: colors.cardBackground,
            onSelected: (value) => _handleMenuAction(value, authController),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: colors.primaryText, size: 20),
                    const SizedBox(width: 12),
                    Text('Tahrirlash', style: TextStyle(color: colors.primaryText)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: colors.primaryText, size: 20),
                    const SizedBox(width: 12),
                    Text('Sozlamalar', style: TextStyle(color: colors.primaryText)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (authController.isLoading) {
          return LoadingWidgets.page(message: 'Profil ma\'lumotlari yuklanmoqda...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(authController, colors),

              const SizedBox(height: 24),

              // Profile Information
              _buildProfileInfo(authController, colors),

              const SizedBox(height: 24),

              // Settings Section
              _buildSettingsSection(authController, colors),

              const SizedBox(height: 24),

              // Actions Section
              _buildActionsSection(authController, colors),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(AuthController authController, AppThemeColors colors) {
    final user = authController.currentUser;

    return Card(
      elevation: 4,
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colors.info.withOpacity(0.1),
                  child: user != null
                      ? Text(
                    authController.userAvatarText,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.info,
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: 50,
                    color: colors.info,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.info,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.cardBackground, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      onPressed: () => _changeProfilePicture(),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Name
            Text(
              user?.name ?? 'Noma\'lum foydalanuvchi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // User Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(authController.selectedRole, colors).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRoleColor(authController.selectedRole, colors).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRoleIcon(authController.selectedRole),
                    size: 16,
                    color: _getRoleColor(authController.selectedRole, colors),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    authController.getRoleDisplayName(authController.selectedRole),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getRoleColor(authController.selectedRole, colors),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Greeting Message
            Text(
              authController.greetingMessage,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(AuthController authController, AppThemeColors colors) {
    final user = authController.currentUser;

    return Card(
      elevation: 2,
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colors.info, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Shaxsiy ma\'lumotlar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'To\'liq ismi',
              value: user?.name ?? 'Kiritilmagan',
              colors: colors,
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Telefon raqami',
              value: user != null ? authController.formatPhoneForDisplay(user.phone) : 'Kiritilmagan',
              colors: colors,
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.work_outline,
              label: 'Lavozim',
              value: authController.getRoleDisplayName(authController.selectedRole),
              colors: colors,
            ),

            const SizedBox(height: 16),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _editProfile(authController),
                icon: Icon(Icons.edit, size: 18, color: colors.info),
                label: Text(
                  'Ma\'lumotlarni tahrirlash',
                  style: TextStyle(color: colors.info),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.info),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(AuthController authController, AppThemeColors colors) {
    return Card(
      elevation: 2,
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_outlined, color: colors.info, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sozlamalar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Parolni o\'zgartirish',
              subtitle: 'Hisobingiz xavfsizligini ta\'minlang',
              onTap: () => _changePassword(authController),
              colors: colors,
            ),

            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Bildirishnomalar',
              subtitle: 'Push bildirishnomalarni sozlang',
              onTap: () => _notificationSettings(),
              colors: colors,
            ),

            _buildSettingsTile(
              icon: Icons.palette_outlined,
              title: 'Mavzu',
              subtitle: 'Yorug\' yoki qorong\'u mavzuni tanlang',
              onTap: () => _themeSettings(colors),
              colors: colors,
            ),

            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'Til',
              subtitle: 'Dastur tilini o\'zgartiring',
              onTap: () => _languageSettings(),
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(AuthController authController, AppThemeColors colors) {
    return Card(
      elevation: 2,
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_outlined, color: colors.info, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Amallar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildActionTile(
              icon: Icons.help_outline,
              title: 'Yordam va qo\'llab-quvvatlash',
              onTap: () => _showHelp(),
              colors: colors,
            ),

            _buildActionTile(
              icon: Icons.info_outline,
              title: 'Dastur haqida',
              onTap: () => _showAbout(),
              colors: colors,
            ),

            _buildActionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Maxfiylik siyosati',
              onTap: () => _showPrivacyPolicy(),
              colors: colors,
            ),

            const SizedBox(height: 16),

            // Logout Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: authController.isLogoutLoading ? null : () => _logout(authController),
                icon: authController.isLogoutLoading
                    ? LoadingWidgets.button(size: 18)
                    : Icon(Icons.logout, size: 18),
                label: Text(
                  authController.isLogoutLoading ? 'Chiqilmoqda...' : 'Chiqish',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required AppThemeColors colors,
  }) {
    return Row(
      children: [
        Icon(icon, color: colors.secondaryText, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    return ListTile(
      leading: Icon(icon, color: colors.secondaryText),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colors.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: colors.secondaryText,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    return ListTile(
      leading: Icon(icon, color: colors.secondaryText),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colors.primaryText,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.secondaryText),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Color _getRoleColor(String role, AppThemeColors colors) {
    switch (role) {
      case 'student':
        return colors.info;
      case 'teacher':
        return colors.success;
      case 'parent':
        return colors.warning;
      default:
        return colors.secondaryText;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.school;
      case 'teacher':
        return Icons.person;
      case 'parent':
        return Icons.family_restroom;
      default:
        return Icons.person;
    }
  }

  void _handleMenuAction(String action, AuthController authController) {
    switch (action) {
      case 'edit':
        _editProfile(authController);
        break;
      case 'settings':
        Get.toNamed('/settings');
        break;
    }
  }

  void _changeProfilePicture() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              const SizedBox(height: 16, width: double.infinity),
              const Center(
                child: Text(
                  'Profil rasmini o\'zgartirish',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16, width: double.infinity),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kameradan olish'),
                onTap: () {
                  Get.back();
                  // Implement camera functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galereyadan tanlash'),
                onTap: () {
                  Get.back();
                  // Implement gallery functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Rasmni o\'chirish'),
                onTap: () {
                  Get.back();
                  // Implement delete functionality
                },
              ),
              const SizedBox(height: 16, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile(AuthController authController) {
    authController.loadProfileData();
    Get.toNamed('/edit-profile');
  }

  void _changePassword(AuthController authController) {
    Get.toNamed('/change-password');
  }

  void _notificationSettings() {
    Get.toNamed('/notification-settings');
  }

  void _themeSettings(AppThemeColors colors) {
    // Capture current theme mode before showing bottom sheet
    final currentThemeMode = Get.isDarkMode;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              const SizedBox(height: 16, width: double.infinity),
              Center(
                child: Text(
                  'Mavzuni tanlang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
              ),
              const SizedBox(height: 16, width: double.infinity),
              ListTile(
                leading: Icon(Icons.light_mode, color: colors.primaryText),
                title: Text('Yorug\' mavzu', style: TextStyle(color: colors.primaryText)),
                trailing: !currentThemeMode ? Icon(Icons.check, color: colors.info) : null,
                onTap: () {
                  Get.back();
                  Get.changeThemeMode(ThemeMode.light);
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: colors.primaryText),
                title: Text('Qorong\'u mavzu', style: TextStyle(color: colors.primaryText)),
                trailing: currentThemeMode ? Icon(Icons.check, color: colors.info) : null,
                onTap: () {
                  Get.back();
                  Get.changeThemeMode(ThemeMode.dark);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_brightness, color: colors.primaryText),
                title: Text('Tizim mavzusi', style: TextStyle(color: colors.primaryText)),
                onTap: () {
                  Get.back();
                  Get.changeThemeMode(ThemeMode.system);
                },
              ),
              const SizedBox(height: 16, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }

  void _languageSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Til sozlamalari'),
        content: const Text('Hozircha faqat o\'zbek tili mavjud.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Yordam'),
        content: const Text(
          'Savollaringiz bo\'lsa, quyidagi manzillarga murojaat qiling:\n\n'
              '📞 +998 71 123 45 67\n'
              '📧 support@toshmi.uz\n'
              '🌐 www.toshmi.uz\n\n'
              'Ish vaqti: 09:00 - 18:00',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Dastur haqida'),
        content: const Text(
          'Toshmi Mobile v1.0.0\n\n'
              'Ta\'lim muassasalari uchun boshqaruv tizimi.\n\n'
              '© 2024 Toshmi. Barcha huquqlar himoyalangan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Maxfiylik siyosati'),
        content: const SingleChildScrollView(
          child: Text(
            'Biz sizning shaxsiy ma\'lumotlaringizni himoya qilishga majburmiz.\n\n'
                'To\'planadigan ma\'lumotlar:\n'
                '• Ism va familiya\n'
                '• Telefon raqami\n'
                '• Ta\'lim ma\'lumotlari\n\n'
                'Ma\'lumotlardan foydalanish:\n'
                '• Xizmat ko\'rsatish\n'
                '• Hisobotlar tayyorlash\n'
                '• Xavfsizlikni ta\'minlash\n\n'
                'Biz sizning ma\'lumotlaringizni uchinchi tomonlarga bermayamiz.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _logout(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Tizimdan chiqish'),
        content: const Text('Rostdan ham tizimdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Chiqish'),
          ),
        ],
      ),
    );
  }
}