import 'package:hive_flutter/hive_flutter.dart';

part 'app_contact.g.dart';

/// A person in the shared contacts pool — reused across features (Tour,
/// Kurbani, ...) wherever a "choose member" picker is needed.
@HiveType(typeId: 40)
class AppContact {
  AppContact({
    required this.id,
    required this.name,
    required this.avatarColorIndex,
    this.isMe = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// Index into an avatar color palette.
  @HiveField(2)
  int avatarColorIndex;

  /// True for the current app user ("Me" — always selected as creator).
  @HiveField(3)
  bool isMe;
}
