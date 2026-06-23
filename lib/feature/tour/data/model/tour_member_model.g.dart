// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TourMemberModelAdapter extends TypeAdapter<TourMemberModel> {
  @override
  final int typeId = 10;

  @override
  TourMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TourMemberModel(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarColorIndex: fields[2] as int,
      paidToManager: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TourMemberModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarColorIndex)
      ..writeByte(3)
      ..write(obj.paidToManager);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TourMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
