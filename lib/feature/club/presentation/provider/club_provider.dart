import 'dart:async';

import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/club/data/model/club_failure.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_project.dart';
import 'package:fclub/feature/club/data/repositories/club_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:flutter/foundation.dart';

class ClubProvider with ChangeNotifier {
  static const Duration _networkTimeout = Duration(seconds: 10);
  static const Duration _listenerCancelTimeout = Duration(seconds: 2);

  ClubProvider({
    required ClubRepository repository,
    required GroupSessionProvider groupSession,
    required FirebaseAuthService authService,
  }) : _repository = repository,
       _groupSession = groupSession,
       _authService = authService;

  final ClubRepository _repository;
  final GroupSessionProvider _groupSession;
  final FirebaseAuthService _authService;

  StreamSubscription<List<ClubPayment>>? _paymentsSubscription;
  StreamSubscription<List<ClubPayment>>? _sharedPaidPaymentsSubscription;
  StreamSubscription<List<ClubMember>>? _membersSubscription;
  StreamSubscription<String?>? _adminSubscription;
  Future<void>? _initializeOperation;
  Future<void>? _reloadOperation;
  int _sessionListenerVersion = 0;
  int _paymentListenerVersion = 0;

  List<ClubPayment> _payments = const [];
  List<ClubPayment> _filteredPayments = const [];
  List<ClubPayment> _primaryPayments = const [];
  List<ClubPayment> _sharedPaidPayments = const [];
  List<ClubMember> _members = const [];
  List<ClubMemberCandidate> _availableMembers = const [];
  ClubPaymentFilter _filter = const ClubPaymentFilter();
  String? _adminId;
  String? _groupAdminId;
  ClubProject? _project;
  String? _loadedGroupId;
  String? _loadedUserId;
  String? _loadError;
  String? _actionError;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingCandidates = false;
  bool _hasAdminSnapshot = false;
  bool _hasMembersSnapshot = false;
  bool _hasPaymentsSnapshot = false;
  bool _hasPrimaryPaymentsSnapshot = false;
  bool _hasSharedPaidPaymentsSnapshot = false;
  bool _hasPaymentScope = false;
  String? _paymentScopeUserId;

  List<ClubPayment> get payments => List.unmodifiable(_payments);
  List<ClubPayment> get filteredPayments =>
      List.unmodifiable(_filteredPayments);
  List<ClubPayment> get visiblePayments => paymentsVisibleTo(
    _payments,
    isAdmin: isAdmin,
    memberId: currentMember?.id ?? currentUserId,
  );
  List<ClubPayment> get visibleFilteredPayments => paymentsVisibleTo(
    _filteredPayments,
    isAdmin: isAdmin,
    memberId: currentMember?.id ?? currentUserId,
  );
  List<ClubMember> get members => List.unmodifiable(_members);
  List<ClubMemberCandidate> get availableMembers =>
      List.unmodifiable(_availableMembers);
  ClubPaymentFilter get filter => _filter;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingCandidates => _isLoadingCandidates;
  String? get loadError => _loadError;
  String? get actionError => _actionError;
  String? get adminId => _adminId;
  ClubProject? get project => _project;
  String get projectName => _project?.name ?? 'Club';
  double get monthlyTargetPerMember => _project?.monthlyTargetPerMember ?? 0;
  String? get currentUserId => _authService.currentUser?.uid;
  String? get currentUserEmail =>
      _authService.currentUser?.email?.trim().toLowerCase();
  String? get activeGroupId => _groupSession.groupId;

  ClubMember? get currentMember {
    final userId = currentUserId;
    if (userId == null) return null;
    for (final member in _members) {
      if (member.id == userId) return member;
    }
    return null;
  }

  bool get isProjectAdmin =>
      isClubAdmin(adminId: _adminId, userId: currentUserId);
  bool get isGroupAdmin =>
      isClubAdmin(adminId: _groupAdminId, userId: currentUserId);
  bool get isAdmin => isProjectAdmin || isGroupAdmin;
  bool get canManageParticipants => isAdmin;
  bool get canAccessProject => isAdmin || currentMember != null;

  ClubMember? memberById(String id) {
    for (final member in _members) {
      if (member.id == id) return member;
    }
    return null;
  }

