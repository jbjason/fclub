import 'package:fclub/feature/tour/data/model/member_balance.dart';

class TourSummary {
  const TourSummary({
    required this.totalCollected,
    required this.totalSpent,
    required this.totalDecidedBudget,
    required this.memberBalances,
  });

  final double totalCollected;
  final double totalSpent;
  final double totalDecidedBudget;
  final List<MemberBalance> memberBalances;

  double get balance => totalCollected - totalSpent;

  bool get isOverBudget =>
      totalDecidedBudget > 0 && totalSpent > totalDecidedBudget;

  double get budgetProgress => totalDecidedBudget <= 0
      ? 0
      : (totalSpent / totalDecidedBudget).clamp(0, 1).toDouble();
}
