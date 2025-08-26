import 'package:azan_guru_mobile/service/localization/ar_sa.dart';
import 'package:azan_guru_mobile/service/localization/en.dart';
import 'package:azan_guru_mobile/service/localization/ur.dart';

abstract class AppTranslation {
  static Map<String, Map<String, String>> translationsKeys = {
    "en": english,
    "ar-sa": arabic,
    "ur": urdu,
  };
}