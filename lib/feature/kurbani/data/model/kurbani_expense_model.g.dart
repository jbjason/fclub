// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kurbani_expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KurbaniExpenseModelAdapter extends TypeAdapter<KurbaniExpenseModel> {
  @override
  final int typeId = 21;

  @override
  KurbaniExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KurbaniExpenseModel(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      paidByMemberId: fields[3] as String,
      timestamp: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KurbaniExpenseModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paidByMemberId)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KurbaniExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
