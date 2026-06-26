import 'package:fclub/feature/tour/data/model/extra_payment_model.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'tour_session.g.dart';

/// One tour trip — stores all members, expenses and extra payments for that
/// trip in a self-contained record so the full history remains browsable.
@HiveType(typeId: 13)
class TourSession {
  TourSession({
    required this.id,
    required this.tourName,
    required this.decidedBudget,
    required this.createdAt,
    required this.members,
    required this.expenses,
    required this.extraPayments,
    this.isCompleted = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  String tourName;

  @HiveField(2)
  double decidedBudget;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  bool isCompleted;

  /// Participants — embedded copies (not live box entries).
  @HiveField(5)
  List<TourMemberModel> members;

  @HiveField(6)
  List<TourExpenseModel> expenses;

  @HiveField(7)
  List<ExtraPaymentModel> extraPayments;

  // ── Computed helpers ──────────────────────────────────────────────────────

  double get totalSpent =>
      expenses.fold<double>(0, (s, e) => s + e.amount);

  double get totalCollected =>
      members.fold<double>(0, (s, m) => s + m.paidToManager) +
      extraPayments.fold<double>(0, (s, p) => s + p.amount);
}
