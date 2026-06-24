import 'package:hive_flutter/hive_flutter.dart';

import 'model/pack_item.dart';
import 'model/pack_session.dart';

/// Registers Hive adapters and opens the PackCheck storage boxes.
class PackCheckHiveBoxes {
  static const String sessionsBox = 'pack_sessions';

  static Future<void> openBoxes() async {
    Hive
      ..registerAdapter(PackItemAdapter())
      ..registerAdapter(PackSessionAdapter());
    await Hive.openBox<PackSession>(sessionsBox);
  }
}
