import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_button.dart';
import '../../../utils/widgets/common/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneFormatter = MaskTextInputFormatter(
      mask: '+998 (##) ###-##-##',
      filter: {"#": RegExp(r'[0-9]')},
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo/Title
                Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 24),

                Text(
                  'Maktab Tizimi',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),

                Text(
                  'Hisobingizga kiring',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 48),

                // Role Selection
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: controller.roles.map((role) {
                      final isSelected = controller.selectedRole.value == role['value'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.setRole(role['value']!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role['label']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),

                const SizedBox(height: 32),

                // Phone Field
                CustomTextField(
                  label: 'Telefon raqami',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                  inputFormatters: [phoneFormatter],
                  validator: controller.validatePhone,
                  hint: '+998 (90) 123-45-67',
                ),

                const SizedBox(height: 16),

                // Password Field
                Obx(() => CustomTextField(
                  label: 'Parol',
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  validator: controller.validatePassword,
                )),

                const SizedBox(height: 32),

                // Login Button
                Obx(() => CustomButton(
                  text: 'Kirish',
                  onPressed: controller.login,
                  isLoading: controller.isLoading.value,
                  height: 56,
                )),

              ],
            ),
          ),
        ),
      ),
    );
  }
}