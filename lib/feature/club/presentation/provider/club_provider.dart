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
  StreamSubscription<List<ClubPayment>>? _filteredSubscription;
  StreamSubscription<List<ClubMember>>? _membersSubscription;
  StreamSubscription<String?>? _adminSubscription;

  List<ClubPayment> _payments = const [];
  List<ClubPayment> _filteredPayments = const [];
  List<ClubMember> _members = const [];
  List<ClubMemberCandidate> _availableMembers = const [];
  ClubPaymentFilter _filter = const ClubPaymentFilter();
  String? _adminId;
  String? _groupAdminId;
  ClubProject? _project;
  String? _loadedGroupId;
  String? _loadError;
  String? _actionError;
  bool _isLoading = false;
  bool _isFiltering = false;
  bool _isSubmitting = false;
  bool _isLoadingCandidates = false;
  bool _hasAdminSnapshot = false;
  bool _hasMembersSnapshot = false;
  bool _hasPaymentsSnapshot = false;
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
  bool get isFiltering => _isFiltering;
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
      memberCount: isAdmin ? _members.length : (currentMember == null ? 0 : 1),
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
            memberCount: isAdmin
                ? _members.length
                : (currentMember == null ? 0 : 1),
            perMemberTarget: monthlyTargetPerMember,
            payments: _payments,
          ),
        )
        .toList(growable: false);
  }

  Future<void> initialize({bool force = false}) async {
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
        _paymentsSubscription != null &&
        _adminSubscription != null) {
      return;
    }

    await _cancelSubscriptions();
    _loadedGroupId = groupId;
    _payments = const [];
    _filteredPayments = const [];
    _members = const [];
    _adminId = null;
    _groupAdminId = null;
    _project = null;
    _filter = const ClubPaymentFilter();
    _hasAdminSnapshot = false;
    _hasMembersSnapshot = false;
    _hasPaymentsSnapshot = false;
    _hasPaymentScope = false;
    _paymentScopeUserId = null;
    _isLoading = true;
    _loadError = null;
    _actionError = null;
    notifyListeners();

    try {
      _groupAdminId = await _repository.getGroupAdminId(groupId: groupId);
      _project = await _repository.findProject(groupId: groupId);
    } catch (error) {
      _handleLoadError(error);
      return;
    }
    final activeProject = _project;
    if (activeProject == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _adminId = activeProject.adminId;

    _membersSubscription = _repository
        .watchMembers(groupId: groupId, projectId: activeProject.id)
        .listen((members) {
          _members = members;
          _hasMembersSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);
    _adminSubscription = _repository
        .watchAdminId(groupId: groupId, projectId: activeProject.id)
        .listen((adminId) {
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
        }, onError: _handleLoadError);
    _listenToPayments(groupId: groupId, projectId: activeProject.id);
  }

  Future<void> setFilter(ClubPaymentFilter filter) async {
    if (_sameFilter(_filter, filter)) return;
    _filter = filter;
    _actionError = null;
    await _filteredSubscription?.cancel();
    _filteredSubscription = null;
    if (filter.isEmpty) {
      _filteredPayments = _payments;
      _isFiltering = false;
      notifyListeners();
      return;
    }

    final groupId = _requireGroupId();
    _isFiltering = true;
    notifyListeners();
    final effectiveFilter = isAdmin
        ? filter
        : filter.copyWith(userId: _requireUserId());
    _filteredSubscription = _repository
        .watchPayments(
          groupId: groupId,
          projectId: _requireProjectId(),
          filter: effectiveFilter,
        )
        .listen(
          (payments) {
            _filteredPayments = payments;
            _isFiltering = false;
            notifyListeners();
          },
          onError: (Object error) {
            _isFiltering = false;
            _actionError = _message(error);
            notifyListeners();
          },
        );
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
      payments.where((payment) => payment.userId == memberId),
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
    final scopeUserId = isAdmin ? null : _requireUserId();
    _hasPaymentScope = true;
    _paymentScopeUserId = scopeUserId;
    _paymentsSubscription = _repository
        .watchPayments(
          groupId: groupId,
          projectId: projectId,
          filter: scopeUserId == null
              ? const ClubPaymentFilter()
              : ClubPaymentFilter(userId: scopeUserId),
        )
        .listen((payments) {
          _payments = payments;
          if (_filter.isEmpty) _filteredPayments = payments;
          _hasPaymentsSnapshot = true;
          _completeInitialLoad();
        }, onError: _handleLoadError);
  }

  Future<void> _restartPaymentsForRole({
    required String groupId,
    required String projectId,
  }) async {
    final nextScope = isAdmin ? null : _requireUserId();
    if (_hasPaymentScope && _paymentScopeUserId == nextScope) return;
    await _paymentsSubscription?.cancel();
    await _filteredSubscription?.cancel();
    _paymentsSubscription = null;
    _filteredSubscription = null;
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
    await _paymentsSubscription?.cancel();
    await _filteredSubscription?.cancel();
    await _membersSubscription?.cancel();
    await _adminSubscription?.cancel();
    _paymentsSubscription = null;
    _filteredSubscription = null;
    _membersSubscription = null;
    _adminSubscription = null;
  }

  @override
  void dispose() {
    unawaited(_cancelSubscriptions());
    super.dispose();
  }
}
