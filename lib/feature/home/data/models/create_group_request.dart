import 'package:fclub/feature/home/data/models/group_user.dart';

class CreateGroupRequest {
  const CreateGroupRequest({
    required this.name,
    required this.pinCode,
    required this.creator,
    required this.members,
  });

  final String name;
  final String pinCode;
  final GroupUser creator;
  final List<GroupUser> members;
}
