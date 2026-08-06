import 'package:fclub/feature/home/data/datasources/group_selection_local_data_source.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:flutter/foundation.dart';

class ActiveGroup {
  const ActiveGroup({required this.id, required this.name});

  final String id;
  final String name;
}

class GroupSessionProvider with ChangeNotifier {
  GroupSessionProvider({required GroupSelectionLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final GroupSelectionLocalDataSource _localDataSource;
  ActiveGroup? _activeGroup;

  ActiveGroup? get activeGroup => _activeGroup;
  String? get groupId => _activeGroup?.id;

  Future<String?> rememberedGroupId({required String userId}) {
    return _localDataSource.readGroupId(userId: userId);
  }

  Future<void> activateJoined({
    required JoinedGroup group,
    required String userId,
  }) async {
    _setActiveGroup(ActiveGroup(id: group.id, name: group.name));
    await _remember(userId: userId, groupId: group.id);
  }

  Future<void> activateCreated({
    required CreatedGroup group,
    required String userId,
  }) async {
    _setActiveGroup(ActiveGroup(id: group.id, name: group.name));
    await _remember(userId: userId, groupId: group.id);
  }

  Future<void> activateMembership({
    required UserGroup group,
    required String userId,
  }) async {
    _setActiveGroup(ActiveGroup(id: group.id, name: group.name));
    await _remember(userId: userId, groupId: group.id);
  }

  void restoreMembership(UserGroup group) {
    _setActiveGroup(ActiveGroup(id: group.id, name: group.name));
  }

  void clearActiveGroup() => _setActiveGroup(null);

  Future<void> clear() async {
    clearActiveGroup();
    await _localDataSource.clear();
  }

  Future<void> _remember({required String userId, required String groupId}) {
    return _localDataSource.saveGroupId(userId: userId, groupId: groupId);
  }

  void _setActiveGroup(ActiveGroup? group) {
    if (_activeGroup?.id == group?.id && _activeGroup?.name == group?.name) {
      return;
    }
    _activeGroup = group;
    notifyListeners();
  }
}
