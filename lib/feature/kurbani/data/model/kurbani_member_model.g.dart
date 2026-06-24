// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurbani_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KurbaniMemberModelAdapter extends TypeAdapter<KurbaniMemberModel> {
  @override
  final int typeId = 20;

  @override
  KurbaniMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KurbaniMemberModel(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarColorIndex: fields[2] as int,
      contribution: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, KurbaniMemberModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarColorIndex)
      ..writeByte(3)
      ..write(obj.contribution);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KurbaniMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
