import 'package:fclub/feature/locker/data/model/locker_expense.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class LockerHiveBox {
  static const String expensesBoxName = 'locker_expenses';

  /// Untyped box holding the single admin-editable base balance.
  static const String metaBoxName = 'locker_meta';

  static Future<void> openBoxes() async {
    if (!Hive.isAdapterRegistered(60)) {
      Hive.registerAdapter(LockerExpenseAdapter());
    }

    await Future.wait([
      Hive.openBox<LockerExpense>(expensesBoxName),
      Hive.openBox<dynamic>(metaBoxName),
    ]);
  }
}
