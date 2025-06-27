import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ToshmiApp());
}

class ToshmiApp extends StatelessWidget {
  const ToshmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Toshmi Mobile',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _getThemeMode(),
      locale: const Locale('uz', 'UZ'),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      unknownRoute: AppPages.unknownRoute,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).textScaler.clamp(
            minScaleFactor: 0.8,
            maxScaleFactor: 1.2,
          ),
        ),
        child: child!,
      ),
    );
  }

  ThemeMode _getThemeMode() {
    final storage = GetStorage();
    final savedTheme = storage.read<String>('theme_mode');
    return switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}