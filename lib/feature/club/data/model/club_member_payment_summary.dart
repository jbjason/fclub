import 'package:fclub/feature/club/data/model/club_payment.dart';

class ClubMemberPaymentSummary {
  const ClubMemberPaymentSummary({
    required this.totalPaid,
    required this.totalPending,
    required this.totalRejected,
    required this.entryCount,
  });

  final double totalPaid;
  final double totalPending;
  final double totalRejected;
  final int entryCount;

  factory ClubMemberPaymentSummary.calculate(Iterable<ClubPayment> payments) {
    var paid = 0.0;
    var pending = 0.0;
    var rejected = 0.0;
    var count = 0;

    for (final payment in payments) {
      count++;
      switch (payment.status) {
        case PaymentStatus.paid:
          paid += payment.amount;
        case PaymentStatus.pending:
          pending += payment.amount;
        case PaymentStatus.rejected:
          rejected += payment.amount;
      }
    }

    return ClubMemberPaymentSummary(
      totalPaid: paid,
      totalPending: pending,
      totalRejected: rejected,
      entryCount: count,
    );
  }
}
