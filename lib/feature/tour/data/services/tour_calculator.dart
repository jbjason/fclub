import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_extra_payment.dart';
import 'package:fclub/feature/tour/data/models/tour_member_balance.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/data/models/tour_summary.dart';

abstract final class TourCalculator {
  static double equalContribution({
    required double totalBudget,
    required int participantCount,
  }) => participantCount <= 0 ? 0 : totalBudget / participantCount;

  static TourSummary calculate({
    required List<TourParticipant> participants,
    required List<TourExpense> expenses,
    required List<TourExtraPayment> extraPayments,
    required double totalDecidedBudget,
  }) {
    final extraByMember = <String, double>{};
    for (final payment in extraPayments) {
      extraByMember.update(
        payment.memberId,
        (amount) => amount + payment.amount,
        ifAbsent: () => payment.amount,
      );
    }

    final spentOnOthersByMember = <String, double>{};
    final consumedByMember = <String, double>{};
    for (final expense in expenses) {
      final payerIds = expense.paidByAllMembers
          ? participants.map((participant) => participant.id).toList()
          : [expense.paidByMemberId].whereType<String>().toList();
      if (payerIds.isNotEmpty) {
        final amountPerPayer = expense.amount / payerIds.length;
        for (final payerId in payerIds) {
          spentOnOthersByMember.update(
            payerId,
            (amount) => amount + amountPerPayer,
            ifAbsent: () => amountPerPayer,
          );
        }
      }

      final beneficiaryIds = expense.beneficiaryMemberIds.isEmpty
          ? participants.map((participant) => participant.id).toList()
          : expense.beneficiaryMemberIds;
      if (beneficiaryIds.isEmpty) continue;
      final share = expense.amount / beneficiaryIds.length;
      for (final memberId in beneficiaryIds) {
        consumedByMember.update(
          memberId,
          (amount) => amount + share,
          ifAbsent: () => share,
        );
      }
    }

    final balances = participants
        .map(
          (participant) => TourMemberBalance(
            memberId: participant.id,
            totalPaidToManager:
                participant.paidToManager +
                (extraByMember[participant.id] ?? 0),
            totalSpentOnOthers: spentOnOthersByMember[participant.id] ?? 0,
            totalConsumedByThem: consumedByMember[participant.id] ?? 0,
          ),
        )
        .toList(growable: false);

    return TourSummary(
      totalCollected:
          participants.fold<double>(
            0,
            (total, participant) => total + participant.paidToManager,
          ) +
          extraPayments.fold<double>(
            0,
            (total, payment) => total + payment.amount,
          ),
      totalSpent: expenses.fold<double>(
        0,
        (total, expense) => total + expense.amount,
      ),
      totalDecidedBudget: totalDecidedBudget,
      memberBalances: balances,
    );
  }
}
