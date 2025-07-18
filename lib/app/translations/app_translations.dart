import 'package:get/get.dart';
import 'package:toshmi_mobile/app/translations/parent.dart';
import 'package:toshmi_mobile/app/translations/widgets.dart';

import 'auth.dart';
import 'student.dart';
import 'teacher.dart';

class AppTranslations extends Translations {
  final Map<String, String> uz = {};
  final Map<String, String> ru = {};
  final Map<String, String> en = {};

  AppTranslations() {
    // uz
    uz.addAll(teacherUz);
    uz.addAll(authUz);
    uz.addAll(parentUz);
    uz.addAll(widgetsUz);
    uz.addAll(studentUz);

    // ru
    ru.addAll(authRu);
    ru.addAll(teacherRu);
    ru.addAll(parentRu);
    ru.addAll(widgetsRu);
    ru.addAll(studentRu);

    // en
    en.addAll(teacherUs);
    en.addAll(authEn);
    en.addAll(parentEn);
    en.addAll(widgetsEn);
    en.addAll(studentEn);
  }

  @override
  Map<String, Map<String, String>> get keys => {
    'uz_UZ': uz,
    'ru_RU': ru,
    'en_US': en,
  };
}
