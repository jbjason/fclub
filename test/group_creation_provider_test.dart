import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/data/repositories/firestore_group_repository.dart';
import 'package:fclub/feature/home/presentation/group_pin_generator.dart';
import 'package:fclub/feature/home/presentation/provider/group_creation_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const signedInUser = GroupUser(
    id: 'creator-id',
    username: 'Fallback Name',
    profilePic: '',
    email: 'creator@fundora.app',
  );
  const users = [
    GroupUser(
      id: 'legacy-creator-document',
      username: 'Creator Profile',
      profilePic: 'https://example.com/creator.png',
      email: 'creator@fundora.app',
    ),
    GroupUser(
      id: 'member-1',
      username: 'Aurora Member',
      profilePic: '',
      email: 'aurora@fundora.app',
    ),
    GroupUser(
      id: 'member-2',
      username: 'Nova Member',
      profilePic: '',
      email: 'nova@fundora.app',
    ),
  ];

  test('loads users and locks the authenticated user in as creator', () async {
    final repository = _FakeGroupRepository(users: users);
    final provider = GroupCreationProvider(
      repository: repository,
      signedInUser: signedInUser,
    );

    await provider.loadUsers();

    expect(provider.creator.id, signedInUser.id);
    expect(provider.creator.username, 'Creator Profile');
    expect(provider.visibleUsers.map((user) => user.id), [
      'member-1',
      'member-2',
    ]);
    expect(provider.selectedMemberCount, 1);

    provider.dispose();
  });

  test('submits selected members with the creator profile', () async {
    final repository = _FakeGroupRepository(users: users);
    final provider = GroupCreationProvider(
      repository: repository,
      signedInUser: signedInUser,
    );
    await provider.loadUsers();
    provider.toggleUser('member-2');

    final result = await provider.submit(
      name: 'Nova Circle',
      pinCode: 'NOVA-247',
    );

    expect(result?.id, 'group-id');
    expect(repository.lastRequest?.creator.id, 'creator-id');
    expect(repository.lastRequest?.members.map((user) => user.id), [
      'member-2',
    ]);
    expect(provider.selectedMemberCount, 2);

    provider.dispose();
  });

  test('surfaces a typed creation failure', () async {
    final repository = _FakeGroupRepository(
      users: users,
      createFailure: const GroupFailure(GroupFailureCode.pinUnavailable),
    );
    final provider = GroupCreationProvider(
      repository: repository,
      signedInUser: signedInUser,
    );

    final result = await provider.submit(name: 'Nova', pinCode: 'NOVA-247');

    expect(result, isNull);
    expect(provider.submitFailure?.code, GroupFailureCode.pinUnavailable);

    provider.dispose();
  });

  test('generated PINs are readable and valid for the form', () {
    final pin = GroupPinGenerator.generate();

    expect(pin, matches(RegExp(r'^[A-HJ-NP-Z2-9]{4}-[A-HJ-NP-Z2-9]{3}$')));
  });

  test('Club project stores the creator as adminId', () {
    final createdAt = DateTime(2026, 8, 7);

    final data = FirestoreGroupRepository.createClubProjectData(
      adminId: signedInUser.id,
      createdAt: createdAt,
    );

    expect(data['id'], 'club');
    expect(data['adminId'], signedInUser.id);
    expect(data['createdAt'], createdAt);
  });

  test('group member documents do not store a role', () {
    final joinedAt = DateTime(2026, 8, 7);

    final data = FirestoreGroupRepository.createMemberData(
      member: signedInUser,
      joinedAt: joinedAt,
    );

    expect(data['id'], signedInUser.id);
    expect(data['joinedAt'], joinedAt);
    expect(data, isNot(contains('role')));
  });
}

class _FakeGroupRepository implements GroupRepository {
  _FakeGroupRepository({required this.users, this.createFailure});

  final List<GroupUser> users;
  final GroupFailure? createFailure;
  CreateGroupRequest? lastRequest;

  @override
  Future<CreatedGroup> createGroup(CreateGroupRequest request) async {
    lastRequest = request;
    if (createFailure != null) throw createFailure!;
    return CreatedGroup(
      id: 'group-id',
      name: request.name,
      pinCode: request.pinCode,
      memberCount: request.members.length + 1,
    );
  }

  @override
  Future<List<GroupUser>> getUsers() async => users;

  @override
  Future<JoinedGroup> joinGroup({
    required String pinCode,
    required GroupUser user,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserGroup?> getUserGroup({
    required String userId,
    required String groupId,
  }) async => null;

  @override
  Future<List<UserGroup>> getUserGroups({required String userId}) async =>
      const [];
}
