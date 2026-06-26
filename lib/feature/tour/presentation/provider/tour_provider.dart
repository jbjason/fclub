import 'package:fclub/core/services/global_service.dart';
import 'package:fclub/feature/auth/data/model/auth_user.dart';
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
  TourProvider()
      : _sessionsBox = Hive.box<TourSession>(TourHiveBoxes.sessionsBox) {
    _load();
  }

  final Box<TourSession> _sessionsBox;
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
    final list =
        List<TourExpenseModel>.from(_activeSession?.expenses ?? []);
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
    required List<String> memberNames,
  }) async {
    final sessionMembers = memberNames.asMap().entries.map((entry) {
      return TourMemberModel(
        id: _uuid.v4(),
        name: entry.value,
        avatarColorIndex: entry.key,
        paidToManager: 0,
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

  // ── Legacy compat — kept for TourSetupScreen ──────────────────────────────

  Future<void> setupTour({
    required String tourName,
    required double decidedBudget,
    required List<String> memberNames,
  }) => createSession(
        tourName: tourName,
        decidedBudget: decidedBudget,
        memberNames: memberNames,
      );

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

  Future<void> seedDemoData() async {
    if (hasDemoData) return;

    final youName =
        _resolveDisplayName(GlobalService.instance.currentUser);

    // ── 2023 session ──────────────────────────────────────────────────────────
    final m23 = [
      TourMemberModel(
          id: 'me23', name: youName, avatarColorIndex: 0, paidToManager: 4000),
      TourMemberModel(
          id: 'rafiq23', name: 'Rafiq', avatarColorIndex: 1, paidToManager: 4000),
      TourMemberModel(
          id: 'tania23', name: 'Tania', avatarColorIndex: 2, paidToManager: 4000),
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
            paidByMemberId: 'me23',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.transport.index,
            timestamp: d2023),
        TourExpenseModel(
            id: 's23_e2',
            title: 'Forest Lodge',
            amount: 3000,
            paidByMemberId: 'rafiq23',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.accommodation.index,
            timestamp: d2023),
        TourExpenseModel(
            id: 's23_e3',
            title: 'Food & Meals',
            amount: 1700,
            paidByMemberId: 'tania23',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.food.index,
            timestamp: d2023),
      ],
      extraPayments: [],
    );

    // ── 2024 session ──────────────────────────────────────────────────────────
    final m24 = [
      TourMemberModel(
          id: 'me24', name: youName, avatarColorIndex: 0, paidToManager: 5000),
      TourMemberModel(
          id: 'rafiq24', name: 'Rafiq', avatarColorIndex: 1, paidToManager: 5000),
      TourMemberModel(
          id: 'tania24', name: 'Tania', avatarColorIndex: 2, paidToManager: 5000),
      TourMemberModel(
          id: 'imran24', name: 'Imran', avatarColorIndex: 3, paidToManager: 5000),
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
            paidByMemberId: 'me24',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.accommodation.index,
            timestamp: d2024,
            note: 'Sea view room'),
        TourExpenseModel(
            id: 's24_e2',
            title: 'Bus Tickets',
            amount: 3200,
            paidByMemberId: 'rafiq24',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.transport.index,
            timestamp: d2024),
        TourExpenseModel(
            id: 's24_e3',
            title: 'Seafood Dinner',
            amount: 2400,
            paidByMemberId: 'tania24',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.food.index,
            timestamp: d2024),
        TourExpenseModel(
            id: 's24_e4',
            title: 'Beach Snacks',
            amount: 650,
            paidByMemberId: 'imran24',
            beneficiaryMemberIds: ['imran24', 'tania24'],
            categoryIndex: ExpenseCategory.snacks.index,
            timestamp: d2024),
        TourExpenseModel(
            id: 's24_e5',
            title: 'SIM Cards',
            amount: 400,
            paidByMemberId: 'me24',
            beneficiaryMemberIds: const [],
            categoryIndex: ExpenseCategory.misc.index,
            timestamp: d2024),
      ],
      extraPayments: [
        ExtraPaymentModel(
            id: 's24_p1',
            memberId: 'rafiq24',
            amount: 1000,
            timestamp: d2024,
            note: 'Forgot to pay earlier'),
        ExtraPaymentModel(
            id: 's24_p2',
            memberId: 'tania24',
            amount: 500,
            timestamp: d2024),
      ],
    );

    await _sessionsBox.put(s2023.id, s2023);
    await _sessionsBox.put(s2024.id, s2024);
    _load();
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
