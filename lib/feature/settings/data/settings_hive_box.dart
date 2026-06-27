import 'package:hive_flutter/hive_flutter.dart';

abstract class SettingsHiveBox {
  static const String boxName = 'app_settings';

  static Future<void> openBox() async {
    await Hive.openBox<dynamic>(boxName);
  }
}
