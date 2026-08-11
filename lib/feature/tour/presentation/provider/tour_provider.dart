import 'dart:async';

import 'package:fclub/core/services/auth/firebase_auth_service.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/tour/data/models/tour_event.dart';
import 'package:fclub/feature/tour/data/models/tour_failure.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/data/models/tour_project.dart';
import 'package:fclub/feature/tour/data/repositories/tour_repository.dart';
import 'package:flutter/foundation.dart';

class TourProvider with ChangeNotifier {
  TourProvider({
    required TourRepository repository,
    required GroupSessionProvider groupSession,
    required FirebaseAuthService authService,
  }) : _repository = repository,
       _groupSession = groupSession,
       _authService = authService;

  final TourRepository _repository;
  final GroupSessionProvider _groupSession;
  final FirebaseAuthService _authService;

  StreamSubscription<TourProject?>? _projectSubscription;
  StreamSubscription<List<TourEvent>>? _eventSubscription;
  TourProject? _project;
  List<TourEvent> _events = const [];
  List<TourParticipantCandidate> _groupMembers = const [];
  String? _groupAdminId;
  String? _loadedGroupId;
  String? _loadError;
  String? _actionError;
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingMembers = false;
  bool _hasProjectSnapshot = false;
  bool _hasEventSnapshot = false;

  TourProject? get project => _project;
  String get projectName => _project?.name ?? 'Tour';
  List<TourEvent> get events => List.unmodifiable(_events);
  List<TourParticipantCandidate> get groupMembers =>
      List.unmodifiable(_groupMembers);

  TourEvent? get activeEvent {
    for (final event in _events) {
      if (event.isOpen) return event;
    }
    return null;
  }

  List<TourEvent> get history =>
      List.unmodifiable(_events.where((event) => !event.isOpen));

  String? get currentUserId => _authService.currentUser?.uid;
  String? get activeGroupId => _groupSession.groupId;
  bool get isGroupAdmin =>
      _groupAdminId?.isNotEmpty == true && _groupAdminId == currentUserId;
  bool get isProjectAdmin =>
      _project?.adminId.isNotEmpty == true &&
      _project?.adminId == currentUserId;
  bool get canManage => isGroupAdmin || isProjectAdmin;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingMembers => _isLoadingMembers;
  String? get loadError => _loadError;
  String? get actionError => _actionError;

  Future<void> initialize({bool force = false}) async {
    final groupId = activeGroupId;
    if (groupId == null || groupId.isEmpty) {
      _setLoadError('tour_error_choose_group');
      return;
    }
    if (currentUserId == null || currentUserId!.isEmpty) {
      _setLoadError('tour_error_signed_out');
      return;
    }
    if (!force && _loadedGroupId == groupId && _projectSubscription != null) {
      return;
    }

    await _cancelSubscriptions();
    _loadedGroupId = groupId;
    _project = null;
    _events = const [];
    _groupMembers = const [];
    _groupAdminId = null;
    _loadError = null;
    _actionError = null;
    _isLoading = true;
    _hasProjectSnapshot = false;
    _hasEventSnapshot = false;
    notifyListeners();

    try {
      _groupAdminId = await _repository.getGroupAdminId(groupId: groupId);
      _project = await _repository.findProject(groupId: groupId);
    } catch (error) {
      _setLoadError(_message(error));
      return;
    }

    if (_project == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _projectSubscription = _repository.watchProject(groupId: groupId).listen((
      project,
    ) {
      _project = project;
      _hasProjectSnapshot = true;
      _completeInitialLoad();
    }, onError: _handleLoadError);
    _eventSubscription = _repository.watchEvents(groupId: groupId).listen((
      events,
    ) {
      _events = events;
      _hasEventSnapshot = true;
      _completeInitialLoad();
    }, onError: _handleLoadError);
  }

  Future<void> createProject({required String name}) async {
    if (!isGroupAdmin) {
      throw const TourFailure('tour_error_group_admin_create');
    }
    if (name.trim().isEmpty) {
      throw const TourFailure('tour_error_project_name');
    }
    await _runAction(
      () => _repository.createProject(
        groupId: _requireGroupId(),
        name: name,
        adminId: _requireUserId(),
      ),
    );
    await initialize(force: true);
  }

  Future<void> loadGroupMembers() async {
    _requireAdmin();
    _isLoadingMembers = true;
    _actionError = null;
    notifyListeners();
    try {
      _groupMembers = await _repository.getGroupMembers(
        groupId: _requireGroupId(),
      );
    } catch (error) {
      _actionError = _message(error);
    } finally {
      _isLoadingMembers = false;
      notifyListeners();
    }
  }

  Future<TourEvent> createEvent({
    required String tourName,
    required double decidedBudget,
    required Set<String> participantIds,
  }) async {
    _requireAdmin();
    if (activeEvent != null) {
      throw const TourFailure('tour_error_active_event_exists');
    }
    if (tourName.trim().isEmpty || decidedBudget <= 0) {
      throw const TourFailure('tour_error_event_fields');
    }
    final ids = {...participantIds, _requireUserId()};
    TourEvent? result;
    await _runAction(() async {
      result = await _repository.createEvent(
        groupId: _requireGroupId(),
        tourName: tourName,
        decidedBudget: decidedBudget,
        createdBy: _requireUserId(),
        participantIds: ids.toList(growable: false),
      );
    });
    return result!;
  }

  Future<void> completeEvent(String eventId) async {
    _requireAdmin();
    await _runAction(
      () => _repository.updateEventStatus(
        groupId: _requireGroupId(),
        eventId: eventId,
        status: TourEventStatus.completed,
      ),
    );
  }

  Future<void> cancelEvent(String eventId) async {
    _requireAdmin();
    await _runAction(
      () => _repository.updateEventStatus(
        groupId: _requireGroupId(),
        eventId: eventId,
        status: TourEventStatus.cancelled,
      ),
    );
  }

  Future<void> deleteEvent(String eventId) async {
    _requireAdmin();
    await _runAction(
      () =>
          _repository.deleteEvent(groupId: _requireGroupId(), eventId: eventId),
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
    if (_hasProjectSnapshot && _hasEventSnapshot) _isLoading = false;
    notifyListeners();
  }

  void _handleLoadError(Object error) => _setLoadError(_message(error));

  void _setLoadError(String key) {
    _loadError = key;
    _isLoading = false;
    notifyListeners();
  }

  String _requireGroupId() {
    final value = activeGroupId;
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

  void _requireAdmin() {
    if (!canManage) throw const TourFailure('tour_error_admin_only');
  }

  String _message(Object error) =>
      error is TourFailure ? error.messageKey : 'tour_error_unknown';

  Future<void> _cancelSubscriptions() async {
    await _projectSubscription?.cancel();
    await _eventSubscription?.cancel();
    _projectSubscription = null;
    _eventSubscription = null;
  }

  @override
  void dispose() {
    unawaited(_cancelSubscriptions());
    super.dispose();
  }
}
