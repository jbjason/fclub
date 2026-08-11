import 'dart:async';

import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_extra_payment.dart';
import 'package:fclub/feature/tour/data/models/tour_failure.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/data/models/tour_summary.dart';
import 'package:fclub/feature/tour/data/repositories/tour_repository.dart';
import 'package:fclub/feature/tour/data/services/tour_calculator.dart';
import 'package:flutter/foundation.dart';

class TourEventProvider with ChangeNotifier {
  TourEventProvider({
    required TourRepository repository,
    required GroupSessionProvider groupSession,
    required FirebaseAuthService authService,
    required TourEvent event,
  }) : _repository = repository,
       _groupSession = groupSession,
       _authService = authService,
       _event = event;

  final TourRepository _repository;
  final GroupSessionProvider _groupSession;
  final FirebaseAuthService _authService;
  TourEvent _event;

  StreamSubscription<TourEvent?>? _eventSubscription;
  StreamSubscription<List<TourParticipant>>? _participantSubscription;
  StreamSubscription<List<TourExpense>>? _expenseSubscription;
  StreamSubscription<List<TourExtraPayment>>? _paymentSubscription;
  List<TourParticipant> _participants = const [];
  List<TourParticipantCandidate> _availableParticipants = const [];
  List<TourExpense> _expenses = const [];
  List<TourExtraPayment> _extraPayments = const [];
  String? _projectAdminId;
  String? _groupAdminId;
  String? _loadError;
  String? _actionError;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingParticipants = false;
  bool _hasEventSnapshot = false;
  bool _hasParticipantSnapshot = false;
  bool _hasExpenseSnapshot = false;
  bool _hasPaymentSnapshot = false;

  TourEvent get event => _event;
  String get tourName => _event.tourName;
  double get decidedBudget => _event.decidedBudget;
  List<TourParticipant> get participants => List.unmodifiable(_participants);
  List<TourParticipant> get members => participants;
  List<TourParticipantCandidate> get availableParticipants =>
      List.unmodifiable(_availableParticipants);
  List<TourExpense> get expenses => List.unmodifiable(_expenses);
  List<TourExtraPayment> get extraPayments => List.unmodifiable(_extraPayments);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingParticipants => _isLoadingParticipants;
  String? get loadError => _loadError;
  String? get actionError => _actionError;
  String? get currentUserId => _authService.currentUser?.uid;
  bool get isAdmin =>
      currentUserId == _projectAdminId || currentUserId == _groupAdminId;
  bool get canEdit => isAdmin && _event.isOpen;
  bool get canAccess =>
      isAdmin || _participants.any((item) => item.id == currentUserId);
  TourSummary get summary => TourCalculator.calculate(
    participants: _participants,
    expenses: _expenses,
    extraPayments: _extraPayments,
    totalDecidedBudget: _event.decidedBudget,
  );

  TourParticipant? memberById(String id) {
    for (final member in _participants) {
      if (member.id == id) return member;
    }
    return null;
  }

