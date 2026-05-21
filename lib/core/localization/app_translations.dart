import 'package:get/get.dart';
import 'package:ninaivu/core/localization/app_translations_en.dart';
import 'package:ninaivu/core/localization/app_translations_ta.dart';
import 'package:ninaivu/core/localization/app_translations_te.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': englishTranslations,
    'ta_IN': tamilTranslations,
    'te_IN': teluguTranslations,
  };
}
