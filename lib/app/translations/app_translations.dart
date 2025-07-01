import 'package:get/get.dart';

import 'teacher.dart';
import 'auth.dart';
import 'student.dart';

class AppTranslations extends Translations {
  final Map<String, String> uz = {};
  final Map<String, String> ru = {};
  final Map<String, String> en = {};
  AppTranslations() {
    uz.addAll(teacherUz);
    ru.addAll(teacherRu);
    en.addAll(teacherUs);
    uz.addAll(authUz);
    ru.addAll(authRu);
    en.addAll(authEn);
  }

  @override
  Map<String, Map<String, String>> get keys => {
    'uz_UZ': uz,
    'ru_RU': ru,
    'en_US': en,
  };
}