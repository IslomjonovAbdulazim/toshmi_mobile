import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/themes/app_themes.dart';

class ThemeConfig {
  // Configure app themes
  static ThemeData get lightTheme => AppThemes.lightTheme;
  static ThemeData get darkTheme => AppThemes.darkTheme;

  // Configure system UI overlay style for light theme
  static SystemUiOverlayStyle get lightSystemUiOverlay {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFFAFAFA),
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Color(0xFFE5E7EB),
    );
  }

  // Configure system UI overlay style for dark theme
  static SystemUiOverlayStyle get darkSystemUiOverlay {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Color(0xFF404040),
    );
  }

  // Apply system UI overlay based on theme
  static void setSystemUIOverlay(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        SystemChrome.setSystemUIOverlayStyle(lightSystemUiOverlay);
        break;
      case ThemeMode.dark:
        SystemChrome.setSystemUIOverlayStyle(darkSystemUiOverlay);
        break;
      case ThemeMode.system:
      // Let the system handle it
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
        );
        break;
    }
  }

  // Initialize theme configuration
  static void initialize() {
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay
    setSystemUIOverlay(ThemeMode.system);
  }

  // Configuration for different screen sizes
  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (screenWidth < 1024) {
      // Tablet
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      // Desktop
      return const EdgeInsets.symmetric(horizontal: 64);
    }
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return baseSize;
    } else if (screenWidth < 1024) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  // Common border radius
  static BorderRadius get defaultBorderRadius => BorderRadius.circular(12);
  static BorderRadius get smallBorderRadius => BorderRadius.circular(8);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(16);
  static BorderRadius get extraLargeBorderRadius => BorderRadius.circular(24);

  // Common shadows
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get largeShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // Spacing constants
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // Screen breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // App bar height
  static double getAppBarHeight(BuildContext context) {
    return kToolbarHeight + getSafeAreaPadding(context).top;
  }

  // Bottom navigation bar height
  static double getBottomNavHeight(BuildContext context) {
    return kBottomNavigationBarHeight + getSafeAreaPadding(context).bottom;
  }
}

// Extension for easy access to theme configuration
extension ThemeConfigExtension on BuildContext {
  EdgeInsets get screenPadding => ThemeConfig.getScreenPadding(this);
  EdgeInsets get safeAreaPadding => ThemeConfig.getSafeAreaPadding(this);
  double get appBarHeight => ThemeConfig.getAppBarHeight(this);
  double get bottomNavHeight => ThemeConfig.getBottomNavHeight(this);

  bool get isMobile => ThemeConfig.isMobile(this);
  bool get isTablet => ThemeConfig.isTablet(this);
  bool get isDesktop => ThemeConfig.isDesktop(this);

  double responsiveFontSize(double baseSize) =>
      ThemeConfig.getResponsiveFontSize(this, baseSize);
}