import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:flutter/foundation.dart';

class GroupCreationProvider with ChangeNotifier {
  GroupCreationProvider({
    required GroupRepository repository,
    required GroupUser signedInUser,
  }) : _repository = repository,
       _signedInUser = signedInUser;

  final GroupRepository _repository;
  final GroupUser _signedInUser;

  List<GroupUser> _users = const [];
  Set<String> _selectedUserIds = <String>{};
  String _searchQuery = '';
  bool _isLoadingUsers = false;
  bool _isSubmitting = false;
  bool _isDisposed = false;
  GroupFailure? _loadFailure;
  GroupFailure? _submitFailure;

  bool get isLoadingUsers => _isLoadingUsers;
  bool get isSubmitting => _isSubmitting;
  GroupFailure? get loadFailure => _loadFailure;
  GroupFailure? get submitFailure => _submitFailure;
  int get selectedMemberCount => _selectedUserIds.length + 1;

  GroupUser get creator {
    final signedInEmail = _signedInUser.email.trim().toLowerCase();
    for (final user in _users) {
      final sameId = user.id == _signedInUser.id;
      final sameEmail =
          signedInEmail.isNotEmpty &&
          user.email.trim().toLowerCase() == signedInEmail;
      if (sameId || sameEmail) {
        return user.copyWith(id: _signedInUser.id);
      }
    }
    return _signedInUser;
  }

  List<GroupUser> get visibleUsers {
    final currentCreator = creator;
    final creatorEmail = currentCreator.email.trim().toLowerCase();
    final candidates = _users
        .where((user) {
          final isCreator =
              user.id == currentCreator.id ||
              (creatorEmail.isNotEmpty &&
                  user.email.trim().toLowerCase() == creatorEmail);
          if (isCreator) return false;

          final query = _searchQuery.trim().toLowerCase();
          return query.isEmpty ||
              user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        })
        .toList(growable: false);

    candidates.sort((first, second) {
      final firstSelected = _selectedUserIds.contains(first.id);
      final secondSelected = _selectedUserIds.contains(second.id);
      if (firstSelected != secondSelected) return firstSelected ? -1 : 1;
      return first.username.toLowerCase().compareTo(
        second.username.toLowerCase(),
      );
    });
    return candidates;
  }

  bool isSelected(String userId) => _selectedUserIds.contains(userId);

  Future<void> loadUsers() async {
    if (_isLoadingUsers) return;
    _isLoadingUsers = true;
    _loadFailure = null;
    _notify();

    try {
      _users = await _repository.getUsers();
      final validIds = _users.map((user) => user.id).toSet();
      _selectedUserIds = _selectedUserIds.intersection(validIds);
    } on GroupFailure catch (failure) {
      _loadFailure = failure;
    } catch (error) {
      _loadFailure = GroupFailure(GroupFailureCode.usersLoadFailed, error);
    } finally {
      _isLoadingUsers = false;
      _notify();
    }
  }

  void search(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _notify();
  }

  void toggleUser(String userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
    } else {
      _selectedUserIds.add(userId);
    }
    _notify();
  }

  Future<CreatedGroup?> submit({
    required String name,
    required String pinCode,
  }) async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _submitFailure = null;
    _notify();

    try {
      final selectedMembers = _users
          .where((user) => _selectedUserIds.contains(user.id))
          .toList(growable: false);
      return await _repository.createGroup(
        CreateGroupRequest(
          name: name,
          pinCode: pinCode,
          creator: creator,
          members: selectedMembers,
        ),
      );
    } on GroupFailure catch (failure) {
      _submitFailure = failure;
      return null;
    } catch (error) {
      _submitFailure = GroupFailure(GroupFailureCode.unknown, error);
      return null;
    } finally {
      _isSubmitting = false;
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
