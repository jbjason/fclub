import 'package:fclub/feature/club/data/model/club_month_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:flutter/foundation.dart';

class ClubMonthPaymentDetailsProvider with ChangeNotifier {
  ClubMonthPaymentDetailsProvider({required DateTime month})
    : month = DateTime(month.year, month.month);

  final DateTime month;

  ClubMonthPaymentFilter _filter = const ClubMonthPaymentFilter();

  ClubMonthPaymentFilter get filter => _filter;
  String get monthKey => ClubProvider.monthKey(month);

  List<ClubPayment> monthPayments(Iterable<ClubPayment> payments) {
    final result = payments
        .where((payment) => payment.month == monthKey)
        .toList(growable: false);
    return result..sort(
      (first, second) => second.submittedAt.compareTo(first.submittedAt),
    );
  }

  List<ClubPayment> filteredPayments(Iterable<ClubPayment> payments) {
    return monthPayments(
      payments,
    ).where(_filter.matches).toList(growable: false);
  }

  ClubMonthSummary summary({
    required Iterable<ClubPayment> payments,
    required int memberCount,
    required double perMemberTarget,
  }) {
    return ClubMonthSummary.calculate(
      month: month,
      memberCount: memberCount,
      perMemberTarget: perMemberTarget,
      payments: payments,
    );
  }

  Set<String> paymentUserIds(Iterable<ClubPayment> payments) {
    return monthPayments(payments).map((payment) => payment.userId).toSet();
  }

  void selectStatus(PaymentStatus? status) {
    _updateFilter(
      _filter.copyWith(status: status, clearStatus: status == null),
    );
  }

  void applyFilter(ClubMonthPaymentFilter filter) {
    _updateFilter(filter);
  }

  void clearFilters() {
    _updateFilter(const ClubMonthPaymentFilter());
  }

  void _updateFilter(ClubMonthPaymentFilter filter) {
    if (_filter.status == filter.status &&
        _filter.userId == filter.userId &&
        _filter.paymentMethod == filter.paymentMethod) {
      return;
    }
    _filter = filter;
    notifyListeners();
  }
}