  Future<void> initialize() async {
    late final String groupId;
    try {
      groupId = _requireGroupId();
    } catch (error) {
      _setLoadError(_message(error));
      return;
    }
    await _cancelSubscriptions();
    _participants = const [];
    _expenses = const [];
    _extraPayments = const [];
    _loadError = null;
    _actionError = null;
    _isLoading = true;
    _hasEventSnapshot = false;
    _hasParticipantSnapshot = false;
    _hasExpenseSnapshot = false;
    _hasPaymentSnapshot = false;
    notifyListeners();

    try {
      _groupAdminId = await _repository.getGroupAdminId(groupId: groupId);
      _projectAdminId = (await _repository.findProject(
        groupId: groupId,
      ))?.adminId;
    } catch (error) {
      _setLoadError(_message(error));
      return;
    }

    _eventSubscription = _repository
        .watchEvent(groupId: groupId, eventId: _event.id)
        .listen((event) {
          if (event == null) {
            _setLoadError('tour_error_event_missing');
            return;
          }
          _event = event;
          _hasEventSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);
    _participantSubscription = _repository
        .watchParticipants(groupId: groupId, eventId: _event.id)
        .listen((items) {
          _participants = items;
          _hasParticipantSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);
    _expenseSubscription = _repository
        .watchExpenses(groupId: groupId, eventId: _event.id)
        .listen((items) {
          _expenses = items;
          _hasExpenseSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);
    _paymentSubscription = _repository
        .watchExtraPayments(groupId: groupId, eventId: _event.id)
        .listen((items) {
          _extraPayments = items;
          _hasPaymentSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);
  }

  Future<void> loadAvailableParticipants() async {
    _requireEditable();
    _isLoadingParticipants = true;
    _actionError = null;
    notifyListeners();
    try {
      _availableParticipants = await _repository.getAvailableParticipants(
        groupId: _requireGroupId(),
        eventId: _event.id,
      );
    } catch (error) {
      _actionError = _message(error);
    } finally {
      _isLoadingParticipants = false;
      notifyListeners();
    }
  }

  Future<void> addParticipant(String userId) async {
    _requireEditable();
    await _runAction(
      () => _repository.addParticipant(
        groupId: _requireGroupId(),
        eventId: _event.id,
        userId: userId,
      ),
    );
    await loadAvailableParticipants();
  }

  Future<void> removeParticipant(String userId) async {
    _requireEditable();
    if (_participants.length <= 1) {
      throw const TourFailure('tour_error_last_member');
    }
    await _runAction(
      () => _repository.removeParticipant(
        groupId: _requireGroupId(),
        eventId: _event.id,
        userId: userId,
      ),
    );
    await loadAvailableParticipants();
  }

  Future<void> updateBudget(double amount) async {
    _requireEditable();
    if (amount <= 0) throw const TourFailure('tour_error_budget');
    await _runAction(
      () => _repository.updateEventBudget(
        groupId: _requireGroupId(),
        eventId: _event.id,
        decidedBudget: amount,
      ),
    );
  }

  Future<void> updateParticipantPayment(String userId, double amount) async {
    _requireEditable();
    if (amount < 0) throw const TourFailure('tour_error_payment');
    await _runAction(
      () => _repository.updateParticipantPayment(
        groupId: _requireGroupId(),
        eventId: _event.id,
        userId: userId,
        paidToManager: amount,
      ),
    );
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String? paidByMemberId,
    required List<String> beneficiaryMemberIds,
    required TourExpenseCategory category,
    bool paidByAllMembers = false,
    String? note,
  }) async {
    _requireEditable();
    if (title.trim().isEmpty || amount <= 0) {
      throw const TourFailure('tour_error_expense_fields');
    }
    if (_participants.isEmpty ||
        (!paidByAllMembers &&
            !_participants.any((item) => item.id == paidByMemberId))) {
      throw const TourFailure('tour_error_choose_payer');
    }
    final beneficiaries = beneficiaryMemberIds.isEmpty
        ? _participants.map((member) => member.id).toList(growable: false)
        : beneficiaryMemberIds;
    await _runAction(
      () => _repository.createExpense(
        groupId: _requireGroupId(),
        eventId: _event.id,
        title: title,
        amount: amount,
        category: category,
        paidByMemberId: paidByMemberId,
        paidByAllMembers: paidByAllMembers,
        beneficiaryMemberIds: beneficiaries,
        createdBy: _requireUserId(),
        note: note,
      ),
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    _requireEditable();
    await _runAction(
      () => _repository.deleteExpense(
        groupId: _requireGroupId(),
        eventId: _event.id,
        expenseId: expenseId,
      ),
    );
  }

  Future<void> addExtraPayment({
    required String memberId,
    required double amount,
    String? note,
  }) async {
    _requireEditable();
    if (amount <= 0 || !_participants.any((item) => item.id == memberId)) {
      throw const TourFailure('tour_error_payment');
    }
    await _runAction(
      () => _repository.createExtraPayment(
        groupId: _requireGroupId(),
        eventId: _event.id,
        memberId: memberId,
        amount: amount,
        createdBy: _requireUserId(),
        note: note,
      ),
    );
  }

  Future<void> deleteExtraPayment(String paymentId) async {
    _requireEditable();
    await _runAction(
      () => _repository.deleteExtraPayment(
        groupId: _requireGroupId(),
        eventId: _event.id,
        paymentId: paymentId,
      ),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    _isSubmitting = true;
    _actionError = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _actionError = _message(error);
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _completeInitialLoad() {
    if (_hasEventSnapshot &&
        _hasParticipantSnapshot &&
        _hasExpenseSnapshot &&
        _hasPaymentSnapshot) {
      _isLoading = false;
    }
    notifyListeners();
  }

  void _handleLoadError(Object error) => _setLoadError(_message(error));

  void _setLoadError(String key) {
    _loadError = key;
    _isLoading = false;
    notifyListeners();
  }

  String _requireGroupId() {
    final value = _groupSession.groupId;
    if (value == null || value.isEmpty) {
      throw const TourFailure('tour_error_choose_group');
    }
    return value;
  }

  String _requireUserId() {
    final value = currentUserId;
    if (value == null || value.isEmpty) {
      throw const TourFailure('tour_error_signed_out');
    }
    return value;
  }

  void _requireEditable() {
    if (!isAdmin) throw const TourFailure('tour_error_admin_only');
    if (!_event.isOpen) {
      throw const TourFailure('tour_error_completed_read_only');
    }
  }

  String _message(Object error) =>
      error is TourFailure ? error.messageKey : 'tour_error_unknown';

  Future<void> _cancelSubscriptions() async {
    await _eventSubscription?.cancel();
    await _participantSubscription?.cancel();
    await _expenseSubscription?.cancel();
    await _paymentSubscription?.cancel();
    _eventSubscription = null;
    _participantSubscription = null;
    _expenseSubscription = null;
    _paymentSubscription = null;
  }

  @override
  void dispose() {
    unawaited(_cancelSubscriptions());
    super.dispose();
  }
}
