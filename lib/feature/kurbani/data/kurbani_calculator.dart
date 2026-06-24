import 'package:fclub/feature/kurbani/data/model/kurbani_expense_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_balance.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_member_model.dart';
import 'package:fclub/feature/kurbani/data/model/kurbani_summary.dart';

abstract class KurbaniCalculator {
  /// Calculates each member's fair share and net settlement amount.
  ///
  /// Logic:
  ///   fair share per member = totalSpent / memberCount
  ///   member credit         = contribution (pool) + expensesPaidFromPocket
  ///   net                   = credit − fairShare
  ///     positive → pool owes them (refund / reimbursement)
  ///     negative → they still owe the pool
  static KurbaniSummary calculate({
    required List<KurbaniMemberModel> members,
    required List<KurbaniExpenseModel> expenses,
    required double budgetPerMember,
  }) {
    final memberCount = members.length;
    final totalSpent = expenses.fold<double>(0, (s, e) => s + e.amount);
    final totalCollected =
        members.fold<double>(0, (s, m) => s + m.contribution);
    final totalBudget = budgetPerMember * memberCount;
    final fairShare = memberCount > 0 ? totalSpent / memberCount : 0.0;

    final paidByMember = <String, double>{};
    for (final expense in expenses) {
      paidByMember[expense.paidByMemberId] =
          (paidByMember[expense.paidByMemberId] ?? 0) + expense.amount;
    }

    final memberBalances = members.map((m) {
      return KurbaniMemberBalance(
        memberId: m.id,
        memberName: m.name,
        avatarColorIndex: m.avatarColorIndex,
        contributed: m.contribution,
        paidExpenses: paidByMember[m.id] ?? 0.0,
        fairShare: fairShare,
      );
    }).toList();

    return KurbaniSummary(
      budgetPerMember: budgetPerMember,
      totalBudget: totalBudget,
      totalCollected: totalCollected,
      totalSpent: totalSpent,
      memberBalances: memberBalances,
    );
  }
}
