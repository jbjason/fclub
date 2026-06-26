// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurbani_global_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KurbaniGlobalContactAdapter extends TypeAdapter<KurbaniGlobalContact> {
  @override
  final int typeId = 23;

  @override
  KurbaniGlobalContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KurbaniGlobalContact(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarColorIndex: fields[2] as int,
      isMe: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, KurbaniGlobalContact obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarColorIndex)
      ..writeByte(3)
      ..write(obj.isMe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KurbaniGlobalContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
