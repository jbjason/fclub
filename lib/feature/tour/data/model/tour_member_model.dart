import 'package:hive_flutter/hive_flutter.dart';

part 'tour_member_model.g.dart';

@HiveType(typeId: 10)
class TourMemberModel extends HiveObject {
  TourMemberModel({
    required this.id,
    required this.name,
    required this.avatarColorIndex,
    required this.paidToManager,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int avatarColorIndex;

  @HiveField(3)
  double paidToManager;
}
