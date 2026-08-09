import 'package:fclub/feature/club/data/model/club_month_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/provider/club_month_payment_details_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClubMonthPaymentDetailsProvider', () {
    final payments = [
      _payment(
        id: 'latest-paid',
        userId: 'member-1',
        month: '2026-08',
        status: PaymentStatus.paid,
        method: PaymentMethod.cash,
        submittedAt: DateTime(2026, 8, 9),
      ),
      _payment(
        id: 'older-pending',
        userId: 'member-2',
        month: '2026-08',
        status: PaymentStatus.pending,
        method: PaymentMethod.mobileWallet,
        submittedAt: DateTime(2026, 8, 4),
      ),
      _payment(
        id: 'other-month',
        userId: 'member-1',
        month: '2026-07',
        status: PaymentStatus.paid,
        method: PaymentMethod.cash,
        submittedAt: DateTime(2026, 7, 7),
      ),
    ];

    test('keeps only the selected month and sorts newest first', () {
      final provider = ClubMonthPaymentDetailsProvider(
        month: DateTime(2026, 8, 20),
      );

      final result = provider.monthPayments(payments);

      expect(result.map((payment) => payment.id), [
        'latest-paid',
        'older-pending',
      ]);
    });

    test('combines status, member, and payment-method filters', () {
      final provider = ClubMonthPaymentDetailsProvider(
        month: DateTime(2026, 8),
      );
      provider.applyFilter(
        const ClubMonthPaymentFilter(
          status: PaymentStatus.pending,
          userId: 'member-2',
          paymentMethod: PaymentMethod.mobileWallet,
        ),
      );

      final result = provider.filteredPayments(payments);

      expect(result.single.id, 'older-pending');
      expect(payments, hasLength(3));
    });

    test('calculates the selected month summary from the live source', () {
      final provider = ClubMonthPaymentDetailsProvider(
        month: DateTime(2026, 8),
      );

      final summary = provider.summary(
        payments: payments,
        memberCount: 2,
        perMemberTarget: 5000,
      );

      expect(summary.target, 10000);
      expect(summary.collected, 5000);
      expect(summary.pending, 5000);
      expect(summary.rejected, 0);
    });
  });
}

ClubPayment _payment({
  required String id,
  required String userId,
  required String month,
  required PaymentStatus status,
  required PaymentMethod method,
  required DateTime submittedAt,
}) {
  return ClubPayment(
    id: id,
    userId: userId,
    amount: 5000,
    month: month,
    status: status,
    paymentMethod: method,
    submittedBy: 'admin',
    submittedAt: submittedAt,
  );
}
