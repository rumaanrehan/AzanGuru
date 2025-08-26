import 'package:azan_guru_mobile/constant/enum.dart';

class MDLSetting {
  String? title;
  bool showIcon;
  SettingOptionType? settingOptionType;

  MDLSetting({
    this.title,
    this.showIcon = true,
    this.settingOptionType,
  });
}
