import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_themes.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Set portrait orientation only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  print('🚀 Starting ToshMI Mobile App');

  runApp(const ToshMIApp());
}

class ToshMIApp extends StatelessWidget {
  const ToshMIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // App Configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.light, // Always use light theme for now

      // Text Scale Configuration - DISABLE USER SCALING
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Fixed text scale - no user scaling
            boldText: false, // Disable bold text accessibility
          ),
          child: child!,
        );
      },

      // Navigation Configuration
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
      initialBinding: AppBindings(),

      // Localization
      locale: const Locale('uz', 'UZ'),
      fallbackLocale: const Locale('uz', 'UZ'),

      // GetX Configuration
      defaultTransition: Transition.rightToLeft,
      transitionDuration: AppConstants.animationNormal,

      // Route Configuration
      routingCallback: (routing) {
        print('🔄 Navigation: ${routing?.current}');
      },

      // Error Handling
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const NotFoundScreen(),
      ),

      // Global Settings
      enableLog: AppConstants.logApiCalls,
      logWriterCallback: (text, {bool isError = false}) {
        if (isError) {
          print('❌ GetX Error: $text');
        } else {
          print('ℹ️ GetX: $text');
        }
      },
    );
  }
}

// 404 Screen for unknown routes
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahifa topilmadi'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppConstants.iconSizeXL * 2,
                color: AppConstants.errorColor,
              ),
              const SizedBox(height: AppConstants.marginLG),
              Text(
                'Sahifa topilmadi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppConstants.textPrimaryColor,
                  fontWeight: AppConstants.fontWeightBold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.marginMD),
              Text(
                'Siz qidirayotgan sahifa mavjud emas yoki ko\'chirilgan.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.marginXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => AppRoutes.toDashboard(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.paddingMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                    ),
                  ),
                  child: const Text(
                    'Bosh sahifaga qaytish',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeLG,
                      fontWeight: AppConstants.fontWeightMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}