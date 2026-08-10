import 'dart:async';

import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_animal_part.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_event.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_expense.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_failure.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_summary.dart';
import 'package:fclub/feature/kurbani/data/repositories/kurbani_repository.dart';
import 'package:fclub/feature/kurbani/data/services/kurbani_calculator.dart';
import 'package:flutter/foundation.dart';

class KurbaniEventProvider with ChangeNotifier {
  KurbaniEventProvider({
    required KurbaniRepository repository,
    required GroupSessionProvider groupSession,
    required FirebaseAuthService authService,
    required KurbaniEvent event,
  }) : _repository = repository,
       _groupSession = groupSession,
       _authService = authService,
       _event = event;

  final KurbaniRepository _repository;
  final GroupSessionProvider _groupSession;
  final FirebaseAuthService _authService;
  KurbaniEvent _event;

  StreamSubscription<KurbaniEvent?>? _eventSubscription;
  StreamSubscription<List<KurbaniParticipant>>? _participantSubscription;
  StreamSubscription<List<KurbaniExpense>>? _expenseSubscription;
  StreamSubscription<List<KurbaniAnimalPart>>? _partSubscription;
  List<KurbaniParticipant> _participants = const [];
  List<KurbaniParticipant> _availableParticipants = const [];
  List<KurbaniExpense> _expenses = const [];
  List<KurbaniAnimalPart> _animalParts = const [];
  String? _projectAdminId;
  String? _groupAdminId;
  String? _loadError;
  String? _actionError;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingParticipants = false;
  bool _hasParticipantSnapshot = false;
  bool _hasExpenseSnapshot = false;
  bool _hasPartSnapshot = false;
  bool _hasEventSnapshot = false;

  KurbaniEvent get event => _event;
  List<KurbaniParticipant> get participants => List.unmodifiable(_participants);
  List<KurbaniParticipant> get availableParticipants =>
      List.unmodifiable(_availableParticipants);
  List<KurbaniExpense> get expenses => List.unmodifiable(_expenses);
  List<KurbaniAnimalPart> get animalParts => List.unmodifiable(_animalParts);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingParticipants => _isLoadingParticipants;
  String? get loadError => _loadError;
  String? get actionError => _actionError;
  String? get currentUserId => _authService.currentUser?.uid;
  bool get isAdmin =>
      currentUserId == _projectAdminId || currentUserId == _groupAdminId;
  bool get canEdit => isAdmin && _event.isActive;
  bool get canAccess =>
      isAdmin || _participants.any((item) => item.id == currentUserId);
  double get totalAnimalWeight =>
      _animalParts.fold(0, (total, part) => total + part.weightKg);
  KurbaniSummary get summary => KurbaniCalculator.calculate(
    participants: _participants,
    expenses: _expenses,
  );

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
    _animalParts = const [];
    _loadError = null;
    _actionError = null;
    _isLoading = true;
    _hasParticipantSnapshot = false;
    _hasExpenseSnapshot = false;
    _hasPartSnapshot = false;
    _hasEventSnapshot = false;
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
            _setLoadError('kurbani_error_event_missing');
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
    _partSubscription = _repository
        .watchAnimalParts(groupId: groupId, eventId: _event.id)
        .listen((items) {
          _animalParts = items;
          _hasPartSnapshot = true;
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

  Future<void> addParticipant(String userId, double contribution) async {
    _requireEditable();
    if (contribution <= 0) {
      throw const KurbaniFailure('kurbani_error_contribution');
    }
    await _runAction(
      () => _repository.addParticipant(
        groupId: _requireGroupId(),
        eventId: _event.id,
        userId: userId,
        contribution: contribution,
      ),
    );
    await loadAvailableParticipants();
  }

  Future<void> updateParticipant({
    required String userId,
    required double contribution,
    required KurbaniPaidStatus paidStatus,
  }) async {
    _requireEditable();
    if (contribution <= 0) {
      throw const KurbaniFailure('kurbani_error_contribution');
    }
    await _runAction(
      () => _repository.updateParticipant(
        groupId: _requireGroupId(),
        eventId: _event.id,
        userId: userId,
        contribution: contribution,
        paidStatus: paidStatus,
      ),
    );
  }

  Future<void> removeParticipant(String userId) async {
    _requireEditable();
    await _runAction(
      () => _repository.removeParticipant(
        groupId: _requireGroupId(),
        eventId: _event.id,
        userId: userId,
      ),
    );
    await loadAvailableParticipants();
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String paidByMemberId,
    String? note,
  }) async {
    _requireEditable();
    if (title.trim().isEmpty || amount <= 0) {
      throw const KurbaniFailure('kurbani_error_expense_fields');
    }
    if (!_participants.any((item) => item.id == paidByMemberId)) {
      throw const KurbaniFailure('kurbani_error_choose_payer');
    }
    await _runAction(
      () => _repository.createExpense(
        groupId: _requireGroupId(),
        eventId: _event.id,
        title: title,
        amount: amount,
        paidByMemberId: paidByMemberId,
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

  Future<void> addAnimalPart({
    required String name,
    required double weightKg,
    String? assignedToUid,
    String? note,
  }) async {
    _requireEditable();
    if (name.trim().isEmpty || weightKg <= 0) {
      throw const KurbaniFailure('kurbani_error_animal_fields');
    }
    await _runAction(
      () => _repository.createAnimalPart(
        groupId: _requireGroupId(),
        eventId: _event.id,
        name: name,
        weightKg: weightKg,
        assignedToUid: assignedToUid,
        createdBy: _requireUserId(),
        note: note,
      ),
    );
  }

  Future<void> deleteAnimalPart(String partId) async {
    _requireEditable();
    await _runAction(
      () => _repository.deleteAnimalPart(
        groupId: _requireGroupId(),
        eventId: _event.id,
        partId: partId,
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
        _hasPartSnapshot) {
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
      throw const KurbaniFailure('kurbani_error_choose_group');
    }
    return value;
  }

  String _requireUserId() {
    final value = currentUserId;
    if (value == null || value.isEmpty) {
      throw const KurbaniFailure('kurbani_error_signed_out');
    }
    return value;
  }

  void _requireEditable() {
    if (!isAdmin) throw const KurbaniFailure('kurbani_error_admin_only');
    if (!_event.isActive) {
      throw const KurbaniFailure('kurbani_error_completed_read_only');
    }
  }

  String _message(Object error) =>
      error is KurbaniFailure ? error.messageKey : 'kurbani_error_unknown';

  Future<void> _cancelSubscriptions() async {
    await _eventSubscription?.cancel();
    await _participantSubscription?.cancel();
    await _expenseSubscription?.cancel();
    await _partSubscription?.cancel();
    _eventSubscription = null;
    _participantSubscription = null;
    _expenseSubscription = null;
    _partSubscription = null;
  }

  @override
  void dispose() {
    unawaited(_cancelSubscriptions());
    super.dispose();
  }
}
