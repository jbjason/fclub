import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:flutter/foundation.dart';

enum GroupBootstrapStatus { checking, gateway, home }

class GroupBootstrapProvider with ChangeNotifier {
  GroupBootstrapProvider({
    required GroupRepository repository,
    required GroupSessionProvider groupSession,
  }) : _repository = repository,
       _groupSession = groupSession;

  final GroupRepository _repository;
  final GroupSessionProvider _groupSession;

  GroupBootstrapStatus _status = GroupBootstrapStatus.checking;
  GroupFailure? _failure;
  bool _isDisposed = false;

  GroupBootstrapStatus get status => _status;
  GroupFailure? get failure => _failure;

  Future<void> initialize({required String userId}) async {
    _status = GroupBootstrapStatus.checking;
    _failure = null;
    _notify();

    try {
      final groupId = await _groupSession.rememberedGroupId(userId: userId);
      if (groupId == null) {
        _status = GroupBootstrapStatus.gateway;
        return;
      }

      final group = await _repository.getUserGroup(
        userId: userId,
        groupId: groupId,
      );
      if (group == null) {
        await _groupSession.clear();
        _status = GroupBootstrapStatus.gateway;
        return;
      }

      _groupSession.restoreMembership(group);
      _status = GroupBootstrapStatus.home;
    } on GroupFailure catch (failure) {
      _groupSession.clearActiveGroup();
      _failure = failure;
      _status = GroupBootstrapStatus.gateway;
    } catch (error) {
      _groupSession.clearActiveGroup();
      _failure = GroupFailure(GroupFailureCode.groupsLoadFailed, error);
      _status = GroupBootstrapStatus.gateway;
    } finally {
      _notify();
    }
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
