// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentEntryAdapter extends TypeAdapter<PaymentEntry> {
  @override
  final int typeId = 50;

  @override
  PaymentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentEntry(
      id: fields[0] as String,
      contactId: fields[1] as String,
      month: fields[2] as DateTime,
      amount: fields[3] as double,
      statusIndex: fields[4] as int,
      date: fields[5] as DateTime,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactId)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.statusIndex)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
