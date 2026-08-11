import 'package:fclub/feature/tour/data/models/tour_expense.dart';
import 'package:fclub/feature/tour/data/models/tour_participant.dart';
import 'package:fclub/feature/tour/data/services/tour_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a revised budget is divided equally among all participants', () {
    expect(
      TourCalculator.equalContribution(totalBudget: 6000, participantCount: 4),
      1500,
    );
  });

  test('an expense paid by all participants credits each payer equally', () {
    final participants = [
      TourParticipant(
        id: 'a',
        username: 'A',
        email: 'a@example.com',
        profilePic: '',
        avatarColorIndex: 0,
        paidToManager: 0,
        joinedAt: DateTime(2026),
      ),
      TourParticipant(
        id: 'b',
        username: 'B',
        email: 'b@example.com',
        profilePic: '',
        avatarColorIndex: 1,
        paidToManager: 0,
        joinedAt: DateTime(2026),
      ),
    ];
    final expense = TourExpense(
      id: 'shared-expense',
      title: 'Shared work',
      amount: 100,
      category: TourExpenseCategory.misc,
      paidByMemberId: null,
      paidByAllMembers: true,
      beneficiaryMemberIds: const ['a'],
      note: null,
      createdBy: 'a',
      createdAt: DateTime(2026),
    );

    final summary = TourCalculator.calculate(
      participants: participants,
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
