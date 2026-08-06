import 'package:hive_flutter/hive_flutter.dart';

abstract final class GroupSessionHiveBox {
  static const String boxName = 'group_session';

  static Future<void> openBox() async {
    await Hive.openBox<dynamic>(boxName);
  }
}
