import 'package:fclub/feature/club/data/model/club_payment.dart';

class ClubMonthSummary {
  const ClubMonthSummary({
    required this.month,
    required this.memberCount,
    required this.target,
    required this.collected,
    required this.pending,
    required this.rejected,
  });

  final DateTime month;
  final int memberCount;
  final double target;
  final double collected;
  final double pending;
  final double rejected;

  double get outstanding => (target - collected).clamp(0, double.infinity);
  double get progress => target <= 0 ? 0 : (collected / target).clamp(0, 1);

  static ClubMonthSummary calculate({
    required DateTime month,
    required int memberCount,
    required double perMemberTarget,
    required Iterable<ClubPayment> payments,
  }) {
    final monthlyPayments = payments.where(
      (payment) =>
          payment.monthDate.year == month.year &&
          payment.monthDate.month == month.month,
    );
    double collected = 0;
    double pending = 0;
    double rejected = 0;
    for (final payment in monthlyPayments) {
      switch (payment.status) {
        case PaymentStatus.paid:
          collected += payment.amount;
        case PaymentStatus.pending:
          pending += payment.amount;
        case PaymentStatus.rejected:
          rejected += payment.amount;
      }
    }
    return ClubMonthSummary(
      month: DateTime(month.year, month.month),
      memberCount: memberCount,
      target: memberCount * perMemberTarget,
      collected: collected,
      pending: pending,
      rejected: rejected,
    );
  }
}
