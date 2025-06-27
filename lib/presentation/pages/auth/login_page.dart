import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../core/themes/app_themes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/loading_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static final MaskTextInputFormatter _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final colors = context.colors;

    // Set default +998 prefix if phone field is empty
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
              _buildHeader(colors),
              const SizedBox(height: 48),
              _buildLoginForm(authController, colors),
              const SizedBox(height: 24),
              _buildRoleSelector(authController, colors),
              const SizedBox(height: 32),
              _buildLoginButton(authController, colors),
              const SizedBox(height: 24),
              _buildFooter(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors) {
    return Column(
      children: [
        // App logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.info,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.info.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Welcome text
        Text(
          'Xush kelibsiz!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.primaryText,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Hisobingizga kirish uchun ma\'lumotlaringizni kiriting',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: colors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthController authController, AppThemeColors colors) {
    return Column(
      children: [
        // Phone number field
        TextFormField(
          controller: authController.phoneController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
            _phoneMaskFormatter,
          ],
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Telefon raqami',
            hintText: '+998 XX XXX XX XX',
            prefixIcon: Icon(Icons.phone, color: colors.info),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.info),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Password field
        Obx(() => TextFormField(
          controller: authController.passwordController,
          obscureText: !authController.isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Parol',
            hintText: 'Parolingizni kiriting',
            prefixIcon: Icon(Icons.lock, color: colors.info),
            suffixIcon: IconButton(
              icon: Icon(
                authController.isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: colors.secondaryText,
              ),
              onPressed: authController.togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.info),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRoleSelector(AuthController authController, AppThemeColors colors) {
    final roles = [
      {'value': 'student', 'label': 'Talaba'},
      {'value': 'teacher', 'label': 'Ustoz'},
      {'value': 'parent', 'label': 'Ota-ona'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rolni tanlang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: colors.secondaryText.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Obx(() => DropdownButton<String>(
            value: authController.selectedRole,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: colors.secondaryText),
            items: roles.map((role) {
              return DropdownMenuItem<String>(
                value: role['value']!,
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
          )),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthController authController, AppThemeColors colors) {
    return Obx(() {
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
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text(
            'Kirish',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFooter(AppThemeColors colors) {
    return Column(
      children: [
        Text(
          'Muammoga duch keldingizmi?',
          style: TextStyle(
            fontSize: 14,
            color: colors.secondaryText,
          ),
        ),

        const SizedBox(height: 8),

        TextButton(
          onPressed: () {
            // Handle support contact
          },
          child: Text(
            'Yordam olish',
            style: TextStyle(
              fontSize: 14,
              color: colors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getRoleIcon(String role) {
    return switch (role) {
      'student' => Icons.school_outlined,
      'teacher' => Icons.person_outline,
      'parent' => Icons.family_restroom_outlined,
      _ => Icons.person_outline,
    };
  }
}