import 'package:hive_flutter/hive_flutter.dart';

import 'pack_item.dart';

part 'pack_session.g.dart';

/// A named carry session — represents one "outing" with its own item list.
@HiveType(typeId: 31)
class PackSession {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  /// Full item catalog for this session; includes packed and unpacked items.
  @HiveField(3)
  List<PackItem> items;

  /// True after all packed items have been verified on return.
  @HiveField(4)
  bool isCompleted;

  PackSession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.items,
    this.isCompleted = false,
  });

  /// Number of items the user marked as packed.
  int get packedCount => items.where((i) => i.isPacked).length;

  /// Number of packed items confirmed on the return check.
  int get checkedBackCount =>
      items.where((i) => i.isPacked && i.isCheckedBack).length;

  /// True when every packed item has been verified.
  bool get allCheckedBack =>
      packedCount > 0 && packedCount == checkedBackCount;
}
