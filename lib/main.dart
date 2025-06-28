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

  // Initialize services
  await initServices();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

Future<void> initServices() async {
  // Core services
  await Get.putAsync(() => StorageService().init());
  Get.put(StorageProvider());

  // Auth service (required by ApiService)
  await Get.putAsync(() => AuthService().init());

  // API services
  Get.put(ApiService());
  Get.put(ApiProvider());

  // Other services
  Get.put(FileService());
  Get.put(NotificationService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Maktab Boshqaruv Tizimi',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routes
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Text scaling restrictions
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            boldText: false,
          ),
          child: child!,
        );
      },

      // Locale
      locale: const Locale('uz', 'UZ'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}

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