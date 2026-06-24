import 'package:fclub/feature/kurbani/data/model/kurbani_member_balance.dart';

class KurbaniSummary {
  const KurbaniSummary({
    required this.budgetPerMember,
    required this.totalBudget,
    required this.totalCollected,
    required this.totalSpent,
    required this.memberBalances,
  });

  /// Agreed fixed budget per person.
  final double budgetPerMember;

  /// budgetPerMember × memberCount.
  final double totalBudget;

  /// Sum of all member contributions to the pool.
  final double totalCollected;

  /// Sum of all expenses paid (from pool or pocket).
  final double totalSpent;

  final List<KurbaniMemberBalance> memberBalances;

  /// Positive = pool surplus. Negative = pool deficit.
  double get balance => totalCollected - totalSpent;

  bool get isDeficit => balance < -0.01;
  bool get isSurplus => balance > 0.01;

  double get spendingProgress =>
      totalBudget <= 0 ? 0 : (totalSpent / totalBudget).clamp(0.0, 1.0);

  /// How much each member needs to add (deficit) or receives back (surplus).
  double get perMemberAdjustment {
    final count = memberBalances.length;
    if (count == 0) return 0;
    return balance.abs() / count;
  }
}
