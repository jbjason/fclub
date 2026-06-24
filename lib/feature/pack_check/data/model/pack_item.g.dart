// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PackItemAdapter extends TypeAdapter<PackItem> {
  @override
  final int typeId = 30;

  @override
  PackItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PackItem(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
      imagePath: fields[3] as String?,
      isCustom: fields[4] as bool,
      isPacked: fields[5] as bool,
      isCheckedBack: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PackItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.isCustom)
      ..writeByte(5)
      ..write(obj.isPacked)
      ..writeByte(6)
      ..write(obj.isCheckedBack);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PackItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
