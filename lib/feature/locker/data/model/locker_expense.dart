import 'package:hive_flutter/hive_flutter.dart';

part 'locker_expense.g.dart';

/// One cash-out record against the locker's balance.
@HiveType(typeId: 60)
class LockerExpense {
  LockerExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.note,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? note;
}