  double get totalCollected => _payments
      .where((payment) => payment.status == PaymentStatus.paid)
      .fold(0, (total, payment) => total + payment.amount);

  ClubMonthSummary get currentMonthSummary {
    final now = DateTime.now();
    return ClubMonthSummary.calculate(
      month: DateTime(now.year, now.month),
      memberCount: _members.length,
      perMemberTarget: monthlyTargetPerMember,
      payments: _payments,
    );
  }

  List<ClubMonthSummary> get monthSummaries {
    final now = DateTime.now();
    final months = <DateTime>{DateTime(now.year, now.month)};
    for (final payment in _payments) {
      months.add(payment.monthDate);
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted
        .map(
          (month) => ClubMonthSummary.calculate(
            month: month,
            memberCount: _members.length,
            perMemberTarget: monthlyTargetPerMember,
            payments: _payments,
          ),
        )
        .toList(growable: false);
  }

  Future<void> initialize({bool force = false}) async {
    final activeOperation = _initializeOperation;
    if (activeOperation != null) {
      await activeOperation;
      final groupId = activeGroupId;
      final userId = currentUserId;
      if (_loadedGroupId == groupId && _loadedUserId == userId) return;
      return initialize(force: force);
    }

    final operation = _initialize(force: force);
    _initializeOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_initializeOperation, operation)) {
        _initializeOperation = null;
      }
    }
  }

  Future<void> _initialize({required bool force}) async {
    final groupId = activeGroupId;
    final userId = currentUserId;
    if (groupId == null || groupId.isEmpty) {
      _loadError = 'Choose a group before opening Club.';
      _isLoading = false;
      notifyListeners();
      return;
    }
    if (userId == null || userId.isEmpty) {
      _loadError = 'Your session expired. Please sign in again.';
      _isLoading = false;
      notifyListeners();
      return;
    }
    if (!force &&
        _loadedGroupId == groupId &&
        _loadedUserId == userId &&
        _paymentsSubscription != null &&
        _adminSubscription != null) {
      return;
    }

    final preserveData =
        force &&
        _loadedGroupId == groupId &&
        _loadedUserId == userId &&
        _project != null;
    await _cancelSubscriptions();
    _loadedGroupId = groupId;
    _loadedUserId = userId;
    if (!preserveData) {
      _payments = const [];
      _filteredPayments = const [];
      _primaryPayments = const [];
      _sharedPaidPayments = const [];
      _members = const [];
      _adminId = null;
      _groupAdminId = null;
      _project = null;
      _filter = const ClubPaymentFilter();
    }
    _hasAdminSnapshot = false;
    _hasMembersSnapshot = false;
    _hasPaymentsSnapshot = false;
    _hasPrimaryPaymentsSnapshot = false;
    _hasSharedPaidPaymentsSnapshot = false;
    _hasPaymentScope = false;
    _paymentScopeUserId = null;
    _isLoading = !preserveData;
    _loadError = null;
    _actionError = null;
    notifyListeners();

    try {
      final metadata = await Future.wait<Object?>([
        _repository.getGroupAdminId(groupId: groupId),
        _repository.findProject(groupId: groupId),
      ]).timeout(_networkTimeout);
      _groupAdminId = metadata[0] as String?;
      _project = metadata[1] as ClubProject?;
    } on TimeoutException {
      _handleLoadError(
        const ClubFailure('Club refresh timed out. Please try again.'),
      );
      return;
    } catch (error) {
      _handleLoadError(error);
      return;
    }
    if (activeGroupId != groupId || currentUserId != userId) return;
    final activeProject = _project;
    if (activeProject == null) {
      _payments = const [];
      _filteredPayments = const [];
      _members = const [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _adminId = activeProject.adminId;
    final sessionListenerVersion = _sessionListenerVersion;

    _membersSubscription = _repository
        .watchMembers(groupId: groupId, projectId: activeProject.id)
        .listen(
          (members) {
            if (sessionListenerVersion != _sessionListenerVersion) return;
            _members = members;
            _hasMembersSnapshot = true;
            _completeInitialLoad();
          },
          onError: (Object error) {
            if (sessionListenerVersion != _sessionListenerVersion) return;
            _handleLoadError(error);
          },
        );
    _adminSubscription = _repository
        .watchAdminId(groupId: groupId, projectId: activeProject.id)
        .listen(
          (adminId) {
            if (sessionListenerVersion != _sessionListenerVersion) return;
            final wasAdmin = isAdmin;
            _adminId = adminId;
            _hasAdminSnapshot = true;
            _completeInitialLoad();
            if (wasAdmin != isAdmin) {
              unawaited(
                _restartPaymentsForRole(
                  groupId: groupId,
                  projectId: activeProject.id,
                ),
              );
            }
          },
          onError: (Object error) {
            if (sessionListenerVersion != _sessionListenerVersion) return;
            _handleLoadError(error);
          },
        );
    _listenToPayments(groupId: groupId, projectId: activeProject.id);
  }

  /// Restarts the payment listeners used by pull-to-refresh.
  ///
  /// Club data is already backed by live Firestore streams, so pull-to-refresh
  /// only needs to reconnect the payment queries. Keeping the member/admin
  /// streams alive avoids an unnecessary metadata round trip, and the returned
  /// future completes as soon as the listeners have been reattached so a
  /// [RefreshIndicator] cannot wait forever for a network snapshot.
  Future<void> reload() async {
    final activeOperation = _reloadOperation;
    if (activeOperation != null) return activeOperation;

    final operation = _reloadPayments();
    _reloadOperation = operation;
    try {
      await operation;
    } finally {
      if (identical(_reloadOperation, operation)) _reloadOperation = null;
    }
  }

  Future<void> _reloadPayments() async {
    final groupId = activeGroupId;
    final userId = currentUserId;
    final activeProject = _project;
    if (groupId == null ||
        groupId.isEmpty ||
        userId == null ||
        userId.isEmpty ||
        _loadedGroupId != groupId ||
        _loadedUserId != userId ||
        activeProject == null) {
      await initialize(force: true);
      return;
    }

    _loadError = null;
    _actionError = null;
    await _cancelPaymentSubscriptions();
    _listenToPayments(groupId: groupId, projectId: activeProject.id);
    notifyListeners();
  }

  Future<void> setFilter(ClubPaymentFilter filter) async {
    if (_sameFilter(_filter, filter)) return;
    _filter = filter;
    _actionError = null;
    _applyPaymentFilter();
    notifyListeners();
  }

  Future<void> submitPayment({
    String? memberId,
    required double amount,
    required DateTime month,
    required PaymentMethod paymentMethod,
    String? note,
  }) async {
    final userId = _requireUserId();
    final selectedMemberId = isAdmin ? memberId : (currentMember?.id ?? userId);
    if (selectedMemberId == null || selectedMemberId.isEmpty) {
      throw const ClubFailure('Select a member.');
    }
    await _runAction(
      () => _repository.createPayment(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        userId: selectedMemberId,
        amount: amount,
        month: monthKey(month),
        status: isAdmin ? PaymentStatus.paid : PaymentStatus.pending,
        paymentMethod: paymentMethod,
        submittedBy: userId,
        note: note,
      ),
    );
  }

  Future<void> updatePaymentStatus(
    String paymentId,
    PaymentStatus status,
  ) async {
    _requireAdmin();
    await _runAction(
      () => _repository.updatePaymentStatus(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        paymentId: paymentId,
        status: status,
        reviewedBy: _requireUserId(),
      ),
    );
  }

  Future<void> loadAvailableMembers() async {
    _requireAdmin();
    _isLoadingCandidates = true;
    _actionError = null;
    notifyListeners();
    try {
      _availableMembers = await _repository.getAvailableMembers(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
      );
    } catch (error) {
      _actionError = _message(error);
    } finally {
      _isLoadingCandidates = false;
      notifyListeners();
    }
  }

  Future<void> addMember(ClubMemberCandidate member) async {
    _requireAdmin();
    await _runAction(
      () => _repository.addMember(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        member: member,
      ),
    );
    await loadAvailableMembers();
  }

  Future<void> removeMember(ClubMember member) async {
    _requireAdmin();
    if (member.id == _adminId) {
      throw const ClubFailure('The Club admin cannot be removed.');
    }
    await _runAction(
      () => _repository.removeMember(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        memberId: member.id,
      ),
    );
    await loadAvailableMembers();
  }

  Future<void> transferAdmin(ClubMember member) async {
    _requireProjectAdmin();
    final currentAdminId = _requireUserId();
    if (member.id == _adminId) {
      throw const ClubFailure('This member is already the Club admin.');
    }
    if (!_members.any((candidate) => candidate.id == member.id)) {
      throw const ClubFailure('Choose an active Club member as admin.');
    }
    await _runAction(
      () => _repository.transferAdmin(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
        currentAdminId: currentAdminId,
        newAdminId: member.id,
      ),
    );
    _adminId = member.id;
    unawaited(
      _restartPaymentsForRole(
        groupId: _requireGroupId(),
        projectId: _requireProjectId(),
      ),
    );
    notifyListeners();
  }

  Future<void> createProject({
    required String name,
    required double monthlyTargetPerMember,
  }) async {
    if (!isGroupAdmin) {
      throw const ClubFailure('Only the group admin can create a Club.');
    }
    if (name.trim().isEmpty || monthlyTargetPerMember <= 0) {
      throw const ClubFailure('Enter a name and a valid monthly target.');
    }
    await _runAction(() async {
      await _repository.createProject(
        groupId: _requireGroupId(),
        name: name,
        adminId: _requireUserId(),
        monthlyTargetPerMember: monthlyTargetPerMember,
      );
    });
    await initialize(force: true);
  }

  void clearActionError() {
    if (_actionError == null) return;
    _actionError = null;
    notifyListeners();
  }

  static String monthKey(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';

  static List<ClubPayment> paymentsVisibleTo(
    Iterable<ClubPayment> payments, {
    required bool isAdmin,
    required String? memberId,
  }) {
    if (isAdmin) return List<ClubPayment>.unmodifiable(payments);
    if (memberId == null || memberId.isEmpty) return const [];
    return List<ClubPayment>.unmodifiable(
      payments.where(
        (payment) =>
            payment.status == PaymentStatus.paid || payment.userId == memberId,
      ),
    );
  }

  static bool isClubAdmin({required String? adminId, required String? userId}) {
    return adminId != null &&
        adminId.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty &&
        adminId == userId;
  }

  void _completeInitialLoad() {
    if (_hasAdminSnapshot && _hasMembersSnapshot && _hasPaymentsSnapshot) {
      _isLoading = false;
    }
    notifyListeners();
  }

  void _listenToPayments({required String groupId, required String projectId}) {
    final paymentListenerVersion = _paymentListenerVersion;
    final scopeUserId = isAdmin ? null : _requireUserId();
    _hasPaymentScope = true;
    _paymentScopeUserId = scopeUserId;
    _primaryPayments = const [];
    _sharedPaidPayments = const [];
    _hasPrimaryPaymentsSnapshot = false;
    _hasSharedPaidPaymentsSnapshot = isAdmin;
    _paymentsSubscription = _repository
        .watchPayments(
          groupId: groupId,
          projectId: projectId,
          filter: scopeUserId == null
              ? const ClubPaymentFilter()
              : ClubPaymentFilter(userId: scopeUserId),
        )
        .listen(
          (payments) {
            if (paymentListenerVersion != _paymentListenerVersion) return;
            _primaryPayments = payments;
            _hasPrimaryPaymentsSnapshot = true;
            _syncPayments();
          },
          onError: (Object error) {
            if (paymentListenerVersion != _paymentListenerVersion) return;
            _handleLoadError(error);
          },
        );

    if (!isAdmin) {
      _sharedPaidPaymentsSubscription = _repository
          .watchPayments(
            groupId: groupId,
            projectId: projectId,
            filter: const ClubPaymentFilter(status: PaymentStatus.paid),
          )
          .listen(
            (payments) {
              if (paymentListenerVersion != _paymentListenerVersion) return;
              _sharedPaidPayments = payments;
              _hasSharedPaidPaymentsSnapshot = true;
              _syncPayments();
            },
            onError: (Object error) {
              if (paymentListenerVersion != _paymentListenerVersion) return;
              _handleLoadError(error);
            },
          );
    }
  }

  void _syncPayments() {
    _payments = mergePaymentSnapshots(
      primaryPayments: _primaryPayments,
      sharedPaidPayments: _sharedPaidPayments,
    );
    _applyPaymentFilter();
    _hasPaymentsSnapshot =
        _hasPrimaryPaymentsSnapshot && _hasSharedPaidPaymentsSnapshot;
    _completeInitialLoad();
  }

  /// Merges the member-scoped stream with the shared approved stream.
  ///
  /// The approved stream is deliberately applied last. During a Firestore
  /// status transition the two query snapshots can arrive in either order; an
  /// approved copy must never be overwritten by the older pending copy.
  @visibleForTesting
  static List<ClubPayment> mergePaymentSnapshots({
    required Iterable<ClubPayment> primaryPayments,
    required Iterable<ClubPayment> sharedPaidPayments,
  }) {
    final paymentsById = <String, ClubPayment>{
      for (final payment in primaryPayments) payment.id: payment,
      for (final payment in sharedPaidPayments) payment.id: payment,
    };
    return paymentsById.values.toList(
      growable: false,
    )..sort((first, second) => second.submittedAt.compareTo(first.submittedAt));
  }

  void _applyPaymentFilter() {
    _filteredPayments = _filter.isEmpty
        ? _payments
        : _payments.where(_filter.matches).toList(growable: false);
  }

  Future<void> _restartPaymentsForRole({
    required String groupId,
    required String projectId,
  }) async {
    final nextScope = isAdmin ? null : _requireUserId();
    if (_hasPaymentScope && _paymentScopeUserId == nextScope) return;
    await _cancelPaymentSubscriptions();
    _filter = const ClubPaymentFilter();
    _listenToPayments(groupId: groupId, projectId: projectId);
  }

  void _handleLoadError(Object error) {
    _isLoading = false;
    _loadError = _message(error);
    notifyListeners();
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

  String _requireGroupId() {
    final groupId = activeGroupId;
    if (groupId == null || groupId.isEmpty) {
      throw const ClubFailure('Choose a group before opening Club.');
    }
    return groupId;
  }

  String _requireUserId() {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw const ClubFailure('Your session expired. Please sign in again.');
    }
    return userId;
  }

  String _requireProjectId() {
    final projectId = _project?.id;
    if (projectId == null || projectId.isEmpty) {
      throw const ClubFailure('Create or select a Club project first.');
    }
    return projectId;
  }

  void _requireAdmin() {
    if (!isAdmin) {
      throw const ClubFailure('Only a project or group admin can do this.');
    }
  }

  void _requireProjectAdmin() {
    if (!isProjectAdmin) {
      throw const ClubFailure('Only the current project admin can do this.');
    }
  }

  String _message(Object error) {
    return error is ClubFailure ? error.message : 'Something went wrong.';
  }

  bool _sameFilter(ClubPaymentFilter first, ClubPaymentFilter second) {
    return first.userId == second.userId &&
        first.month == second.month &&
        first.status == second.status &&
        first.paymentMethod == second.paymentMethod;
  }

  Future<void> _cancelSubscriptions() async {
    _sessionListenerVersion++;
    await _cancelPaymentSubscriptions();
    final membersSubscription = _membersSubscription;
    final adminSubscription = _adminSubscription;
    _membersSubscription = null;
    _adminSubscription = null;
    await Future.wait<void>([
      if (membersSubscription != null) membersSubscription.cancel(),
      if (adminSubscription != null) adminSubscription.cancel(),
    ]).timeout(_listenerCancelTimeout, onTimeout: () => const []);
  }

  Future<void> _cancelPaymentSubscriptions() async {
    _paymentListenerVersion++;
    final paymentsSubscription = _paymentsSubscription;
    final sharedPaidPaymentsSubscription = _sharedPaidPaymentsSubscription;
    _paymentsSubscription = null;
    _sharedPaidPaymentsSubscription = null;
    await Future.wait<void>([
      if (paymentsSubscription != null) paymentsSubscription.cancel(),
      if (sharedPaidPaymentsSubscription != null)
        sharedPaidPaymentsSubscription.cancel(),
    ]).timeout(_listenerCancelTimeout, onTimeout: () => const []);
  }

  @override
  void dispose() {
    unawaited(_cancelSubscriptions());
    super.dispose();
  }
}
