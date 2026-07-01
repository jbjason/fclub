import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/kurbani/data/kurbani_calculator.dart';
import 'package:fclub/feature/kurbani/data/kurbani_hive_boxes.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_animal_part_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_session.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class KurbaniProvider with ChangeNotifier {
  KurbaniProvider(this._globalContacts)
      : _sessionsBox = Hive.box<KurbaniSession>(KurbaniHiveBoxes.sessionsBox) {
    _load();
  }

  final Box<KurbaniSession> _sessionsBox;
  final GlobalContactsProvider _globalContacts;
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

  // ── Session lifecycle ──────────────────────────────────────────────────────

  Future<void> createSession({
    required String groupName,
    required double budgetPerMember,
    required List<String> selectedContactIds,
  }) async {
    final meId = _globalContacts.meContact?.id;
    final ids = [
      if (meId != null && !selectedContactIds.contains(meId)) meId,
      ...selectedContactIds,
    ];

    final members = ids.map((id) {
      final contact = _globalContacts.contactById(id);
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

  Future<void> finishSession() async {
    final session = _activeSession;
    if (session == null) return;
    session.isCompleted = true;
    await _sessionsBox.put(session.id, session);
    _load();
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

  Future<void> addMemberFromContact(String contactId) async {
    final session = _activeSession;
    if (session == null) return;
    if (session.members.any((m) => m.id == contactId)) return;
    final contact = _globalContacts.contactById(contactId);
    if (contact == null) return;
    final colorIndex = session.members.length % _avatarGradientCount;
    session.members.add(KurbaniMemberModel(
      id: contact.id,
      name: contact.isMe ? 'You (${contact.name})' : contact.name,
      avatarColorIndex: colorIndex,
      contribution: session.budgetPerMember,
    ));
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
