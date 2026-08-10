import 'package:fclub/feature/kurbani/data/models/kurbani_expense.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_member_balance.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_summary.dart';

abstract final class KurbaniCalculator {
  static KurbaniSummary calculate({
    required List<KurbaniParticipant> participants,
    required List<KurbaniExpense> expenses,
  }) {
    final totalSpent = expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
    final totalPlanned = participants.fold<double>(
      0,
      (total, participant) => total + participant.contribution,
    );
    final totalCollected = participants.fold<double>(
      0,
      (total, participant) => total + participant.collectedContribution,
    );
    final fairShare = participants.isEmpty
        ? 0.0
        : totalSpent / participants.length;
    final paidExpenses = <String, double>{};
    for (final expense in expenses) {
      paidExpenses.update(
        expense.paidByMemberId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return KurbaniSummary(
      totalPlanned: totalPlanned,
      totalCollected: totalCollected,
      totalSpent: totalSpent,
      memberBalances: participants
          .map(
            (participant) => KurbaniMemberBalance(
              memberId: participant.id,
              memberName: participant.username,
              contributed: participant.collectedContribution,
              paidExpenses: paidExpenses[participant.id] ?? 0,
              fairShare: fairShare,
            ),
          )
          .toList(growable: false),
    );
  }
}
