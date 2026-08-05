import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the canonical Firestore month key', () {
    expect(ClubProvider.monthKey(DateTime(2026, 8, 19)), '2026-08');
  });

  test('monthly summary uses a 5000 target for every member', () {
    final payments = [
      _payment(id: 'paid', amount: 5000, status: PaymentStatus.paid),
      _payment(id: 'pending', amount: 5000, status: PaymentStatus.pending),
      _payment(id: 'rejected', amount: 2500, status: PaymentStatus.rejected),
    ];

    final summary = ClubMonthSummary.calculate(
      month: DateTime(2026, 8),
      memberCount: 3,
      perMemberTarget: ClubProvider.monthlyContribution,
      payments: payments,
    );

    expect(summary.target, 15000);
    expect(summary.collected, 5000);
    expect(summary.pending, 5000);
    expect(summary.rejected, 2500);
    expect(summary.outstanding, 10000);
    expect(summary.progress, closeTo(1 / 3, .001));
  });

  test(
    'filter can clear fields without changing the other API constraints',
    () {
      const initial = ClubPaymentFilter(
        userId: 'member-1',
        month: '2026-08',
        status: PaymentStatus.pending,
        paymentMethod: PaymentMethod.mobileWallet,
      );

      final next = initial.copyWith(clearStatus: true, clearMonth: true);

      expect(next.userId, 'member-1');
      expect(next.month, isNull);
      expect(next.status, isNull);
      expect(next.paymentMethod, PaymentMethod.mobileWallet);
    },
  );
}

ClubPayment _payment({
  required String id,
  required double amount,
  required PaymentStatus status,
}) {
  return ClubPayment(
    id: id,
    userId: 'member-$id',
    amount: amount,
    month: '2026-08',
    status: status,
    paymentMethod: PaymentMethod.cash,
    submittedBy: 'submitter',
    submittedAt: DateTime(2026, 8, 5),
  );
}
