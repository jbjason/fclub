// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppContactAdapter extends TypeAdapter<AppContact> {
  @override
  final int typeId = 40;

  @override
  AppContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppContact(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarColorIndex: fields[2] as int,
      isMe: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppContact obj) {
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
      other is AppContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
