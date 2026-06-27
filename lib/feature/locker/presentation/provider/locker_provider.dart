import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:fclub/feature/locker/data/locker_hive_box.dart';
import 'package:fclub/feature/locker/data/model/locker_expense.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Central source of truth for the club's cash locker — a single running
/// balance (admin-editable, representing total collected from members) and
/// the list of expenses recorded against it.
class LockerProvider with ChangeNotifier {
  LockerProvider(this._clubProvider)
      : _expensesBox = Hive.box<LockerExpense>(LockerHiveBox.expensesBoxName),
        _metaBox = Hive.box<dynamic>(LockerHiveBox.metaBoxName);

  final Box<LockerExpense> _expensesBox;
  final Box<dynamic> _metaBox;
  final ClubProvider _clubProvider;
  final Uuid _uuid = const Uuid();

  static const String _baseBalanceKey = 'base_balance';

  /// The admin-set "total collected" figure expenses are deducted from.
  double get baseBalance => (_metaBox.get(_baseBalanceKey) as num?)?.toDouble() ?? 0;

  List<LockerExpense> get expenses =>
      _expensesBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  double get totalExpenses =>
      expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

  /// Cash actually left in the locker right now.
  double get currentCash => baseBalance - totalExpenses;

  /// What Club's payment history has actually collected so far — offered
  /// as a one-tap suggestion when the admin edits the balance.
  double get clubCollectedTotal => _clubProvider.entries
      .where((entry) => entry.status == PaymentStatus.paid)
      .fold<double>(0, (sum, entry) => sum + entry.amount);

  bool get hasDemoData => _metaBox.containsKey(_baseBalanceKey);

  Future<void> setBaseBalance(double amount) async {
    await _metaBox.put(_baseBalanceKey, amount);
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final expense = LockerExpense(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      date: date,
      note: note,
    );
    await _expensesBox.put(expense.id, expense);
    notifyListeners();
  }

  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final expense = LockerExpense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      note: note,
    );
    await _expensesBox.put(expense.id, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _expensesBox.delete(id);
    notifyListeners();
  }

  Future<void> seedDemoData() async {
    if (hasDemoData) return;

    final seedBalance = clubCollectedTotal > 0 ? clubCollectedTotal : 65000.0;
    await _metaBox.put(_baseBalanceKey, seedBalance);

    final now = DateTime.now();
    final demoExpenses = [
      LockerExpense(
        id: _uuid.v4(),
        title: 'Venue Rent',
        amount: 8000,
        date: now.subtract(const Duration(days: 25)),
        note: 'Monthly meeting hall',
      ),
      LockerExpense(
        id: _uuid.v4(),
        title: 'Stationery & Printing',
        amount: 1500,
        date: now.subtract(const Duration(days: 14)),
      ),
      LockerExpense(
        id: _uuid.v4(),
        title: 'Refreshments',
        amount: 3200,
        date: now.subtract(const Duration(days: 5)),
        note: 'General meeting',
      ),
    ];
    for (final expense in demoExpenses) {
      await _expensesBox.put(expense.id, expense);
    }
    notifyListeners();
  }
}
