import 'package:fclub/feature/home/data/models/create_group_request.dart';
import 'package:fclub/feature/home/data/models/created_group.dart';
import 'package:fclub/feature/home/data/models/group_user.dart';
import 'package:fclub/feature/home/data/models/joined_group.dart';

abstract interface class GroupRepository {
  Future<List<GroupUser>> getUsers();

  Future<CreatedGroup> createGroup(CreateGroupRequest request);

  Future<JoinedGroup> joinGroup({
    required String pinCode,
    required GroupUser user,
  });
}
