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
  bool get hasDemoData => _sessionsBox.isNotEmpty;

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

  Future<void> deleteSession(String sessionId) async {
    await _sessionsBox.delete(sessionId);
    _history.removeWhere((s) => s.id == sessionId);
    if (_activeSession?.id == sessionId) _activeSession = null;
    notifyListeners();
  }

  // ── Members in active session ──────────────────────────────────────────────

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

  // ── Demo seed ──────────────────────────────────────────────────────────────

  /// Seeds two completed historical sessions, reusing the shared demo
  /// contacts (same ids/names Kurbani's history uses) so both features show
  /// consistent people.
  Future<void> seedDemoData() async {
    if (hasDemoData) return;

    final youName = _globalContacts.meContact?.name ?? 'You';

    final m23 = [
      TourMemberModel(
          id: 'me', name: youName, avatarColorIndex: 0, paidToManager: 4000),
      TourMemberModel(
          id: 'c1', name: 'Ahmed Hassan', avatarColorIndex: 1, paidToManager: 4000),
      TourMemberModel(
          id: 'c2', name: 'Fatima Ali', avatarColorIndex: 2, paidToManager: 4000),
    ];
    final d2023 = DateTime(2023, 10, 6);
    final s2023 = TourSession(
      id: 'hist_2023',
      tourName: "Sundarbans Expedition",
      decidedBudget: 12000,
      createdAt: d2023,
      isCompleted: true,
      members: m23,
      expenses: [
        TourExpenseModel(
            id: 's23_e1',
            title: 'Boat Charter',
            amount: 4500,
            paidByMemberId: 'me',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.transport.index,
            timestamp: d2023),
        TourExpenseModel(
            id: 's23_e2',
            title: 'Forest Lodge',
            amount: 3000,
            paidByMemberId: 'c1',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.accommodation.index,
            timestamp: d2023),
        TourExpenseModel(
            id: 's23_e3',
            title: 'Food & Meals',
            amount: 1700,
            paidByMemberId: 'c2',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.food.index,
            timestamp: d2023),
      ],
      extraPayments: [],
    );

    final m24 = [
      TourMemberModel(
          id: 'me', name: youName, avatarColorIndex: 0, paidToManager: 5000),
      TourMemberModel(
          id: 'c1', name: 'Ahmed Hassan', avatarColorIndex: 1, paidToManager: 5000),
      TourMemberModel(
          id: 'c2', name: 'Fatima Ali', avatarColorIndex: 2, paidToManager: 5000),
      TourMemberModel(
          id: 'c3', name: 'Mohammad Reza', avatarColorIndex: 3, paidToManager: 5000),
    ];
    final d2024 = DateTime(2024, 6, 14);
    final s2024 = TourSession(
      id: 'hist_2024',
      tourName: "Cox's Bazar Trip",
      decidedBudget: 20000,
      createdAt: d2024,
      isCompleted: true,
      members: m24,
      expenses: [
        TourExpenseModel(
            id: 's24_e1',
            title: 'Hotel Booking',
            amount: 8000,
            paidByMemberId: 'me',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.accommodation.index,
            timestamp: d2024,
            note: 'Sea view room'),
        TourExpenseModel(
            id: 's24_e2',
            title: 'Bus Tickets',
            amount: 3200,
            paidByMemberId: 'c1',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.transport.index,
            timestamp: d2024),
        TourExpenseModel(
            id: 's24_e3',
            title: 'Seafood Dinner',
            amount: 2400,
            paidByMemberId: 'c2',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.food.index,
            timestamp: d2024),
        TourExpenseModel(
            id: 's24_e4',
            title: 'Beach Snacks',
            amount: 650,
            paidByMemberId: 'c3',
            beneficiaryMemberIds: ['c3', 'c2'],
            categoryIndex: ExpenseCategory.snacks.index,
            timestamp: d2024),
        TourExpenseModel(
            id: 's24_e5',
            title: 'SIM Cards',
            amount: 400,
            paidByMemberId: 'me',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.misc.index,
            timestamp: d2024),
      ],
      extraPayments: [
        ExtraPaymentModel(
            id: 's24_p1',
            memberId: 'c1',
            amount: 1000,
            timestamp: d2024,
            note: 'Forgot to pay earlier'),
        ExtraPaymentModel(
            id: 's24_p2',
            memberId: 'c2',
            amount: 500,
            timestamp: d2024),
      ],
    );

    await _sessionsBox.put(s2023.id, s2023);
    await _sessionsBox.put(s2024.id, s2024);
    _load();
  }
}
