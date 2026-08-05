import 'package:fclub/feature/club/data/model/club_payment.dart';

class ClubMemberPaymentFilter {
  const ClubMemberPaymentFilter({this.status, this.month, this.paymentMethod});

  final PaymentStatus? status;
  final String? month;
  final PaymentMethod? paymentMethod;

  bool get isEmpty => status == null && month == null && paymentMethod == null;

  int get activeCount =>
      [status, month, paymentMethod].where((value) => value != null).length;

  int get advancedFilterCount =>
      [month, paymentMethod].where((value) => value != null).length;

  bool matches(ClubPayment payment) {
    return (status == null || payment.status == status) &&
        (month == null || payment.month == month) &&
        (paymentMethod == null || payment.paymentMethod == paymentMethod);
  }

  ClubMemberPaymentFilter copyWith({
    PaymentStatus? status,
    String? month,
    PaymentMethod? paymentMethod,
    bool clearStatus = false,
    bool clearMonth = false,
    bool clearPaymentMethod = false,
  }) {
    return ClubMemberPaymentFilter(
      status: clearStatus ? null : status ?? this.status,
      month: clearMonth ? null : month ?? this.month,
      paymentMethod: clearPaymentMethod
          ? null
          : paymentMethod ?? this.paymentMethod,
    );
  }
}
