import 'dart:async';

import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/locker/data/models/locker_failure.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_project.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';
import 'package:fclub/feature/locker/data/repositories/locker_repository.dart';
import 'package:flutter/foundation.dart';

class LockerProvider with ChangeNotifier {
  LockerProvider({
    required LockerRepository repository,
    required GroupSessionProvider groupSession,
    required FirebaseAuthService authService,
  }) : _repository = repository,
       _groupSession = groupSession,
       _authService = authService;

  final LockerRepository _repository;
  final GroupSessionProvider _groupSession;
  final FirebaseAuthService _authService;

  StreamSubscription<LockerProject?>? _projectSubscription;
  StreamSubscription<List<LockerParticipant>>? _participantSubscription;
  StreamSubscription<List<LockerTransaction>>? _transactionSubscription;

  LockerProject? _project;
  String? _groupAdminId;
  List<LockerParticipant> _participants = const [];
  List<LockerParticipant> _availableParticipants = const [];
  List<LockerTransaction> _transactions = const [];
  String? _loadedGroupId;
  String? _loadError;
  String? _actionError;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingParticipants = false;
  bool _hasProjectSnapshot = false;
  bool _hasParticipantSnapshot = false;
  bool _hasTransactionSnapshot = false;
  bool _hasTransactionScope = false;
  String? _transactionScopeUserId;

  LockerProject? get project => _project;
  String get projectName => _project?.name ?? 'Locker';
  List<LockerParticipant> get participants => List.unmodifiable(_participants);
  List<LockerParticipant> get availableParticipants =>
      List.unmodifiable(_availableParticipants);
  List<LockerTransaction> get transactions => List.unmodifiable(_transactions);
  List<LockerTransaction> get expenses => List.unmodifiable(
    _transactions.where(
      (transaction) => transaction.type == LockerTransactionType.expense,
    ),
  );
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingParticipants => _isLoadingParticipants;
  String? get loadError => _loadError;
  String? get actionError => _actionError;
  String? get currentUserId => _authService.currentUser?.uid;
  String? get activeGroupId => _groupSession.groupId;

  LockerParticipant? get currentParticipant {
    final userId = currentUserId;
    if (userId == null) return null;
    for (final participant in _participants) {
      if (participant.id == userId) return participant;
    }
    return null;
  }

  bool get isProjectAdmin =>
      _project?.adminId.isNotEmpty == true &&
      _project?.adminId == currentUserId;
  bool get isGroupAdmin =>
      _groupAdminId?.isNotEmpty == true && _groupAdminId == currentUserId;
  bool get isAdmin => isProjectAdmin || isGroupAdmin;
  bool get canAccessProject => isAdmin || currentParticipant != null;
  bool get canManageParticipants => isAdmin;

  double get totalContributions =>
      _approvedTotal(LockerTransactionType.contribution);
  double get baseBalance => totalContributions;
  double get totalExpenses => _approvedTotal(LockerTransactionType.expense);
  double get currentCash => totalContributions - totalExpenses;

