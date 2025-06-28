import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/custom_button.dart';
import '../../../utils/widgets/common/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class ProfileView extends GetView<AuthController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profil',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    authService.userFullName ?? 'Noma\'lum',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      authService.userRole?.roleUz ?? 'Noma\'lum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    authService.userPhone ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Profile Form
            Form(
              key: controller.profileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // First Name
                  CustomTextField(
                    label: 'Ism',
                    controller: controller.firstNameController,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) => controller.validateName(value, 'Ism'),
                  ),

                  const SizedBox(height: 16),

                  // Last Name
                  CustomTextField(
                    label: 'Familiya',
                    controller: controller.lastNameController,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) => controller.validateName(value, 'Familiya'),
                  ),

                  const SizedBox(height: 24),

                  // Update Button
                  Obx(() => CustomButton(
                    text: 'Profilni yangilash',
                    onPressed: controller.updateProfile,
                    isLoading: controller.isLoading.value,
                    height: 56,
                  )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionTile(
              icon: Icons.lock_outline,
              title: 'Parolni o\'zgartirish',
              subtitle: 'Xavfsizlik uchun parolni yangilang',
              onTap: () => Get.toNamed('/change-password'),
              color: AppColors.warning,
            ),

            const SizedBox(height: 12),

            _buildActionTile(
              icon: Icons.notifications,
              title: 'Bildirishnomalar',
              subtitle: 'Bildirishnoma sozlamalarini boshqaring',
              onTap: () => Get.toNamed('/notifications'),
              color: AppColors.info,
            ),

            const SizedBox(height: 12),

            _buildActionTile(
              icon: Icons.help_outline,
              title: 'Yordam',
              subtitle: 'FAQ va qo\'llab-quvvatlash',
              onTap: () => Get.toNamed('/help'),
              color: AppColors.success,
            ),

            const SizedBox(height: 24),

            // Logout Button
            CustomOutlinedButton(
              text: 'Chiqish',
              onPressed: controller.logout,
              height: 56,
              borderColor: AppColors.error,
              textColor: AppColors.error,
              icon: const Icon(Icons.logout, size: 20),
            ),

            const SizedBox(height: 24),

            // App Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Maktab Boshqaruv Tizimi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versiya 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}