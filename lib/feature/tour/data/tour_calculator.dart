import 'package:fclub/feature/tour/data/model/extra_payment_model.dart';
import 'package:fclub/feature/tour/data/model/member_balance.dart';
import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/data/model/tour_summary.dart';

abstract class TourCalculator {
  static TourSummary calculate({
    required List<TourMemberModel> members,
    required List<TourExpenseModel> expenses,
    required List<ExtraPaymentModel> extraPayments,
    required double totalDecidedBudget,
  }) {
    final extraByMember = <String, double>{};
    for (final payment in extraPayments) {
      extraByMember[payment.memberId] =
          (extraByMember[payment.memberId] ?? 0) + payment.amount;
    }

    final spentOnOthersByMember = <String, double>{};
    final consumedByMember = <String, double>{};
    for (final expense in expenses) {
      spentOnOthersByMember[expense.paidByMemberId] =
          (spentOnOthersByMember[expense.paidByMemberId] ?? 0) +
          expense.amount;

      final beneficiaries = expense.beneficiaryMemberIds.isEmpty
          ? members.map((member) => member.id).toList()
          : expense.beneficiaryMemberIds;
      if (beneficiaries.isEmpty) continue;

      final shareEach = expense.amount / beneficiaries.length;
      for (final memberId in beneficiaries) {
        consumedByMember[memberId] =
            (consumedByMember[memberId] ?? 0) + shareEach;
      }
    }

    final memberBalances = members.map((member) {
      return MemberBalance(
        memberId: member.id,
        totalPaidToManager: member.paidToManager + (extraByMember[member.id] ?? 0),
        totalSpentOnOthers: spentOnOthersByMember[member.id] ?? 0,
        totalConsumedByThem: consumedByMember[member.id] ?? 0,
      );
    }).toList();

    final totalCollected = members.fold<double>(
      0,
      (sum, member) => sum + member.paidToManager,
    ) + extraPayments.fold<double>(0, (sum, payment) => sum + payment.amount);

    final totalSpent = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return TourSummary(
      totalCollected: totalCollected,
      totalSpent: totalSpent,
      totalDecidedBudget: totalDecidedBudget,
      memberBalances: memberBalances,
    );
  }
}
