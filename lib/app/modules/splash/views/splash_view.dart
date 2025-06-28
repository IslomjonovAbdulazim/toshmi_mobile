import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlueDark,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.school_rounded,
                size: 80,
                color: Colors.white,
              ),

              SizedBox(height: 24),

              // App Name
              Text(
                'Toshmi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Maktab Boshqaruv Tizimi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 48),

              // Loading indicator
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),

              SizedBox(height: 16),

              Text(
                'Yuklanmoqda...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}