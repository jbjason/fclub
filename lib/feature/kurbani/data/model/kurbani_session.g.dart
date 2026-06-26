// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurbani_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KurbaniSessionAdapter extends TypeAdapter<KurbaniSession> {
  @override
  final int typeId = 24;

  @override
  KurbaniSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KurbaniSession(
      id: fields[0] as String,
      groupName: fields[1] as String,
      budgetPerMember: fields[2] as double,
      createdAt: fields[3] as DateTime,
      members: (fields[5] as List).cast<KurbaniMemberModel>(),
      expenses: (fields[6] as List).cast<KurbaniExpenseModel>(),
      animalParts: (fields[7] as List).cast<KurbaniAnimalPartModel>(),
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, KurbaniSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.budgetPerMember)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.members)
      ..writeByte(6)
      ..write(obj.expenses)
      ..writeByte(7)
      ..write(obj.animalParts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KurbaniSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
