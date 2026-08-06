import 'package:fclub/feature/home/data/group_session_hive_box.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract interface class GroupSelectionLocalDataSource {
  Future<String?> readGroupId({required String userId});

  Future<void> saveGroupId({required String userId, required String groupId});

  Future<void> clear();
}

class HiveGroupSelectionLocalDataSource
    implements GroupSelectionLocalDataSource {
  static const String _selectionKey = 'active_group';
  static const String _userIdKey = 'userId';
  static const String _groupIdKey = 'groupId';

  Box<dynamic> get _box => Hive.box<dynamic>(GroupSessionHiveBox.boxName);

  @override
  Future<String?> readGroupId({required String userId}) async {
    final value = _box.get(_selectionKey);
    if (value is! Map) return null;

    final selection = Map<String, dynamic>.from(value);
    final savedUserId = selection[_userIdKey];
    final savedGroupId = selection[_groupIdKey];
    if (savedUserId != userId || savedGroupId is! String) {
      await clear();
      return null;
    }

    final normalizedGroupId = savedGroupId.trim();
    return normalizedGroupId.isEmpty ? null : normalizedGroupId;
  }

  @override
  Future<void> saveGroupId({
    required String userId,
    required String groupId,
  }) async {
    await _box.put(_selectionKey, {_userIdKey: userId, _groupIdKey: groupId});
  }

  @override
  Future<void> clear() => _box.delete(_selectionKey);
}
