// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurbani_animal_part_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KurbaniAnimalPartModelAdapter
    extends TypeAdapter<KurbaniAnimalPartModel> {
  @override
  final int typeId = 22;

  @override
  KurbaniAnimalPartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KurbaniAnimalPartModel(
      id: fields[0] as String,
      partName: fields[1] as String,
      weightKg: fields[2] as double,
      timestamp: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KurbaniAnimalPartModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.partName)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KurbaniAnimalPartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
