import 'package:fclub/feature/club/data/model/payment_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class ClubHiveBox {
  static const String boxName = 'club_payment_entries';

  static Future<void> openBox() async {
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(PaymentEntryAdapter());
    }
    await Hive.openBox<PaymentEntry>(boxName);
  }
}
