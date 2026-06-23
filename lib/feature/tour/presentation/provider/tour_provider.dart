import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
import 'package:fclub/feature/tour/data/expense_category.dart';
import 'package:fclub/feature/tour/data/hive_boxes.dart';
import 'package:fclub/feature/tour/data/model/extra_payment_model.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/data/model/tour_summary.dart';
import 'package:fclub/feature/tour/data/tour_calculator.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class TourProvider with ChangeNotifier {
  TourProvider()
    : _membersBox = Hive.box<TourMemberModel>(TourHiveBoxes.membersBox),
      _expensesBox = Hive.box<TourExpenseModel>(TourHiveBoxes.expensesBox),
      _extraPaymentsBox = Hive.box<ExtraPaymentModel>(
        TourHiveBoxes.extraPaymentsBox,
      ),
      _metaBox = Hive.box<dynamic>(TourHiveBoxes.metaBox);

  static const String _tourNameKey = 'tour_name';
  static const String _decidedBudgetKey = 'decided_budget';

  final Box<TourMemberModel> _membersBox;
  final Box<TourExpenseModel> _expensesBox;
  final Box<ExtraPaymentModel> _extraPaymentsBox;
  final Box<dynamic> _metaBox;
  final Uuid _uuid = const Uuid();

  String get tourName =>
      (_metaBox.get(_tourNameKey) as String?) ?? '';

  double get decidedBudget =>
      (_metaBox.get(_decidedBudgetKey) as num?)?.toDouble() ?? 0;

  bool get hasActiveTour => _membersBox.isNotEmpty;

  List<TourMemberModel> get members => _membersBox.values.toList();

  List<TourExpenseModel> get expenses =>
      _expensesBox.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<ExtraPaymentModel> get extraPayments =>
      _extraPaymentsBox.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  TourSummary get summary => TourCalculator.calculate(
    members: members,
    expenses: expenses,
    extraPayments: extraPayments,
    totalDecidedBudget: decidedBudget,
  );

  TourMemberModel? memberById(String id) {
    try {
      return _membersBox.values.firstWhere((member) => member.id == id);
    } on StateError {
      return null;
    }
  }

  Future<void> setupTour({
    required String tourName,
    required double decidedBudget,
    required List<String> memberNames,
  }) async {
    await _membersBox.clear();
    await _expensesBox.clear();
    await _extraPaymentsBox.clear();

    for (var i = 0; i < memberNames.length; i++) {
      final member = TourMemberModel(
        id: _uuid.v4(),
        name: memberNames[i],
        avatarColorIndex: i,
        paidToManager: 0,
      );
      await _membersBox.put(member.id, member);
    }

    await _metaBox.put(_tourNameKey, tourName);
    await _metaBox.put(_decidedBudgetKey, decidedBudget);
    notifyListeners();
  }

  Future<void> updateMemberPaidToManager(String memberId, double amount) async {
    final member = memberById(memberId);
    if (member == null) return;
    member.paidToManager = amount;
    await member.save();
    notifyListeners();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String paidByMemberId,
    required List<String> beneficiaryMemberIds,
    required ExpenseCategory category,
    String? note,
  }) async {
    final expense = TourExpenseModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      paidByMemberId: paidByMemberId,
      beneficiaryMemberIds: beneficiaryMemberIds,
      categoryIndex: category.index,
      timestamp: DateTime.now(),
      note: note,
    );
    await _expensesBox.put(expense.id, expense);
    notifyListeners();
  }

  Future<void> addExtraPayment({
    required String memberId,
    required double amount,
    String? note,
  }) async {
    final payment = ExtraPaymentModel(
      id: _uuid.v4(),
      memberId: memberId,
      amount: amount,
      timestamp: DateTime.now(),
      note: note,
    );
    await _extraPaymentsBox.put(payment.id, payment);
    notifyListeners();
  }

  /// Seeds a populated demo tour (members, expenses, extra payments) so the
  /// dashboard/summary screens can be evaluated without manual data entry.
  /// The signed-in [GlobalService] user becomes the first member.
  Future<void> seedDemoData() async {
    final youName = _resolveDisplayName(GlobalService.instance.currentUser);

    await setupTour(
      tourName: "Cox's Bazar Trip",
      decidedBudget: 20000,
      memberNames: [youName, 'Rafiq', 'Tania', 'Imran'],
    );

    final demoMembers = members;
    final you = demoMembers[0];
    final rafiq = demoMembers[1];
    final tania = demoMembers[2];
    final imran = demoMembers[3];

    for (final member in demoMembers) {
      member.paidToManager = 5000;
      await member.save();
    }

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final demoExpenses = [
      TourExpenseModel(
        id: _uuid.v4(),
        title: 'Hotel Booking',
        amount: 8000,
        paidByMemberId: you.id,
        beneficiaryMemberIds: const [],
        categoryIndex: ExpenseCategory.accommodation.index,
        timestamp: yesterday,
        note: 'Sea view room',
      ),
      TourExpenseModel(
        id: _uuid.v4(),
        title: 'Bus Tickets',
        amount: 3200,
        paidByMemberId: rafiq.id,
        beneficiaryMemberIds: const [],
        categoryIndex: ExpenseCategory.transport.index,
        timestamp: yesterday,
      ),
      TourExpenseModel(
        id: _uuid.v4(),
        title: 'Dinner at Seafood Restaurant',
        amount: 2400,
        paidByMemberId: tania.id,
        beneficiaryMemberIds: const [],
        categoryIndex: ExpenseCategory.food.index,
        timestamp: today,
      ),
      TourExpenseModel(
        id: _uuid.v4(),
        title: 'Beach Snacks',
        amount: 650,
        paidByMemberId: imran.id,
        beneficiaryMemberIds: [imran.id, tania.id],
        categoryIndex: ExpenseCategory.snacks.index,
        timestamp: today,
      ),
      TourExpenseModel(
        id: _uuid.v4(),
        title: 'Local SIM Cards',
        amount: 400,
        paidByMemberId: you.id,
        beneficiaryMemberIds: const [],
        categoryIndex: ExpenseCategory.misc.index,
        timestamp: today,
      ),
    ];
    for (final expense in demoExpenses) {
      await _expensesBox.put(expense.id, expense);
    }

    final demoPayments = [
      ExtraPaymentModel(
        id: _uuid.v4(),
        memberId: rafiq.id,
        amount: 1000,
        timestamp: today,
        note: 'Forgot to pay earlier',
      ),
      ExtraPaymentModel(
        id: _uuid.v4(),
        memberId: tania.id,
        amount: 500,
        timestamp: today,
      ),
    ];
    for (final payment in demoPayments) {
      await _extraPaymentsBox.put(payment.id, payment);
    }

    notifyListeners();
  }

  String _resolveDisplayName(AuthUser? user) {
    if (user == null) return 'You';
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = user.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'You';
  }
}
