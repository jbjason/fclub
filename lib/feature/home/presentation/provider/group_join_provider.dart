import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:flutter/foundation.dart';

class GroupJoinProvider with ChangeNotifier {
  GroupJoinProvider(this._repository);

  final GroupRepository _repository;

  bool _isJoining = false;
  bool _isDisposed = false;
  GroupFailure? _failure;

  bool get isJoining => _isJoining;
  GroupFailure? get failure => _failure;

  Future<JoinedGroup?> join({
    required String pinCode,
    required GroupUser user,
  }) async {
    if (_isJoining) return null;
    _isJoining = true;
    _failure = null;
    _notify();

    try {
      return await _repository.joinGroup(pinCode: pinCode, user: user);
    } on GroupFailure catch (failure) {
      _failure = failure;
      return null;
    } catch (error) {
      _failure = GroupFailure(GroupFailureCode.unknown, error);
      return null;
    } finally {
      _isJoining = false;
      _notify();
    }
  }

  void clearFailure() {
    if (_failure == null) return;
    _failure = null;
    _notify();
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
