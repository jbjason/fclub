import 'package:fclub/feature/tour/data/model/tour_expense_model.dart';
import 'package:fclub/feature/tour/data/model/tour_member_model.dart';
import 'package:fclub/feature/tour/data/tour_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an expense paid by all members credits each payer equally', () {
    final members = [
      TourMemberModel(
        id: 'a',
        name: 'A',
        avatarColorIndex: 0,
        paidToManager: 0,
      ),
      TourMemberModel(
        id: 'b',
        name: 'B',
        avatarColorIndex: 1,
        paidToManager: 0,
      ),
    ];
    final expense = TourExpenseModel(
      id: 'shared-expense',
      title: 'Shared work',
      amount: 100,
      paidByMemberId: null,
      paidByAllMembers: true,
      beneficiaryMemberIds: ['a'],
      categoryIndex: 0,
      timestamp: DateTime(2026),
    );

    final summary = TourCalculator.calculate(
      members: members,
      expenses: [expense],
      extraPayments: const [],
      totalDecidedBudget: 0,
    );

    expect(summary.memberBalances.first.totalSpentOnOthers, 50);
    expect(summary.memberBalances.last.totalSpentOnOthers, 50);
    expect(summary.memberBalances.first.netBalance, -50);
    expect(summary.memberBalances.last.netBalance, 50);
  });
}
