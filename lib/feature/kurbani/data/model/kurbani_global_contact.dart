import 'package:hive_flutter/hive_flutter.dart';

part 'kurbani_global_contact.g.dart';

/// A person in the global contacts pool — reused across multiple Kurbani years.
@HiveType(typeId: 23)
class KurbaniGlobalContact {
  KurbaniGlobalContact({
    required this.id,
    required this.name,
    required this.avatarColorIndex,
    this.isMe = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// Index into the kurbaniAvatarGradients palette.
  @HiveField(2)
  int avatarColorIndex;

  /// True for the current app user ("Me" — always selected as creator).
  @HiveField(3)
  bool isMe;
}
