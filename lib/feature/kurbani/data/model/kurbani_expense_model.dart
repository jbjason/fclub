import 'package:hive_flutter/hive_flutter.dart';

part 'kurbani_expense_model.g.dart';

@HiveType(typeId: 21)
class KurbaniExpenseModel extends HiveObject {
  KurbaniExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidByMemberId,
    required this.timestamp,
    this.note,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  /// The member who paid this expense directly from their own pocket.
  @HiveField(3)
  String paidByMemberId;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String? note;
}
