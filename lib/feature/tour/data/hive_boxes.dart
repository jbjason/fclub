import 'package:fclub/feature/tour/data/model/extra_payment_model.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/data/model/tour_session.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class TourHiveBoxes {
  // ── Session-based storage (current) ───────────────────────────────────────
  static const String sessionsBox = 'tour_sessions';

  static Future<void> openBoxes() async {
    // Embedded-type adapters used by TourSession
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(TourMemberModelAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(TourExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(ExtraPaymentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(TourSessionAdapter());
    }

    await Hive.openBox<TourSession>(sessionsBox);
  }
}
