import 'package:fclub/feature/club/data/model/payment_status.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'payment_entry.g.dart';

/// One member's monthly contribution record.
///
/// Members are not modeled here — [contactId] references the shared
/// [AppContact] pool (`core/services/contacts`) so club members, Tour
/// members, and Kurbani members all resolve back to the same person.
@HiveType(typeId: 50)
class PaymentEntry {
  PaymentEntry({
    required this.id,
    required this.contactId,
    required this.month,
    required this.amount,
    required this.statusIndex,
    required this.date,
    this.note,
  });

  @HiveField(0)
  final String id;

  /// References `AppContact.id`.
  @HiveField(1)
  String contactId;

  /// The billing month this entry covers, normalized to the 1st.
  @HiveField(2)
  DateTime month;

  @HiveField(3)
  double amount;

  @HiveField(4)
  int statusIndex;

  /// The date the entry was recorded/paid.
  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? note;

  PaymentStatus get status => PaymentStatus.values[statusIndex];
}
