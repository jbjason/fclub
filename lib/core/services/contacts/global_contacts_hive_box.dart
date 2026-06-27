import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class GlobalContactsHiveBox {
  static const String boxName = 'global_contacts';

  static Future<void> openBox() async {
    if (!Hive.isAdapterRegistered(40)) {
      Hive.registerAdapter(AppContactAdapter());
    }
    await Hive.openBox<AppContact>(boxName);
  }
}
