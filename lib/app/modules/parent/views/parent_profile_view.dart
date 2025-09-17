import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/theme_service.dart';
import '../../../services/language_service.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/avatar_upload_widget.dart';
import '../../../../core/theme/app_colors.dart';

class ParentProfileView extends StatefulWidget {
  const ParentProfileView({super.key});

  @override
  State<ParentProfileView> createState() => _ParentProfileViewState();
}

class _ParentProfileViewState extends State<ParentProfileView> {
  final AuthService authService = Get.find<AuthService>();
  final ThemeService themeService = ThemeService();
  final LanguageService languageService = LanguageService();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final currentThemeMode = ThemeMode.system.obs;
  final currentLocale = const Locale('uz', 'UZ').obs;

  @override
  void initState() {
    super.initState();
    currentThemeMode.value = themeService.theme;
    currentLocale.value = languageService.locale;
    
    // Refresh user profile when entering profile screen
    authService.refreshUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'profile'.tr,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(theme),
            const SizedBox(height: 24),
            _buildThemeSelector(theme),
            const SizedBox(height: 24),
            _buildLanguageSelector(theme),
            const SizedBox(height: 24),
            _buildPasswordForm(theme),
            const SizedBox(height: 24),
            _buildLogoutButton(theme),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Builder(builder: (context) {
              final user = authService.currentUser;
              final avatarUrl = user?.avatarUrl;
              final legacyProfileImageId = user?.profileImageId;
              
              print('👨‍👩‍👧 Parent profile - User ID: ${user?.id}, Avatar URL: $avatarUrl, Legacy Profile Image ID: $legacyProfileImageId');
              
              return AvatarUploadWidget(
                avatarUrl: avatarUrl,
                legacyProfileImageId: legacyProfileImageId,
                size: 80,
                onAvatarUploaded: (storageUrl) {
                  // Handle avatar update success
                  print('👨‍👩‍👧 Parent avatar uploaded - New storage URL: $storageUrl');
                  setState(() {});
                },
                isEditable: true,
              );
            }),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authService.userFullName ?? 'parent'.tr,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.parentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'parent'.tr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.parentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authService.userPhone ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'theme'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildThemeOption(ThemeMode.system, theme),
                const SizedBox(height: 8),
                _buildThemeOption(ThemeMode.light, theme),
                const SizedBox(height: 8),
                _buildThemeOption(ThemeMode.dark, theme),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode themeMode, ThemeData theme) {
    final isSelected = currentThemeMode.value == themeMode;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          themeService.getThemeModeIcon(themeMode),
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          _getThemeModeText(themeMode),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(
          Icons.check_circle,
          color: theme.colorScheme.primary,
        )
            : null,
        onTap: () => _changeTheme(themeMode),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordForm(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'change_password'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'current_password'.tr,
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'new_password'.tr,
                prefixIcon: const Icon(Icons.lock_open),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'confirm_password'.tr,
                prefixIcon: const Icon(Icons.lock_open),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Obx(() => FilledButton.icon(
                onPressed: isLoading.value ? null : _changePassword,
                icon: isLoading.value
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.key),
                label: Text('change_password'.tr),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
            label: Text('logout'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'language'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildLanguageOption(const Locale('uz', 'UZ'), theme),
                const SizedBox(height: 8),
                _buildLanguageOption(const Locale('ru', 'RU'), theme),
                const SizedBox(height: 8),
                _buildLanguageOption(const Locale('en', 'US'), theme),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(Locale locale, ThemeData theme) {
    final isSelected = currentLocale.value == locale;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Text(
          languageService.getLanguageFlag(locale),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          languageService.getLanguageText(locale),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: () => _changeLanguage(locale),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _changeTheme(ThemeMode themeMode) {
    currentThemeMode.value = themeMode;
    themeService.changeThemeMode(themeMode);
  }

  void _changeLanguage(Locale locale) {
    currentLocale.value = locale;
    languageService.changeLanguage(locale);
  }

  Future<void> _changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('error'.tr, 'password_mismatch'.tr);
      return;
    }

    if (newPasswordController.text.isEmpty) {
      Get.snackbar('error'.tr, 'enter_new_password'.tr);
      return;
    }

    try {
      isLoading.value = true;

      Get.snackbar('password_changed'.tr.split(' ')[0], 'password_changed'.tr);
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      Get.snackbar('error'.tr, '${'password_change_error'.tr}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              authService.logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'S'; // Default fallback
    }

    final words = trimmedName.split(' ');
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'S'; // Default fallback
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system_theme'.tr;
      case ThemeMode.light:
        return 'light_theme'.tr;
      case ThemeMode.dark:
        return 'dark_theme'.tr;
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}