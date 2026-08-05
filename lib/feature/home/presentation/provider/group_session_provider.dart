import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:flutter/foundation.dart';

class ActiveGroup {
  const ActiveGroup({required this.id, required this.name});

  final String id;
  final String name;
}

/// Keeps the group chosen at the gateway available to group-scoped features.
/// Authentication still returns to the gateway after a fresh app launch, so
/// this state intentionally lives only for the current signed-in session.
class GroupSessionProvider with ChangeNotifier {
  ActiveGroup? _activeGroup;

  ActiveGroup? get activeGroup => _activeGroup;
  String? get groupId => _activeGroup?.id;

  void activateJoined(JoinedGroup group) {
    _setActiveGroup(ActiveGroup(id: group.id, name: group.name));
  }

  void activateCreated(CreatedGroup group) {
    _setActiveGroup(ActiveGroup(id: group.id, name: group.name));
  }

  void clear() => _setActiveGroup(null);

  void _setActiveGroup(ActiveGroup? group) {
    if (_activeGroup?.id == group?.id && _activeGroup?.name == group?.name) {
      return;
    }
    _activeGroup = group;
    notifyListeners();
  }
}
