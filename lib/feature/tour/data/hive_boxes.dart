import 'package:fclub/feature/tour/data/model/extra_payment_model.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class TourHiveBoxes {
  static const String membersBox = 'tour_members';
  static const String expensesBox = 'tour_expenses';
  static const String extraPaymentsBox = 'tour_extra_payments';
  static const String metaBox = 'tour_meta';

  /// Registers adapters and opens all tour boxes. Assumes [Hive.initFlutter]
  /// has already run (done once in `main()` via `GlobalService.initialize`).
  static Future<void> openBoxes() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(TourMemberModelAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(TourExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(ExtraPaymentModelAdapter());
    }

    await Future.wait([
      Hive.openBox<TourMemberModel>(membersBox),
      Hive.openBox<TourExpenseModel>(expensesBox),
      Hive.openBox<ExtraPaymentModel>(extraPaymentsBox),
      Hive.openBox<dynamic>(metaBox),
    ]);
  }
}
