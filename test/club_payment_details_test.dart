import 'package:fclub/feature/club/data/model/club_member_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/provider/club_payment_details_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClubPaymentDetailsProvider', () {
    final payments = [
      _payment(
        id: 'newer-paid',
        userId: 'member-1',
        month: '2026-08',
        status: PaymentStatus.paid,
        method: PaymentMethod.cash,
        amount: 5000,
      ),
      _payment(
        id: 'older-pending',
        userId: 'member-1',
        month: '2026-07',
        status: PaymentStatus.pending,
        method: PaymentMethod.mobileWallet,
        amount: 3000,
      ),
      _payment(
        id: 'other-member',
        userId: 'member-2',
        month: '2026-08',
        status: PaymentStatus.paid,
        method: PaymentMethod.cash,
        amount: 9000,
      ),
    ];

    test('keeps only the selected member and sorts newest first', () {
      final provider = ClubPaymentDetailsProvider(userId: 'member-1');

      final result = provider.memberPayments(payments);

      expect(result.map((payment) => payment.id), [
        'newer-paid',
        'older-pending',
      ]);
    });

    test('applies page filters without changing the source list', () {
      final provider = ClubPaymentDetailsProvider(userId: 'member-1');
      provider.applyFilter(
        const ClubMemberPaymentFilter(
          status: PaymentStatus.pending,
          month: '2026-07',
          paymentMethod: PaymentMethod.mobileWallet,
        ),
      );

      final result = provider.filteredPayments(payments);

      expect(result.single.id, 'older-pending');
      expect(payments, hasLength(3));
    });

    test('summary excludes payments belonging to another member', () {
      final provider = ClubPaymentDetailsProvider(userId: 'member-1');

      final summary = provider.summary(payments);

      expect(summary.totalPaid, 5000);
      expect(summary.totalPending, 3000);
      expect(summary.totalRejected, 0);
      expect(summary.entryCount, 2);
    });
  });
}

ClubPayment _payment({
  required String id,
  required String userId,
  required String month,
  required PaymentStatus status,
  required PaymentMethod method,
  required double amount,
}) {
  return ClubPayment(
    id: id,
    userId: userId,
    amount: amount,
    month: month,
    status: status,
    paymentMethod: method,
    submittedBy: 'admin',
    submittedAt: DateTime.parse('$month-05'),
  );
}
