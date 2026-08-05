import 'package:fclub/feature/club/data/model/club_member_payment_filter.dart';
import 'package:fclub/feature/club/data/model/club_member_payment_summary.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:flutter/foundation.dart';

class ClubPaymentDetailsProvider with ChangeNotifier {
  ClubPaymentDetailsProvider({required this.userId});

  final String userId;

  ClubMemberPaymentFilter _filter = const ClubMemberPaymentFilter();

  ClubMemberPaymentFilter get filter => _filter;

  List<ClubPayment> memberPayments(Iterable<ClubPayment> payments) {
    final result = payments
        .where((payment) => payment.userId == userId)
        .toList(growable: false);
    return result..sort((first, second) {
      final monthComparison = second.monthDate.compareTo(first.monthDate);
      return monthComparison != 0
          ? monthComparison
          : second.submittedAt.compareTo(first.submittedAt);
    });
  }

  List<ClubPayment> filteredPayments(Iterable<ClubPayment> payments) {
    return memberPayments(
      payments,
    ).where(_filter.matches).toList(growable: false);
  }

  ClubMemberPaymentSummary summary(Iterable<ClubPayment> payments) {
    return ClubMemberPaymentSummary.calculate(memberPayments(payments));
  }

  List<String> availableMonths(Iterable<ClubPayment> payments) {
    final months = memberPayments(payments).map((payment) => payment.month);
    return months.toSet().toList(growable: false)
      ..sort((first, second) => second.compareTo(first));
  }

  void selectStatus(PaymentStatus? status) {
    final next = _filter.copyWith(status: status, clearStatus: status == null);
    _updateFilter(next);
  }

  void applyFilter(ClubMemberPaymentFilter filter) {
    _updateFilter(filter);
  }

  void clearFilters() {
    _updateFilter(const ClubMemberPaymentFilter());
  }

  void _updateFilter(ClubMemberPaymentFilter filter) {
    if (_filter.status == filter.status &&
        _filter.month == filter.month &&
        _filter.paymentMethod == filter.paymentMethod) {
      return;
    }
    _filter = filter;
    notifyListeners();
  }
}
