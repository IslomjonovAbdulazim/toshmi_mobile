import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/services/storage_service.dart';
import 'app/services/api_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/file_service.dart';
import 'app/services/notification_service.dart';
import 'app/data/providers/api_provider.dart';
import 'app/data/providers/storage_provider.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await _initializeServices();

  // Configure system UI
  _configureSystemUI();

  runApp(const ToshmiApp());
}

/// Initialize all required services in the correct order
Future<void> _initializeServices() async {
  try {
    print('🚀 Initializing Toshmi services...');

    // 1. Storage services (required first)
    await Get.putAsync(() => StorageService().init());
    Get.put(StorageProvider());
    print('✅ Storage services initialized');

    // 2. Authentication service
    await Get.putAsync(() => AuthService().init());
    print('✅ Authentication service initialized');

    // 3. API services
    Get.put(ApiService());
    Get.put(ApiProvider());
    print('✅ API services initialized');

    // 4. Utility services (lazy loaded)
    Get.put(FileService());
    Get.lazyPut(() => NotificationService());
    print('✅ Utility services initialized');

    print('🎉 All services ready');
  } catch (e) {
    print('❌ Service initialization error: $e');
    // Continue startup - app will handle errors gracefully
  }
}

/// Configure system UI appearance
void _configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class ToshmiApp extends StatelessWidget {
  const ToshmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // App configuration
      title: 'Toshmi - Maktab Boshqaruv Tizimi',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Navigation configuration
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Error handling
      unknownRoute: GetPage(
        name: '/404',
        page: () => const NotFoundPage(),
      ),

      // Text scaling and accessibility
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            boldText: false,
          ),
          child: child!,
        );
      },

      // Localization
      locale: const Locale('uz', 'UZ'),
      fallbackLocale: const Locale('en', 'US'),

      // Navigation logging (debug mode only)
      routingCallback: (routing) {
        if (routing != null && kDebugMode) {
          print('🧭 Navigation: ${routing.current}');
        }
      },
    );
  }
}

/// 404 Not Found page
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahifa topilmadi'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sahifa topilmadi',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Siz qidirayotgan sahifa mavjud emas yoki ko\'chirilgan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Get.offAllNamed('/splash'),
                icon: const Icon(Icons.home),
                label: const Text('Bosh sahifaga qaytish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension methods for service initialization
extension StorageServiceExtension on StorageService {
  Future<StorageService> init() async {
    await onInit();
    return this;
  }
}

extension AuthServiceExtension on AuthService {
  Future<AuthService> init() async {
    await onInit();
    return this;
  }
}