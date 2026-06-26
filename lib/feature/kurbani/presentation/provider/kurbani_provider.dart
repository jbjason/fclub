import 'package:fclub/feature/kurbani/data/kurbani_calculator.dart';
import 'package:fclub/feature/kurbani/data/kurbani_hive_boxes.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_animal_part_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_global_contact.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_session.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class KurbaniProvider with ChangeNotifier {
  KurbaniProvider()
      : _sessionsBox =
            Hive.box<KurbaniSession>(KurbaniHiveBoxes.sessionsBox),
        _contactsBox =
            Hive.box<KurbaniGlobalContact>(KurbaniHiveBoxes.contactsBox) {
    _load();
  }

  final Box<KurbaniSession> _sessionsBox;
  final Box<KurbaniGlobalContact> _contactsBox;
  final _uuid = const Uuid();

  KurbaniSession? _activeSession;
  List<KurbaniSession> _history = [];

  // ── Init ──────────────────────────────────────────────────────────────────

  void _load() {
    final all = _sessionsBox.values.toList();
    final active = all.where((s) => !s.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _activeSession = active.isNotEmpty ? active.first : null;
    _history = all.where((s) => s.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // ── Public getters ─────────────────────────────────────────────────────────

  bool get hasActiveSession => _activeSession != null;
  KurbaniSession? get activeSession => _activeSession;
  List<KurbaniSession> get history => List.unmodifiable(_history);
  List<KurbaniGlobalContact> get contacts => _contactsBox.values.toList();
  KurbaniGlobalContact? get meContact =>
      _contactsBox.values.where((c) => c.isMe).firstOrNull;
  bool get hasDemoData =>
      _sessionsBox.isNotEmpty || _contactsBox.isNotEmpty;

  // ── Delegated getters for active session ──────────────────────────────────

  String get groupName => _activeSession?.groupName ?? '';
  double get budgetPerMember => _activeSession?.budgetPerMember ?? 3000.0;

  List<KurbaniMemberModel> get members =>
      List<KurbaniMemberModel>.from(_activeSession?.members ?? []);

  List<KurbaniExpenseModel> get expenses {
    final list =
        List<KurbaniExpenseModel>.from(_activeSession?.expenses ?? []);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<KurbaniAnimalPartModel> get animalParts {
    final list =
        List<KurbaniAnimalPartModel>.from(_activeSession?.animalParts ?? []);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  KurbaniSummary get summary => KurbaniCalculator.calculate(
        members: members,
        expenses: expenses,
        budgetPerMember: budgetPerMember,
      );

  double get totalAnimalWeight =>
      animalParts.fold<double>(0, (s, p) => s + p.weightKg);

  // ── Demo seed ──────────────────────────────────────────────────────────────

  Future<void> seedDemoData() async {
    if (hasDemoData) return;
    await _seedContacts();
    await _seedHistorySessions();
    _load();
  }

  Future<void> _seedContacts() async {
    final list = [
      KurbaniGlobalContact(
          id: 'me', name: 'You', avatarColorIndex: 0, isMe: true),
      KurbaniGlobalContact(
          id: 'c1', name: 'Ahmed Hassan', avatarColorIndex: 1),
      KurbaniGlobalContact(id: 'c2', name: 'Fatima Ali', avatarColorIndex: 2),
      KurbaniGlobalContact(
          id: 'c3', name: 'Mohammad Reza', avatarColorIndex: 3),
      KurbaniGlobalContact(id: 'c4', name: 'Aisha Khan', avatarColorIndex: 4),
      KurbaniGlobalContact(
          id: 'c5', name: 'Ibrahim Siddique', avatarColorIndex: 5),
      KurbaniGlobalContact(
          id: 'c6', name: 'Mariam Yusuf', avatarColorIndex: 6),
      KurbaniGlobalContact(
          id: 'c7', name: 'Omar Abdullah', avatarColorIndex: 0),
      KurbaniGlobalContact(
          id: 'c8', name: 'Sara Rahman', avatarColorIndex: 1),
      KurbaniGlobalContact(
          id: 'c9', name: 'Yusuf Malik', avatarColorIndex: 2),
      KurbaniGlobalContact(
          id: 'c10', name: 'Khadija Hossain', avatarColorIndex: 3),
      KurbaniGlobalContact(id: 'c11', name: 'Ali Karim', avatarColorIndex: 4),
    ];
    for (final c in list) {
      await _contactsBox.put(c.id, c);
    }
  }

  Future<void> _seedHistorySessions() async {
    final s2023 = KurbaniSession(
      id: 'hist_2023',
      groupName: 'Kurbani 1444 H',
      budgetPerMember: 2500,
      createdAt: DateTime(2023, 6, 28),
      isCompleted: true,
      members: [
        KurbaniMemberModel(
            id: 'me', name: 'You', avatarColorIndex: 0, contribution: 2500),
        KurbaniMemberModel(
            id: 'c1',
            name: 'Ahmed Hassan',
            avatarColorIndex: 1,
            contribution: 2500),
        KurbaniMemberModel(
            id: 'c2',
            name: 'Fatima Ali',
            avatarColorIndex: 2,
            contribution: 2500),
        KurbaniMemberModel(
            id: 'c3',
            name: 'Mohammad Reza',
            avatarColorIndex: 3,
            contribution: 2500),
        KurbaniMemberModel(
            id: 'c4',
            name: 'Aisha Khan',
            avatarColorIndex: 4,
            contribution: 2000),
        KurbaniMemberModel(
            id: 'c5',
            name: 'Ibrahim Siddique',
            avatarColorIndex: 5,
            contribution: 2500),
      ],
      expenses: [
        KurbaniExpenseModel(
            id: 'h23_e1',
            title: 'Cow Purchase',
            amount: 13000,
            paidByMemberId: 'me',
            timestamp: DateTime(2023, 6, 28),
            note: 'Local cattle market'),
        KurbaniExpenseModel(
            id: 'h23_e2',
            title: 'Butcher Fee',
            amount: 1200,
            paidByMemberId: 'c1',
            timestamp: DateTime(2023, 6, 28)),
        KurbaniExpenseModel(
            id: 'h23_e3',
            title: 'Transport',
            amount: 400,
            paidByMemberId: 'c3',
            timestamp: DateTime(2023, 6, 28)),
      ],
      animalParts: [
        KurbaniAnimalPartModel(
            id: 'h23_p1',
            partName: 'Meat',
            weightKg: 72.0,
            timestamp: DateTime(2023, 6, 28)),
        KurbaniAnimalPartModel(
            id: 'h23_p2',
            partName: 'Bone',
            weightKg: 28.0,
            timestamp: DateTime(2023, 6, 28)),
        KurbaniAnimalPartModel(
            id: 'h23_p3',
            partName: 'Liver',
            weightKg: 5.0,
            timestamp: DateTime(2023, 6, 28)),
      ],
    );

    final s2024 = KurbaniSession(
      id: 'hist_2024',
      groupName: 'Kurbani 1445 H',
      budgetPerMember: 3000,
      createdAt: DateTime(2024, 6, 17),
      isCompleted: true,
      members: [
        KurbaniMemberModel(
            id: 'me', name: 'You', avatarColorIndex: 0, contribution: 3000),
        KurbaniMemberModel(
            id: 'c1',
            name: 'Ahmed Hassan',
            avatarColorIndex: 1,
            contribution: 3000),
        KurbaniMemberModel(
            id: 'c2',
            name: 'Fatima Ali',
            avatarColorIndex: 2,
            contribution: 3000),
        KurbaniMemberModel(
            id: 'c3',
            name: 'Mohammad Reza',
            avatarColorIndex: 3,
            contribution: 3000),
        KurbaniMemberModel(
            id: 'c4',
            name: 'Aisha Khan',
            avatarColorIndex: 4,
            contribution: 2500),
        KurbaniMemberModel(
            id: 'c5',
            name: 'Ibrahim Siddique',
            avatarColorIndex: 5,
            contribution: 3000),
        KurbaniMemberModel(
            id: 'c6',
            name: 'Mariam Yusuf',
            avatarColorIndex: 6,
            contribution: 3000),
        KurbaniMemberModel(
            id: 'c7',
            name: 'Omar Abdullah',
            avatarColorIndex: 0,
            contribution: 3000),
      ],
      expenses: [
        KurbaniExpenseModel(
            id: 'h24_e1',
            title: 'Cow Purchase',
            amount: 20000,
            paidByMemberId: 'me',
            timestamp: DateTime(2024, 6, 17),
            note: 'Local cattle market'),
        KurbaniExpenseModel(
            id: 'h24_e2',
            title: 'Butcher Fee',
            amount: 2000,
            paidByMemberId: 'c1',
            timestamp: DateTime(2024, 6, 17)),
        KurbaniExpenseModel(
            id: 'h24_e3',
            title: 'Transport',
            amount: 500,
            paidByMemberId: 'c3',
            timestamp: DateTime(2024, 6, 17)),
        KurbaniExpenseModel(
            id: 'h24_e4',
            title: 'Salt & Spices',
            amount: 350,
            paidByMemberId: 'c5',
            timestamp: DateTime(2024, 6, 17)),
      ],
      animalParts: [
        KurbaniAnimalPartModel(
            id: 'h24_p1',
            partName: 'Meat',
            weightKg: 90.0,
            timestamp: DateTime(2024, 6, 17)),
        KurbaniAnimalPartModel(
            id: 'h24_p2',
            partName: 'Bone',
            weightKg: 38.0,
            timestamp: DateTime(2024, 6, 17)),
        KurbaniAnimalPartModel(
            id: 'h24_p3',
            partName: 'Liver',
            weightKg: 6.5,
            timestamp: DateTime(2024, 6, 17)),
        KurbaniAnimalPartModel(
            id: 'h24_p4',
            partName: 'Ribs',
            weightKg: 14.0,
            timestamp: DateTime(2024, 6, 17)),
      ],
    );

    await _sessionsBox.put(s2023.id, s2023);
    await _sessionsBox.put(s2024.id, s2024);
  }

  // ── Session lifecycle ──────────────────────────────────────────────────────

  Future<void> createSession({
    required String groupName,
    required double budgetPerMember,
    required List<String> selectedContactIds,
  }) async {
    final meId = meContact?.id;
    final ids = [
      if (meId != null && !selectedContactIds.contains(meId)) meId,
      ...selectedContactIds,
    ];

    final members = ids.map((id) {
      final contact = _contactsBox.get(id);
      if (contact == null) return null;
      return KurbaniMemberModel(
        id: contact.id,
        name: contact.isMe ? 'You (${contact.name})' : contact.name,
        avatarColorIndex: contact.avatarColorIndex,
        contribution: budgetPerMember,
      );
    }).whereType<KurbaniMemberModel>().toList();

    final session = KurbaniSession(
      id: _uuid.v4(),
      groupName: groupName,
      budgetPerMember: budgetPerMember,
      createdAt: DateTime.now(),
      members: members,
      expenses: [],
      animalParts: [],
    );
    await _sessionsBox.put(session.id, session);
    _activeSession = session;
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionsBox.delete(sessionId);
    _history.removeWhere((s) => s.id == sessionId);
    if (_activeSession?.id == sessionId) _activeSession = null;
    notifyListeners();
  }

  // ── Members in active session ──────────────────────────────────────────────

  Future<void> addMember(String name) async {
    final session = _activeSession;
    if (session == null) return;
    final colorIndex = session.members.length % _avatarGradientCount;
    session.members.add(KurbaniMemberModel(
      id: _uuid.v4(),
      name: name,
      avatarColorIndex: colorIndex,
      contribution: session.budgetPerMember,
    ));
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  Future<void> updateContribution(String memberId, double amount) async {
    final session = _activeSession;
    if (session == null) return;
    final idx = session.members.indexWhere((m) => m.id == memberId);
    if (idx == -1) return;
    session.members[idx].contribution = amount;
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  Future<void> deleteMember(String memberId) async {
    final session = _activeSession;
    if (session == null) return;
    session.members.removeWhere((m) => m.id == memberId);
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  // ── Expenses ───────────────────────────────────────────────────────────────

  Future<void> addExpense({
    required String title,
    required double amount,
    required String paidByMemberId,
    String? note,
  }) async {
    final session = _activeSession;
    if (session == null) return;
    session.expenses.add(KurbaniExpenseModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      paidByMemberId: paidByMemberId,
      timestamp: DateTime.now(),
      note: note,
    ));
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  Future<void> deleteExpense(String expenseId) async {
    final session = _activeSession;
    if (session == null) return;
    session.expenses.removeWhere((e) => e.id == expenseId);
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  // ── Animal parts ───────────────────────────────────────────────────────────

  Future<void> addAnimalPart({
    required String partName,
    required double weightKg,
    String? note,
  }) async {
    final session = _activeSession;
    if (session == null) return;
    session.animalParts.add(KurbaniAnimalPartModel(
      id: _uuid.v4(),
      partName: partName,
      weightKg: weightKg,
      timestamp: DateTime.now(),
      note: note,
    ));
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  Future<void> deleteAnimalPart(String partId) async {
    final session = _activeSession;
    if (session == null) return;
    session.animalParts.removeWhere((p) => p.id == partId);
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  // ── Settings on active session ─────────────────────────────────────────────

  Future<void> updateBudgetPerMember(double amount) async {
    final session = _activeSession;
    if (session == null) return;
    session.budgetPerMember = amount;
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  Future<void> updateGroupName(String name) async {
    final session = _activeSession;
    if (session == null) return;
    session.groupName = name;
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }
}

const int _avatarGradientCount = 7;
