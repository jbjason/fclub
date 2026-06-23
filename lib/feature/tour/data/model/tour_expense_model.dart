import 'package:hive_flutter/hive_flutter.dart';

part 'tour_expense_model.g.dart';

@HiveType(typeId: 11)
class TourExpenseModel extends HiveObject {
  TourExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidByMemberId,
    required this.beneficiaryMemberIds,
    required this.categoryIndex,
    required this.timestamp,
    this.note,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String paidByMemberId;

  /// Empty means "all members benefited".
  @HiveField(4)
  List<String> beneficiaryMemberIds;

  @HiveField(5)
  int categoryIndex;

  @HiveField(6)
  DateTime timestamp;

  @HiveField(7)
  String? note;
}
