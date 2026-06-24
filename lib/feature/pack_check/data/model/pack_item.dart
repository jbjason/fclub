import 'package:hive_flutter/hive_flutter.dart';

part 'pack_item.g.dart';

/// A single packable item — either from the built-in catalog or user-created.
@HiveType(typeId: 30)
class PackItem {
  /// Unique stable identifier.
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// [MaterialIcons] font codepoint. Reconstruct with
  /// `IconData(codePoint, fontFamily: 'MaterialIcons')`.
  @HiveField(2)
  final int iconCodePoint;

  /// Absolute file path to a user-captured photo; null for icon-based items.
  @HiveField(3)
  final String? imagePath;

  /// True when the item was created by the user (not a default catalog entry).
  @HiveField(4)
  final bool isCustom;

  /// User has selected this item as something they are bringing.
  @HiveField(5)
  bool isPacked;

  /// User has confirmed this item was retrieved on the return check.
  @HiveField(6)
  bool isCheckedBack;

  PackItem({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.imagePath,
    this.isCustom = false,
    this.isPacked = false,
    this.isCheckedBack = false,
  });

  PackItem copyWith({
    String? name,
    bool? isPacked,
    bool? isCheckedBack,
  }) =>
      PackItem(
        id: id,
        name: name ?? this.name,
        iconCodePoint: iconCodePoint,
        imagePath: imagePath,
        isCustom: isCustom,
        isPacked: isPacked ?? this.isPacked,
        isCheckedBack: isCheckedBack ?? this.isCheckedBack,
      );
}
