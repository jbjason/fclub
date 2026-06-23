// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtraPaymentModelAdapter extends TypeAdapter<ExtraPaymentModel> {
  @override
  final int typeId = 12;

  @override
  ExtraPaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtraPaymentModel(
      id: fields[0] as String,
      memberId: fields[1] as String,
      amount: fields[2] as double,
      timestamp: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExtraPaymentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.amount)
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
      other is ExtraPaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
