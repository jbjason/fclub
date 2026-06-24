import 'package:fclub/feature/kurbani/data/kurbani_calculator.dart';
import 'package:fclub/feature/kurbani/data/kurbani_hive_boxes.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_animal_part_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class KurbaniProvider with ChangeNotifier {
  KurbaniProvider()
      : _membersBox =
            Hive.box<KurbaniMemberModel>(KurbaniHiveBoxes.membersBox),
        _expensesBox =
            Hive.box<KurbaniExpenseModel>(KurbaniHiveBoxes.expensesBox),
        _animalPartsBox = Hive.box<KurbaniAnimalPartModel>(
          KurbaniHiveBoxes.animalPartsBox,
        ),
        _metaBox = Hive.box<dynamic>(KurbaniHiveBoxes.metaBox);

  static const _budgetPerMemberKey = 'budget_per_member';
  static const _groupNameKey = 'group_name';

  final Box<KurbaniMemberModel> _membersBox;
  final Box<KurbaniExpenseModel> _expensesBox;
  final Box<KurbaniAnimalPartModel> _animalPartsBox;
  final Box<dynamic> _metaBox;
  final _uuid = const Uuid();

  // ── Getters ────────────────────────────────────────────────

  String get groupName =>
      (_metaBox.get(_groupNameKey) as String?) ?? 'Kurbani 1446 H';

  double get budgetPerMember =>
      (_metaBox.get(_budgetPerMemberKey) as num?)?.toDouble() ?? 3000.0;

  bool get hasDemoData => _membersBox.isNotEmpty;

  List<KurbaniMemberModel> get members => _membersBox.values.toList();

  List<KurbaniExpenseModel> get expenses => _expensesBox.values.toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<KurbaniAnimalPartModel> get animalParts =>
      _animalPartsBox.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  KurbaniSummary get summary => KurbaniCalculator.calculate(
        members: members,
        expenses: expenses,
        budgetPerMember: budgetPerMember,
      );

  double get totalAnimalWeight =>
      animalParts.fold<double>(0, (s, p) => s + p.weightKg);

  // ── Demo seed ──────────────────────────────────────────────

  Future<void> seedDemoData() async {
    if (hasDemoData) return;

    await _metaBox.put(_groupNameKey, 'Kurbani 1446 H');
    await _metaBox.put(_budgetPerMemberKey, 3000.0);

    final demoMembers = [
      KurbaniMemberModel(
          id: 'k1',
          name: 'Ahmed Hassan',
          avatarColorIndex: 0,
          contribution: 3000),
      KurbaniMemberModel(
          id: 'k2',
          name: 'Fatima Ali',
          avatarColorIndex: 1,
          contribution: 3000),
      KurbaniMemberModel(
          id: 'k3',
          name: 'Mohammad Reza',
          avatarColorIndex: 2,
          contribution: 3000),
      KurbaniMemberModel(
          id: 'k4',
          name: 'Aisha Khan',
          avatarColorIndex: 3,
          contribution: 2500),
      KurbaniMemberModel(
          id: 'k5',
          name: 'Ibrahim Siddique',
          avatarColorIndex: 4,
          contribution: 3000),
      KurbaniMemberModel(
          id: 'k6',
          name: 'Mariam Yusuf',
          avatarColorIndex: 5,
          contribution: 3000),
      KurbaniMemberModel(
          id: 'k7',
          name: 'Omar Abdullah',
          avatarColorIndex: 6,
          contribution: 3000),
    ];
    for (final m in demoMembers) {
      await _membersBox.put(m.id, m);
    }

    final now = DateTime.now();
    final demoExpenses = [
      KurbaniExpenseModel(
        id: 'e1',
        title: 'Cow Purchase',
        amount: 18000,
        paidByMemberId: 'k1',
        timestamp: now.subtract(const Duration(days: 2)),
        note: 'Local cattle market',
      ),
      KurbaniExpenseModel(
        id: 'e2',
        title: 'Butcher Fee',
        amount: 2000,
        paidByMemberId: 'k3',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      KurbaniExpenseModel(
        id: 'e3',
        title: 'Transport',
        amount: 500,
        paidByMemberId: 'k4',
        timestamp: now.subtract(const Duration(days: 1)),
        note: 'Pickup truck rental',
      ),
      KurbaniExpenseModel(
        id: 'e4',
        title: 'Salt & Spices',
        amount: 300,
        paidByMemberId: 'k5',
        timestamp: now,
      ),
    ];
    for (final e in demoExpenses) {
      await _expensesBox.put(e.id, e);
    }

    final demoParts = [
      KurbaniAnimalPartModel(
          id: 'p1', partName: 'Meat', weightKg: 85.0, timestamp: now),
      KurbaniAnimalPartModel(
          id: 'p2', partName: 'Bone', weightKg: 35.0, timestamp: now),
      KurbaniAnimalPartModel(
          id: 'p3', partName: 'Liver', weightKg: 6.0, timestamp: now),
      KurbaniAnimalPartModel(
          id: 'p4', partName: 'Ribs', weightKg: 12.0, timestamp: now),
      KurbaniAnimalPartModel(
          id: 'p5', partName: 'Offal', weightKg: 4.0, timestamp: now),
      KurbaniAnimalPartModel(
          id: 'p6', partName: 'Head', weightKg: 8.0, timestamp: now),
      KurbaniAnimalPartModel(
          id: 'p7', partName: 'Feet', weightKg: 4.0, timestamp: now),
    ];
    for (final p in demoParts) {
      await _animalPartsBox.put(p.id, p);
    }

    notifyListeners();
  }

  // ── Members ────────────────────────────────────────────────

  Future<void> addMember(String name) async {
    final id = _uuid.v4();
    final colorIndex = _membersBox.length % _avatarGradientCount;
    final member = KurbaniMemberModel(
      id: id,
      name: name,
      avatarColorIndex: colorIndex,
      contribution: budgetPerMember,
    );
    await _membersBox.put(id, member);
    notifyListeners();
  }

  Future<void> updateContribution(String memberId, double amount) async {
    final member = _membersBox.get(memberId);
    if (member == null) return;
    member.contribution = amount;
    await member.save();
    notifyListeners();
  }

  Future<void> deleteMember(String memberId) async {
    await _membersBox.delete(memberId);
    notifyListeners();
  }

  // ── Expenses ───────────────────────────────────────────────

  Future<void> addExpense({
    required String title,
    required double amount,
    required String paidByMemberId,
    String? note,
  }) async {
    final id = _uuid.v4();
    final expense = KurbaniExpenseModel(
      id: id,
      title: title,
      amount: amount,
      paidByMemberId: paidByMemberId,
      timestamp: DateTime.now(),
      note: note,
    );
    await _expensesBox.put(id, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesBox.delete(expenseId);
    notifyListeners();
  }

  // ── Animal Parts ───────────────────────────────────────────

  Future<void> addAnimalPart({
    required String partName,
    required double weightKg,
    String? note,
  }) async {
    final id = _uuid.v4();
    final part = KurbaniAnimalPartModel(
      id: id,
      partName: partName,
      weightKg: weightKg,
      timestamp: DateTime.now(),
      note: note,
    );
    await _animalPartsBox.put(id, part);
    notifyListeners();
  }

  Future<void> deleteAnimalPart(String partId) async {
    await _animalPartsBox.delete(partId);
    notifyListeners();
  }

  // ── Settings ───────────────────────────────────────────────

  Future<void> updateBudgetPerMember(double amount) async {
    await _metaBox.put(_budgetPerMemberKey, amount);
    notifyListeners();
  }

  Future<void> updateGroupName(String name) async {
    await _metaBox.put(_groupNameKey, name);
    notifyListeners();
  }
}

const int _avatarGradientCount = 7;
