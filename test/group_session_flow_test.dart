import 'package:fclub/feature/home/data/datasources/group_selection_local_data_source.dart';
import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_bootstrap_provider.dart';
import 'package:fclub/feature/home/presentation/provider/group_session_provider.dart';
import 'package:fclub/feature/home/presentation/provider/user_groups_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const membership = UserGroup(
    id: 'group-1',
    name: 'Aurora Circle',
    isAdmin: true,
  );

  test('activating and clearing a group updates the local selection', () async {
    final local = _MemoryGroupSelection();
    final session = GroupSessionProvider(localDataSource: local);

    await session.activateMembership(group: membership, userId: 'user-1');

    expect(session.groupId, 'group-1');
    expect(local.userId, 'user-1');
    expect(local.groupId, 'group-1');

    await session.clear();

    expect(session.groupId, isNull);
    expect(local.groupId, isNull);
  });

  test('bootstrap restores a valid remembered membership', () async {
    final local = _MemoryGroupSelection(
      initialUserId: 'user-1',
      initialGroupId: 'group-1',
    );
    final session = GroupSessionProvider(localDataSource: local);
    final repository = _MembershipRepository(membership: membership);
    final provider = GroupBootstrapProvider(
      repository: repository,
      groupSession: session,
    );

    await provider.initialize(userId: 'user-1');

    expect(provider.status, GroupBootstrapStatus.home);
    expect(session.groupId, 'group-1');
    expect(repository.validatedGroupId, 'group-1');
    expect(repository.validatedUserId, 'user-1');
  });

  test(
    'bootstrap clears a remembered group after membership removal',
    () async {
      final local = _MemoryGroupSelection(
        initialUserId: 'user-1',
        initialGroupId: 'removed-group',
      );
      final session = GroupSessionProvider(localDataSource: local);
      final provider = GroupBootstrapProvider(
        repository: _MembershipRepository(),
        groupSession: session,
      );

      await provider.initialize(userId: 'user-1');

      expect(provider.status, GroupBootstrapStatus.gateway);
      expect(session.groupId, isNull);
      expect(local.groupId, isNull);
    },
  );

  test('group list loads and revalidates the selected membership', () async {
    final repository = _MembershipRepository(
      membership: membership,
      memberships: const [membership],
    );
    final provider = UserGroupsProvider(repository);

    await provider.load(userId: 'user-1');
    final selected = await provider.select(
      userId: 'user-1',
      groupId: 'group-1',
    );

    expect(provider.groups, const [membership]);
    expect(selected, membership);
    expect(repository.validatedGroupId, 'group-1');
  });
}

class _MemoryGroupSelection implements GroupSelectionLocalDataSource {
  _MemoryGroupSelection({String? initialUserId, String? initialGroupId})
    : userId = initialUserId,
      groupId = initialGroupId;

  String? userId;
  String? groupId;

  @override
  Future<void> clear() async {
    userId = null;
    groupId = null;
  }

  @override
  Future<String?> readGroupId({required String userId}) async {
    if (this.userId != userId) return null;
    return groupId;
  }

  @override
  Future<void> saveGroupId({
    required String userId,
    required String groupId,
  }) async {
    this.userId = userId;
    this.groupId = groupId;
  }
}

class _MembershipRepository implements GroupRepository {
  _MembershipRepository({this.membership, this.memberships = const []});

  final UserGroup? membership;
  final List<UserGroup> memberships;
  String? validatedGroupId;
  String? validatedUserId;

  @override
  Future<UserGroup?> getUserGroup({
    required String userId,
    required String groupId,
  }) async {
    validatedUserId = userId;
    validatedGroupId = groupId;
    return membership?.id == groupId ? membership : null;
  }

  @override
  Future<List<UserGroup>> getUserGroups({required String userId}) async {
    return memberships;
  }

  @override
  Future<CreatedGroup> createGroup(CreateGroupRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<GroupUser>> getUsers() {
    throw UnimplementedError();
  }

  @override
  Future<JoinedGroup> joinGroup({
    required String pinCode,
    required GroupUser user,
  }) {
    throw UnimplementedError();
  }
}
