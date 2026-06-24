import 'package:hive_flutter/hive_flutter.dart';

part 'kurbani_animal_part_model.g.dart';

@HiveType(typeId: 22)
class KurbaniAnimalPartModel extends HiveObject {
  KurbaniAnimalPartModel({
    required this.id,
    required this.partName,
    required this.weightKg,
    required this.timestamp,
    this.note,
  });

  @HiveField(0)
  String id;

  /// e.g. "Meat", "Bone", "Liver", "Ribs", "Offal", "Head", "Feet"
  @HiveField(1)
  String partName;

  @HiveField(2)
  double weightKg;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? note;
}
