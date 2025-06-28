import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/custom_button.dart';
import '../../../utils/widgets/common/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class ChangePasswordView extends GetView<AuthController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Parolni o\'zgartirish',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.changePasswordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 48,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Xavfsizlik uchun parolni o\'zgartiring',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Old Password
              Obx(() => CustomTextField(
                label: 'Joriy parol',
                controller: controller.oldPasswordController,
                obscureText: !controller.isOldPasswordVisible.value,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isOldPasswordVisible.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.toggleOldPasswordVisibility,
                ),
                validator: controller.validatePassword,
              )),

              const SizedBox(height: 16),

              // New Password
              Obx(() => CustomTextField(
                label: 'Yangi parol',
                controller: controller.newPasswordController,
                obscureText: !controller.isNewPasswordVisible.value,
                prefixIcon: const Icon(Icons.lock), // todo might lock_check
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isNewPasswordVisible.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.toggleNewPasswordVisibility,
                ),
                validator: controller.validatePassword,
              )),

              const SizedBox(height: 16),

              // Confirm Password
              Obx(() => CustomTextField(
                label: 'Yangi parolni tasdiqlash',
                controller: controller.confirmPasswordController,
                obscureText: !controller.isConfirmPasswordVisible.value,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                validator: controller.validateConfirmPassword,
              )),

              const SizedBox(height: 24),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Parol talablari:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement('Kamida 6 ta belgi'),
                    _buildRequirement('Katta va kichik harflar'),
                    _buildRequirement('Raqam va maxsus belgilar'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              Obx(() => CustomButton(
                text: 'Parolni o\'zgartirish',
                onPressed: controller.changePassword,
                isLoading: controller.isLoading.value,
                height: 56,
              )),

              const SizedBox(height: 16),

              // Cancel Button
              CustomOutlinedButton(
                text: 'Bekor qilish',
                onPressed: () => Get.back(),
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
            size: 14,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}