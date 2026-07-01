import 'package:fclub/core/services/contacts/app_contact.dart';
import 'package:fclub/core/services/contacts/global_contacts_provider.dart';
import 'package:fclub/feature/tour/data/expense_category.dart';
import 'package:fclub/feature/tour/data/hive_boxes.dart';
import 'package:fclub/feature/tour/data/model/extra_payment_model.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/data/model/tour_session.dart';
import 'package:fclub/feature/tour/data/model/tour_summary.dart';
import 'package:fclub/feature/tour/data/tour_calculator.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class TourProvider with ChangeNotifier {
  TourProvider(this._globalContacts)
      : _sessionsBox = Hive.box<TourSession>(TourHiveBoxes.sessionsBox) {
    _load();
  }

  final Box<TourSession> _sessionsBox;
  final GlobalContactsProvider _globalContacts;
  final Uuid _uuid = const Uuid();

  TourSession? _activeSession;
  List<TourSession> _history = [];

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
  TourSession? get activeSession => _activeSession;
  List<TourSession> get history => List.unmodifiable(_history);

  // ── Delegated getters for active session ──────────────────────────────────

  String get tourName => _activeSession?.tourName ?? '';
  double get decidedBudget => _activeSession?.decidedBudget ?? 0;

  /// True when any session data exists (active or history).
  bool get hasActiveTour => hasActiveSession;

  List<TourMemberModel> get members =>
      List<TourMemberModel>.from(_activeSession?.members ?? []);

  List<TourExpenseModel> get expenses {
    final list = List<TourExpenseModel>.from(_activeSession?.expenses ?? []);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  List<ExtraPaymentModel> get extraPayments {
    final list =
        List<ExtraPaymentModel>.from(_activeSession?.extraPayments ?? []);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  TourSummary get summary => TourCalculator.calculate(
        members: members,
        expenses: expenses,
        extraPayments: extraPayments,
        totalDecidedBudget: decidedBudget,
      );

  TourMemberModel? memberById(String id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } on StateError {
      return null;
    }
  }

  // ── Session lifecycle ──────────────────────────────────────────────────────

  Future<void> createSession({
    required String tourName,
    required double decidedBudget,
    required List<String> selectedContactIds,
  }) async {
    final meId = _globalContacts.meContact?.id;
    final ids = [
      if (meId != null && !selectedContactIds.contains(meId)) meId,
      ...selectedContactIds,
    ];

    final contacts = ids
        .map((id) => _globalContacts.contactById(id))
        .whereType<AppContact>()
        .toList();

    final memberShare =
        contacts.isEmpty ? 0.0 : decidedBudget / contacts.length;

    final sessionMembers = contacts.map((contact) {
      return TourMemberModel(
        id: contact.id,
        name: contact.isMe ? 'You (${contact.name})' : contact.name,
        avatarColorIndex: contact.avatarColorIndex,
        paidToManager: memberShare,
      );
    }).toList();

    final session = TourSession(
      id: _uuid.v4(),
      tourName: tourName,
      decidedBudget: decidedBudget,
      createdAt: DateTime.now(),
      members: sessionMembers,
      expenses: [],
      extraPayments: [],
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

  Future<void> addMemberFromContact(String contactId) async {
    final session = _activeSession;
    if (session == null) return;
    if (session.members.any((m) => m.id == contactId)) return;
    final contact = _globalContacts.contactById(contactId);
    if (contact == null) return;
    final colorIndex = session.members.length % 8;
    session.members.add(TourMemberModel(
      id: contact.id,
      name: contact.isMe ? 'You (${contact.name})' : contact.name,
      avatarColorIndex: colorIndex,
      paidToManager: 0.0,
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

  Future<void> updateDecidedBudget(double amount) async {
    final session = _activeSession;
    if (session == null) return;
    session.decidedBudget = amount;
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  Future<void> updateMemberPaidToManager(
      String memberId, double amount) async {
    final session = _activeSession;
    if (session == null) return;
    final idx = session.members.indexWhere((m) => m.id == memberId);
    if (idx == -1) return;
    session.members[idx].paidToManager = amount;
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  // ── Expenses ───────────────────────────────────────────────────────────────

  Future<void> addExpense({
    required String title,
    required double amount,
    required String paidByMemberId,
    required List<String> beneficiaryMemberIds,
    required ExpenseCategory category,
    String? note,
  }) async {
    final session = _activeSession;
    if (session == null) return;
    session.expenses.add(TourExpenseModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      paidByMemberId: paidByMemberId,
      beneficiaryMemberIds: beneficiaryMemberIds,
      categoryIndex: category.index,
      timestamp: DateTime.now(),
      note: note,
    ));
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

  // ── Extra payments ─────────────────────────────────────────────────────────

  Future<void> addExtraPayment({
    required String memberId,
    required double amount,
    String? note,
  }) async {
    final session = _activeSession;
    if (session == null) return;
    session.extraPayments.add(ExtraPaymentModel(
      id: _uuid.v4(),
      memberId: memberId,
      amount: amount,
      timestamp: DateTime.now(),
      note: note,
    ));
    await _sessionsBox.put(session.id, session);
    notifyListeners();
  }

}
