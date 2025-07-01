// lib/app/services/language_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageService {
  static const String _key = 'language';
  final GetStorage _box = GetStorage();

  Locale get locale => _loadLocaleFromBox();


  void saveLocaleToBox(Locale locale) {
    _box.write(_key, locale.languageCode);
  }

  void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
    saveLocaleToBox(locale);
  }

  Locale _loadLocaleFromBox() {
    final languageCode = _box.read(_key) ?? 'uz';
    switch (languageCode) {
      case 'uz': return const Locale('uz', 'UZ');
      case 'ru': return const Locale('ru', 'RU');
      case 'en': return const Locale('en', 'US');
      default: return const Locale('uz', 'UZ');
    }
  }

  String getLanguageText(Locale locale) {
    switch (locale.languageCode) {
      case 'uz':
        return 'uzbek'.tr;
      case 'ru':
        return 'russian'.tr;
      case 'en':
        return 'english'.tr;
      default:
        return 'uzbek'.tr;
    }
  }

  String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'uz':
        return '🇺🇿';
      case 'ru':
        return '🇷🇺';
      case 'en':
        return '🇺🇸';
      default:
        return '🇺🇿';
    }
  }
}
