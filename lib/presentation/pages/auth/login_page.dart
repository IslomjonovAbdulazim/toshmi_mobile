import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/themes/app_themes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/loading_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // ✅ Uzbek phone number mask formatter
  static final MaskTextInputFormatter _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final colors = context.colors;

    // ✅ Set default +998 prefix if phone field is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.phoneController.text.isEmpty) {
        authController.phoneController.text = '+998 ';
        authController.phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: authController.phoneController.text.length),
        );
      }
    });

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
              color: colors.info.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.school_outlined,
            size: 60,
            color: colors.info,
          ),
        ),

        const SizedBox(height: 24),

        // App Title
        Text(
          'Toshmi',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.info,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Ta\'lim markaziga xush kelibsiz',
          style: TextStyle(
            fontSize: 16,
            color: colors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthController authController, AppThemeColors colors) {
    return Column(
      children: [
        // Phone Input
        Obx(() => _buildPhoneInput(authController, colors)),

        const SizedBox(height: 16),

        // Password Input
        Obx(() => _buildPasswordInput(authController, colors)),

        const SizedBox(height: 16),

        // Role Selection
        Obx(() => _buildRoleSelection(authController, colors)),

        const SizedBox(height: 32),

        // Login Button
        Obx(() => _buildLoginButton(authController, colors)),
      ],
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
          inputFormatters: [
            _phoneMaskFormatter,
            // Prevent deletion of +998 prefix
            FilteringTextInputFormatter.allow(RegExp(r'[\+0-9\s]')),
          ],
          onChanged: (value) {
            // Ensure +998 prefix is always present
            if (!value.startsWith('+998')) {
              authController.phoneController.text = '+998 ';
              authController.phoneController.selection = TextSelection.fromPosition(
                TextPosition(offset: authController.phoneController.text.length),
              );
            }
          },
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
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
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
          'Rol tanlang',
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
            border: Border.all(
              color: colors.divider,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: authController.selectedRole,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: colors.secondaryText,
              ),
              style: TextStyle(color: colors.primaryText),
              dropdownColor: colors.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
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
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthController authController, AppThemeColors colors) {
    final isLoading = authController.isLoginLoading;
    final isFormValid = authController.formValid;

    return SizedBox(
      width: double.infinity,
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

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.school_outlined;
      case 'teacher':
        return Icons.person_outline;
      case 'parent':
        return Icons.family_restroom_outlined;
      default:
        return Icons.person_outline;
    }
  }
}