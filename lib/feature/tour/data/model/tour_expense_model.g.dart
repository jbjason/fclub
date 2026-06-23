// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TourExpenseModelAdapter extends TypeAdapter<TourExpenseModel> {
  @override
  final int typeId = 11;

  @override
  TourExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TourExpenseModel(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      paidByMemberId: fields[3] as String,
      beneficiaryMemberIds: (fields[4] as List).cast<String>(),
      categoryIndex: fields[5] as int,
      timestamp: fields[6] as DateTime,
      note: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TourExpenseModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paidByMemberId)
      ..writeByte(4)
      ..write(obj.beneficiaryMemberIds)
      ..writeByte(5)
      ..write(obj.categoryIndex)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TourExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
