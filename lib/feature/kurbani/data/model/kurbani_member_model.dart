import 'package:hive_flutter/hive_flutter.dart';

part 'kurbani_member_model.g.dart';

@HiveType(typeId: 20)
class KurbaniMemberModel extends HiveObject {
  KurbaniMemberModel({
    required this.id,
    required this.name,
    required this.avatarColorIndex,
    required this.contribution,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  /// Index into the avatar gradient palette.
  @HiveField(2)
  int avatarColorIndex;

  /// Amount this member has paid into the shared pool.
  @HiveField(3)
  double contribution;
}
