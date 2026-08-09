import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/data/model/club_member.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/data/model/club_payment_filter.dart';
import 'package:fclub/feature/club/data/repositories/firestore_club_repository.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the canonical Firestore month key', () {
    expect(ClubProvider.monthKey(DateTime(2026, 8, 19)), '2026-08');
  });

  test('Club admin authority comes only from matching adminId', () {
    expect(
      ClubProvider.isClubAdmin(adminId: 'creator-id', userId: 'creator-id'),
      isTrue,
    );
    expect(
      ClubProvider.isClubAdmin(adminId: 'creator-id', userId: 'member-id'),
      isFalse,
    );
    expect(
      ClubProvider.isClubAdmin(adminId: null, userId: 'creator-id'),
      isFalse,
    );
  });

  test('Club member documents do not store a role', () {
    final joinedAt = DateTime(2026, 8, 7);
    const member = ClubMemberCandidate(
      id: 'member-id',
      name: 'Member',
      email: 'MEMBER@FUNDORA.APP',
      profilePic: '',
    );

    final data = FirestoreClubRepository.createMemberData(
      member: member,
      joinedAt: joinedAt,
    );

    expect(data['email'], 'member@fundora.app');
    expect(data['joinedAt'], joinedAt);
    expect(data, isNot(contains('role')));
  });

  test('monthly summary uses the project target for every participant', () {
    final payments = [
      _payment(id: 'paid', amount: 5000, status: PaymentStatus.paid),
      _payment(id: 'pending', amount: 5000, status: PaymentStatus.pending),
      _payment(id: 'rejected', amount: 2500, status: PaymentStatus.rejected),
    ];

    final summary = ClubMonthSummary.calculate(
      month: DateTime(2026, 8),
      memberCount: 3,
      perMemberTarget: 5000,
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

  test('admin can see every member payment in every status', () {
    final payments = [
      _payment(
        id: 'own-pending',
        userId: 'member-1',
        amount: 5000,
        status: PaymentStatus.pending,
      ),
      _payment(
        id: 'other-rejected',
        userId: 'member-2',
        amount: 2500,
        status: PaymentStatus.rejected,
      ),
    ];

    final visible = ClubProvider.paymentsVisibleTo(
      payments,
      isAdmin: true,
      memberId: 'member-1',
    );

    expect(visible.map((payment) => payment.id), [
      'own-pending',
      'other-rejected',
    ]);
  });

  test('participant sees only their own transactions', () {
    final payments = [
      _payment(
        id: 'own-paid',
        userId: 'member-1',
        amount: 5000,
        status: PaymentStatus.paid,
      ),
      _payment(
        id: 'own-pending',
        userId: 'member-1',
        amount: 5000,
        status: PaymentStatus.pending,
      ),
      _payment(
        id: 'own-rejected',
        userId: 'member-1',
        amount: 2500,
        status: PaymentStatus.rejected,
      ),
      _payment(
        id: 'other-paid',
        userId: 'member-2',
        amount: 5000,
        status: PaymentStatus.paid,
      ),
      _payment(
        id: 'other-pending',
        userId: 'member-2',
        amount: 5000,
        status: PaymentStatus.pending,
      ),
      _payment(
        id: 'other-rejected',
        userId: 'member-2',
        amount: 2500,
        status: PaymentStatus.rejected,
      ),
    ];

    final visible = ClubProvider.paymentsVisibleTo(
      payments,
      isAdmin: false,
      memberId: 'member-1',
    );

    expect(visible.map((payment) => payment.id), [
      'own-paid',
      'own-pending',
      'own-rejected',
    ]);
  });
}

ClubPayment _payment({
  required String id,
  String? userId,
  required double amount,
  required PaymentStatus status,
}) {
  return ClubPayment(
    id: id,
    userId: userId ?? 'member-$id',
    amount: amount,
    month: '2026-08',
    status: status,
    paymentMethod: PaymentMethod.cash,
    submittedBy: 'submitter',
    submittedAt: DateTime(2026, 8, 5),
  );
}
