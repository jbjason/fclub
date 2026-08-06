import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:flutter/foundation.dart';

class UserGroupsProvider with ChangeNotifier {
  UserGroupsProvider(this._repository);

  final GroupRepository _repository;

  List<UserGroup> _groups = const [];
  bool _isLoading = false;
  String? _selectingGroupId;
  GroupFailure? _loadFailure;
  GroupFailure? _selectionFailure;
  bool _isDisposed = false;

  List<UserGroup> get groups => List.unmodifiable(_groups);
  bool get isLoading => _isLoading;
  String? get selectingGroupId => _selectingGroupId;
  GroupFailure? get loadFailure => _loadFailure;
  GroupFailure? get selectionFailure => _selectionFailure;

  Future<void> load({required String userId}) async {
    if (_isLoading) return;
    _isLoading = true;
    _loadFailure = null;
    _notify();

    try {
      _groups = await _repository.getUserGroups(userId: userId);
    } on GroupFailure catch (failure) {
      _loadFailure = failure;
    } catch (error) {
      _loadFailure = GroupFailure(GroupFailureCode.groupsLoadFailed, error);
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  Future<UserGroup?> select({
    required String userId,
    required String groupId,
  }) async {
    if (_selectingGroupId != null) return null;
    _selectingGroupId = groupId;
    _selectionFailure = null;
    _notify();

    try {
      final group = await _repository.getUserGroup(
        userId: userId,
        groupId: groupId,
      );
      if (group == null) {
        _groups = _groups
            .where((candidate) => candidate.id != groupId)
            .toList(growable: false);
        _selectionFailure = const GroupFailure(GroupFailureCode.groupNotFound);
      }
      return group;
    } on GroupFailure catch (failure) {
      _selectionFailure = failure;
      return null;
    } catch (error) {
      _selectionFailure = GroupFailure(
        GroupFailureCode.groupsLoadFailed,
        error,
      );
      return null;
    } finally {
      _selectingGroupId = null;
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
