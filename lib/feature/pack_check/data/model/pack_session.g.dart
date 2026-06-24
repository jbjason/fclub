// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PackSessionAdapter extends TypeAdapter<PackSession> {
  @override
  final int typeId = 31;

  @override
  PackSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PackSession(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      items: (fields[3] as List).cast<PackItem>(),
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PackSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
