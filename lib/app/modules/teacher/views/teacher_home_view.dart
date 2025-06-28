import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../services/auth_service.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'O\'qituvchi',
        actions: [
          IconButton(
            onPressed: () => authService.logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Chiqish',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Role Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.teacherColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school,
                  size: 60,
                  color: AppColors.teacherColor,
                ),
              ),

              const SizedBox(height: 24),

              // Welcome text
              Text(
                'Xush kelibsiz!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.teacherColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Auth info cards
              _buildInfoCard(
                'Rol',
                authService.userRole ?? 'Unknown',
                Icons.person,
                context,
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                'Ism-familiya',
                authService.userFullName ?? 'Unknown',
                Icons.account_circle,
                context,
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                'Telefon',
                authService.userPhone ?? 'Unknown',
                Icons.phone,
                context,
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                'Token Status',
                authService.token != null ? 'Active' : 'Inactive',
                Icons.security,
                context,
              ),

              const SizedBox(height: 32),

              // Coming soon message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'O\'qituvchi paneli tez orada...',
                        style: TextStyle(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
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
}