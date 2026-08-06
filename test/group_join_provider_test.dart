import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_failure.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';
import 'package:fclub/feature/home/data/models/user_group.dart';
import 'package:fclub/feature/home/data/repositories/group_repository.dart';
import 'package:fclub/feature/home/presentation/provider/group_join_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const user = GroupUser(
    id: 'user-id',
    username: 'Aurora Member',
    profilePic: '',
    email: 'member@fundora.app',
  );

  test('returns the joined group from the repository', () async {
    final repository = _JoinFakeRepository();
    final provider = GroupJoinProvider(repository);

    final result = await provider.join(pinCode: 'A7KD-92Q', user: user);

    expect(result?.id, 'group-id');
    expect(result?.alreadyMember, isFalse);
    expect(repository.receivedPin, 'A7KD-92Q');
    expect(repository.receivedUser?.email, 'member@fundora.app');
    expect(provider.failure, isNull);

    provider.dispose();
  });

  test('surfaces a missing-group failure', () async {
    final repository = _JoinFakeRepository(
      failure: const GroupFailure(GroupFailureCode.groupNotFound),
    );
    final provider = GroupJoinProvider(repository);

    final result = await provider.join(pinCode: 'WRONG-1', user: user);

    expect(result, isNull);
    expect(provider.failure?.code, GroupFailureCode.groupNotFound);
    expect(provider.isJoining, isFalse);

    provider.dispose();
  });
}

class _JoinFakeRepository implements GroupRepository {
  _JoinFakeRepository({this.failure});

  final GroupFailure? failure;
  String? receivedPin;
  GroupUser? receivedUser;

  @override
  Future<JoinedGroup> joinGroup({
    required String pinCode,
    required GroupUser user,
  }) async {
    receivedPin = pinCode;
    receivedUser = user;
    if (failure != null) throw failure!;
    return const JoinedGroup(
      id: 'group-id',
      name: 'Aurora Circle',
      pinCode: 'A7KD-92Q',
      alreadyMember: false,
    );
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
  Future<UserGroup?> getUserGroup({
    required String userId,
    required String groupId,
  }) async => null;

  @override
  Future<List<UserGroup>> getUserGroups({required String userId}) async =>
      const [];
}
