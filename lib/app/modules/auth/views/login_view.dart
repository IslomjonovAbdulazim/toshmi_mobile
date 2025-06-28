import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      type: MaskAutoCompletionType.lazy,
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

                // App Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App Title
                Text(
                  'Toshmi',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Maktab Boshqaruv Tizimi',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Hisobingizga kiring',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 48),

                // Error Display
                Obx(() => controller.hasLoginError.value
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.loginError.value,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink()),

                // Role Selection
                Obx(() => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: controller.roles.map((role) {
                      final isSelected = controller.selectedRole.value == role['value'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.setRole(role['value']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                                  : null,
                            ),
                            child: Text(
                              role['label']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),

                const SizedBox(height: 32),

                // Phone Number Field
                CustomTextField(
                  label: 'Telefon raqami',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                  inputFormatters: [phoneFormatter],
                  validator: controller.validatePhone,
                  hint: '+998 (90) 123-45-67',
                ),

                const SizedBox(height: 20),

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
                  onPressed: controller.isLoginLoading.value ? null : controller.login,
                  isLoading: controller.isLoginLoading.value,
                  height: 56,
                  backgroundColor: AppColors.primaryBlue,
                )),

                const SizedBox(height: 32),

                // Help Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Yordam kerakmi?',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Agar kirish parolingizni unutgan bo\'lsangiz, maktab ma\'muriyatiga murojaat qiling.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Version Info
                Text(
                  'Versiya 1.0.0',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}