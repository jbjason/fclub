// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TourSessionAdapter extends TypeAdapter<TourSession> {
  @override
  final int typeId = 13;

  @override
  TourSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TourSession(
      id: fields[0] as String,
      tourName: fields[1] as String,
      decidedBudget: fields[2] as double,
      createdAt: fields[3] as DateTime,
      members: (fields[5] as List).cast<TourMemberModel>(),
      expenses: (fields[6] as List).cast<TourExpenseModel>(),
      extraPayments: (fields[7] as List).cast<ExtraPaymentModel>(),
      isCompleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TourSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tourName)
      ..writeByte(2)
      ..write(obj.decidedBudget)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.members)
      ..writeByte(6)
      ..write(obj.expenses)
      ..writeByte(7)
      ..write(obj.extraPayments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TourSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
