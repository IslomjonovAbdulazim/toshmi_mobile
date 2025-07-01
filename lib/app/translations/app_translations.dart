import 'package:get/get.dart';

import 'en_US.dart';
import 'ru_RU.dart';
import 'uz_UZ.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'uz_UZ': uzUZ,
    'ru_RU': ruRU,
    'en_US': enUS,
  };
}