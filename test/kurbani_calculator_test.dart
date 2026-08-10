import 'package:fclub/feature/kurbani/data/models/kurbani_expense.dart';
import 'package:fclub/feature/kurbani/data/models/kurbani_participant.dart';
import 'package:fclub/feature/kurbani/data/services/kurbani_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settlement counts only paid contributions and direct expenses', () {
    final participants = [
      KurbaniParticipant(
        id: 'a',
        username: 'A',
        email: 'a@example.com',
        profilePic: '',
        contribution: 1000,
        paidStatus: KurbaniPaidStatus.paid,
        joinedAt: DateTime(2026),
      ),
      KurbaniParticipant(
        id: 'b',
        username: 'B',
        email: 'b@example.com',
        profilePic: '',
        contribution: 1000,
        paidStatus: KurbaniPaidStatus.pending,
        joinedAt: DateTime(2026),
      ),
    ];
    final expenses = [
      KurbaniExpense(
        id: 'expense',
        title: 'Animal',
        amount: 600,
        paidByMemberId: 'a',
        note: null,
        createdBy: 'admin',
        createdAt: DateTime(2026),
      ),
    ];

    final summary = KurbaniCalculator.calculate(
      participants: participants,
      expenses: expenses,
    );

    expect(summary.totalPlanned, 2000);
    expect(summary.totalCollected, 1000);
    expect(summary.totalSpent, 600);
    expect(summary.balance, 400);
    expect(summary.memberBalances.first.net, 1300);
    expect(summary.memberBalances.last.net, -300);
  });
}
