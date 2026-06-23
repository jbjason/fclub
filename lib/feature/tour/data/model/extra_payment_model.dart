import 'package:hive_flutter/hive_flutter.dart';

part 'extra_payment_model.g.dart';

@HiveType(typeId: 12)
class ExtraPaymentModel extends HiveObject {
  ExtraPaymentModel({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String memberId;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? note;
}