  Future<void> initialize({bool force = false}) async {
    final groupId = activeGroupId;
    final userId = currentUserId;
    if (groupId == null || groupId.isEmpty) {
      _setLoadError('Choose a group before opening Locker.');
      return;
    }
    if (userId == null || userId.isEmpty) {
      _setLoadError('Your session expired. Please sign in again.');
      return;
    }
    if (!force && _loadedGroupId == groupId && _projectSubscription != null) {
      return;
    }

    await _cancelSubscriptions();
    _loadedGroupId = groupId;
    _project = null;
    _groupAdminId = null;
    _participants = const [];
    _availableParticipants = const [];
    _transactions = const [];
    _loadError = null;
    _actionError = null;
    _isLoading = true;
    _hasProjectSnapshot = false;
    _hasParticipantSnapshot = false;
    _hasTransactionSnapshot = false;
    _hasTransactionScope = false;
    _transactionScopeUserId = null;
    notifyListeners();

    try {
      _groupAdminId = await _repository.getGroupAdminId(groupId: groupId);
      _project = await _repository.findProject(groupId: groupId);
    } catch (error) {
      _setLoadError(_message(error));
      return;
    }
    final activeProject = _project;
    if (activeProject == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _projectSubscription = _repository
        .watchProject(groupId: groupId, projectId: activeProject.id)
        .listen((project) {
          final wasAdmin = isAdmin;
          _project = project;
          _hasProjectSnapshot = true;
          _completeInitialLoad();
          if (wasAdmin != isAdmin) {
            unawaited(
              _restartTransactionsForRole(
                groupId: groupId,
                projectId: activeProject.id,
              ),
            );
          }
        }, onError: _handleLoadError);
    _participantSubscription = _repository
        .watchParticipants(groupId: groupId, projectId: activeProject.id)
        .listen((participants) {
          _participants = participants;
          _hasParticipantSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);

    _listenToTransactions(groupId: groupId, projectId: activeProject.id);
  }

  Future<void> createProject({required String name}) async {
    if (!isGroupAdmin) {
      throw const LockerFailure('Only the group admin can create a Locker.');
    }
    if (name.trim().isEmpty) {
      throw const LockerFailure('Enter a project name.');
    }
    await _runAction(() async {
      await _repository.createProject(
        groupId: _requireGroupId(),
        name: name,
        adminId: _requireUserId(),
      );
    });
    await initialize(force: true);
  }

  Future<void> submitTransaction({
    required LockerTransactionType type,
    required double amount,
    String? participantId,
    String? note,
  }) async {
    if (!canAccessProject) {
      throw const LockerFailure('You are not a participant in this project.');
    }
    if (amount <= 0) throw const LockerFailure('Enter a valid amount.');
    final userId = _requireUserId();
    final targetUserId = isAdmin ? participantId : userId;
    if (targetUserId == null ||
        !_participants.any((participant) => participant.id == targetUserId)) {
      throw const LockerFailure('Choose an active project participant.');
    }
    await _runAction(
      () => _repository.createTransaction(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        type: type,
        amount: amount,
        userId: targetUserId,
        status: isAdmin
            ? LockerTransactionStatus.approved
            : LockerTransactionStatus.pending,
        submittedBy: userId,
        note: note,
      ),
    );
  }

  Future<void> reviewTransaction(
    String transactionId,
    LockerTransactionStatus status,
  ) async {
    _requireAdmin();
    await _runAction(
      () => _repository.reviewTransaction(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        transactionId: transactionId,
        status: status,
        reviewedBy: _requireUserId(),
      ),
    );
  }

  Future<void> loadAvailableParticipants() async {
    _requireAdmin();
    _isLoadingParticipants = true;
    _actionError = null;
    notifyListeners();
    try {
      _availableParticipants = await _repository.getAvailableParticipants(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
      );
    } catch (error) {
      _actionError = _message(error);
    } finally {
      _isLoadingParticipants = false;
      notifyListeners();
    }
  }

  Future<void> addParticipant(String userId) async {
    _requireAdmin();
    await _runAction(
      () => _repository.addParticipant(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        userId: userId,
      ),
    );
    await loadAvailableParticipants();
  }

  Future<void> removeParticipant(String userId) async {
    _requireAdmin();
    if (userId == _project?.adminId) {
      throw const LockerFailure('The project admin cannot be removed.');
    }
    await _runAction(
      () => _repository.removeParticipant(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        userId: userId,
      ),
    );
    await loadAvailableParticipants();
  }

  Future<void> transferAdmin(String newAdminId) async {
    if (!isProjectAdmin) {
      throw const LockerFailure('Only the current project admin can do this.');
    }
    await _runAction(
      () => _repository.transferAdmin(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        currentAdminId: _requireUserId(),
        newAdminId: newAdminId,
      ),
    );
  }

  double _approvedTotal(LockerTransactionType type) {
    return _transactions
        .where(
          (transaction) =>
              transaction.type == type &&
              transaction.status == LockerTransactionStatus.approved,
        )
        .fold(0, (total, transaction) => total + transaction.amount);
  }

  void _listenToTransactions({
    required String groupId,
    required String projectId,
  }) {
    final scopeUserId = isAdmin ? null : _requireUserId();
    _hasTransactionScope = true;
    _transactionScopeUserId = scopeUserId;
    _transactionSubscription = _repository
        .watchTransactions(
          groupId: groupId,
          projectId: projectId,
          userId: scopeUserId,
        )
        .listen((transactions) {
          _transactions = transactions;
          _hasTransactionSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);
  }

  Future<void> _restartTransactionsForRole({
    required String groupId,
    required String projectId,
  }) async {
    final nextScope = isAdmin ? null : _requireUserId();
    if (_hasTransactionScope && _transactionScopeUserId == nextScope) return;
    await _transactionSubscription?.cancel();
    _transactionSubscription = null;
    _listenToTransactions(groupId: groupId, projectId: projectId);
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
    if (_hasProjectSnapshot &&
        _hasParticipantSnapshot &&
        _hasTransactionSnapshot) {
      _isLoading = false;
    }
    notifyListeners();
  }

  void _handleLoadError(Object error) => _setLoadError(_message(error));

  void _setLoadError(String message) {
    _loadError = message;
    _isLoading = false;
    notifyListeners();
  }

  String _requireGroupId() {
    final id = activeGroupId;
    if (id == null || id.isEmpty) {
      throw const LockerFailure('Choose a group first.');
    }
    return id;
  }

  String _requireProjectId() {
    final id = _project?.id;
    if (id == null || id.isEmpty) {
      throw const LockerFailure('Create or select a Locker project first.');
    }
    return id;
  }

  String _requireUserId() {
    final id = currentUserId;
    if (id == null || id.isEmpty) {
      throw const LockerFailure('Your session expired. Please sign in again.');
    }
    return id;
  }

  void _requireAdmin() {
    if (!isAdmin) {
      throw const LockerFailure('Only a project or group admin can do this.');
    }
  }

  String _message(Object error) => error is LockerFailure
      ? error.message
      : 'Something went wrong. Please try again.';

  Future<void> _cancelSubscriptions() async {
    await _projectSubscription?.cancel();
    await _participantSubscription?.cancel();
    await _transactionSubscription?.cancel();
    _projectSubscription = null;
    _participantSubscription = null;
    _transactionSubscription = null;
  }

  @override
  void dispose() {
    unawaited(_cancelSubscriptions());
    super.dispose();
  }
}
