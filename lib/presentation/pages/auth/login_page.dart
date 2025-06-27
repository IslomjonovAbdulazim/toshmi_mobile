import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_themes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/loading_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // App Logo and Title
              _buildHeader(colors),

              const SizedBox(height: 48),

              // Login Form
              _buildLoginForm(authController, colors),

              const SizedBox(height: 24),

              // Additional Options
              _buildAdditionalOptions(colors),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Column(
      children: [
        // App Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: colors.info.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.school,
            size: 60,
            color: colors.info,
          ),
        ),

        const SizedBox(height: 24),

        // App Title
        Text(
          'Toshmi Mobile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.primaryText,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Ta\'lim boshqaruv tizimi',
          style: TextStyle(
            fontSize: 16,
            color: colors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthController authController, AppThemeColors colors) {
    return Card(
      elevation: 4,
      color: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form Title
            Text(
              'Tizimga kirish',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Phone Input
            Obx(() => _buildPhoneInput(authController, colors)),

            const SizedBox(height: 16),

            // Password Input
            Obx(() => _buildPasswordInput(authController, colors)),

            const SizedBox(height: 16),

            // Role Selection
            Obx(() => _buildRoleSelection(authController, colors)),

            const SizedBox(height: 20),

            // Remember Me Checkbox
            Obx(() => _buildRememberMe(authController, colors)),

            const SizedBox(height: 24),

            // Login Button
            Obx(() => _buildLoginButton(authController, colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(AuthController authController, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telefon raqami',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: authController.phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: colors.primaryText),
          decoration: InputDecoration(
            hintText: '+998 90 123 45 67',
            hintStyle: TextStyle(color: colors.secondaryText),
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: colors.secondaryText,
            ),
            filled: true,
            fillColor: colors.secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.info, width: 2),
            ),
            errorText: authController.phoneError,
            errorStyle: TextStyle(color: colors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput(AuthController authController, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parol',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: authController.passwordController,
          obscureText: !authController.isPasswordVisible,
          style: TextStyle(color: colors.primaryText),
          decoration: InputDecoration(
            hintText: 'Parolingizni kiriting',
            hintStyle: TextStyle(color: colors.secondaryText),
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: colors.secondaryText,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                authController.isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: colors.secondaryText,
              ),
              onPressed: authController.togglePasswordVisibility,
            ),
            filled: true,
            fillColor: colors.secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.info, width: 2),
            ),
            errorText: authController.passwordError,
            errorStyle: TextStyle(color: colors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection(AuthController authController, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lavozim',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: authController.selectedRole,
            style: TextStyle(color: colors.primaryText),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.person_outline,
                color: colors.secondaryText,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.info, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            dropdownColor: colors.cardBackground,
            items: authController.roleOptions.map((role) {
              return DropdownMenuItem<String>(
                value: role['value'],
                child: Row(
                  children: [
                    Icon(
                      _getRoleIcon(role['value']!),
                      size: 20,
                      color: colors.secondaryText,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      role['label']!,
                      style: TextStyle(color: colors.primaryText),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                authController.setSelectedRole(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMe(AuthController authController, AppThemeColors colors) {
    return Row(
      children: [
        Checkbox(
          value: authController.rememberMe,
          onChanged: (_) => authController.toggleRememberMe(),
          activeColor: colors.info,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Meni eslab qol',
          style: TextStyle(
            fontSize: 14,
            color: colors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthController authController, AppThemeColors colors) {
    final isLoading = authController.isLoginLoading;
    final isFormValid = authController.formValid;

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading || !isFormValid ? null : authController.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.info,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.secondaryText.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? LoadingWidgets.button(size: 20)
            : Text(
          'Kirish',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions(AppThemeColors colors) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: colors.divider),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'yoki',
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: colors.divider),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Help Options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildHelpButton(
              icon: Icons.help_outline,
              label: 'Yordam',
              onTap: () => _showHelpDialog(),
              colors: colors,
            ),
            _buildHelpButton(
              icon: Icons.info_outline,
              label: 'Ma\'lumot',
              onTap: () => _showInfoDialog(),
              colors: colors,
            ),
            _buildHelpButton(
              icon: Icons.phone,
              label: 'Aloqa',
              onTap: () => _showContactDialog(),
              colors: colors,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Version Info
        Text(
          'Versiya 1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: colors.tertiaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(
              icon,
              color: colors.info,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
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

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Yordam'),
        content: const Text(
          'Tizimga kirish uchun:\n\n'
              '1. Telefon raqamingizni kiriting\n'
              '2. Parolingizni kiriting\n'
              '3. Lavozimingizni tanlang\n'
              '4. "Kirish" tugmasini bosing\n\n'
              'Agar parolingizni unutgan bo\'lsangiz, '
              'administratorga murojaat qiling.',
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

  void _showInfoDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Dastur haqida'),
        content: const Text(
          'Toshmi Mobile - Ta\'lim muassasalari uchun '
              'boshqaruv tizimi.\n\n'
              'Bu dastur orqali siz:\n'
              '• Vazifalarni ko\'rishingiz\n'
              '• Baholarni kuzatishingiz\n'
              '• Davomatni nazorat qilishingiz\n'
              '• Bildirishnomalar olishingiz mumkin.',
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

  void _showContactDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Aloqa'),
        content: const Text(
          'Texnik yordam uchun:\n\n'
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
}