import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_themes.dart';
import '../../controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        backgroundColor: colors.info,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsBottomSheet(context, authController, colors),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => authController.loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(authController, colors),
              const SizedBox(height: 24),
              _buildProfileInfo(authController, colors),
              const SizedBox(height: 24),
              _buildQuickActions(authController, colors),
              const SizedBox(height: 24),
              _buildAccountActions(authController, colors, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthController authController, AppThemeColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.info,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          children: [
            // Profile picture
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Obx(() {
                final user = authController.currentUser;
                return user != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundColor: colors.secondaryBackground,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: colors.info,
                    ),
                  ),
                )
                    : CircleAvatar(
                  radius: 50,
                  backgroundColor: colors.secondaryBackground,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: colors.secondaryText,
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // User name
            Obx(() {
              final user = authController.currentUser;
              return Text(
                user?.name ?? 'Foydalanuvchi',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),

            const SizedBox(height: 8),

            // User role
            Obx(() {
              final profile = authController.profile;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile?.roleUz ?? authController.getRoleDisplayName(authController.selectedRole),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(AuthController authController, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
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

              Obx(() {
                final profile = authController.profile;
                final user = authController.currentUser;

                return Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'To\'liq ismi',
                      value: profile?.fullName ?? user?.name ?? 'Ma\'lumot yo\'q',
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Telefon raqami',
                      value: authController.formatPhoneForDisplay(
                          profile?.phone ?? user?.phone ?? ''
                      ),
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.badge,
                      label: 'ID raqami',
                      value: profile?.id.toString() ?? user?.id.toString() ?? 'Ma\'lumot yo\'q',
                      colors: colors,
                    ),
                  ],
                );
              }),
            ],
          ),
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
        Icon(icon, size: 18, color: colors.secondaryText),
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

  Widget _buildQuickActions(AuthController authController, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flash_on, color: colors.info, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Tezkor harakatlar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit,
                      label: 'Tahrirlash',
                      onTap: () => authController.goToEditProfile(),
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.lock_reset,
                      label: 'Parolni o\'zgartirish',
                      onTap: () => authController.goToChangePassword(),
                      colors: colors,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.info, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(AuthController authController, AppThemeColors colors, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.notifications, color: colors.info),
              title: Text(
                'Bildirishnomalar',
                style: TextStyle(color: colors.primaryText),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colors.secondaryText),
              onTap: () {
                // Navigate to notifications
              },
            ),
            Divider(height: 1, color: colors.secondaryText.withOpacity(0.1)),
            ListTile(
              leading: Icon(Icons.help, color: colors.info),
              title: Text(
                'Yordam',
                style: TextStyle(color: colors.primaryText),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colors.secondaryText),
              onTap: () {
                // Navigate to help
              },
            ),
            Divider(height: 1, color: colors.secondaryText.withOpacity(0.1)),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text(
                'Chiqish',
                style: TextStyle(color: colors.error),
              ),
              onTap: () => _showLogoutDialog(context, authController, colors),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, AuthController authController, AppThemeColors colors) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sozlamalar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.palette_outlined, color: colors.primaryText),
                title: Text('Mavzu', style: TextStyle(color: colors.primaryText)),
                subtitle: Text('Yorug\' yoki qorong\'u mavzuni tanlang', style: TextStyle(color: colors.secondaryText)),
                onTap: () => _showThemeSelector(context, colors),
              ),
              ListTile(
                leading: Icon(Icons.language_outlined, color: colors.primaryText),
                title: Text('Til', style: TextStyle(color: colors.primaryText)),
                subtitle: Text('O\'zbek tili', style: TextStyle(color: colors.secondaryText)),
                onTap: () {
                  Get.back();
                  authController.showInfo('Hozircha faqat o\'zbek tili mavjud');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, AppThemeColors colors) {
    Get.back(); // Close settings

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Mavzuni tanlang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.light_mode, color: colors.primaryText),
                title: Text('Yorug\' mavzu', style: TextStyle(color: colors.primaryText)),
                trailing: !Get.isDarkMode ? Icon(Icons.check, color: colors.info) : null,
                onTap: () {
                  Get.back();
                  Get.changeThemeMode(ThemeMode.light);
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: colors.primaryText),
                title: Text('Qorong\'u mavzu', style: TextStyle(color: colors.primaryText)),
                trailing: Get.isDarkMode ? Icon(Icons.check, color: colors.info) : null,
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController, AppThemeColors colors) {
    Get.dialog(
      AlertDialog(
        title: Text('Chiqish', style: TextStyle(color: colors.primaryText)),
        content: Text(
          'Haqiqatan ham hisobingizdan chiqmoqchimisiz?',
          style: TextStyle(color: colors.secondaryText),
        ),
        backgroundColor: colors.cardBackground,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish', style: TextStyle(color: colors.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: Text('Chiqish', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}