import 'package:fclub/feature/club/data/model/club_payment.dart';

class ClubMonthPaymentFilter {
  const ClubMonthPaymentFilter({this.status, this.userId, this.paymentMethod});

  final PaymentStatus? status;
  final String? userId;
  final PaymentMethod? paymentMethod;

  bool get isEmpty => status == null && userId == null && paymentMethod == null;

  int get advancedFilterCount =>
      [userId, paymentMethod].where((value) => value != null).length;

  bool matches(ClubPayment payment) {
    return (status == null || payment.status == status) &&
        (userId == null || payment.userId == userId) &&
        (paymentMethod == null || payment.paymentMethod == paymentMethod);
  }

  ClubMonthPaymentFilter copyWith({
    PaymentStatus? status,
    String? userId,
    PaymentMethod? paymentMethod,
    bool clearStatus = false,
    bool clearUser = false,
    bool clearPaymentMethod = false,
  }) {
    return ClubMonthPaymentFilter(
      status: clearStatus ? null : status ?? this.status,
      userId: clearUser ? null : userId ?? this.userId,
      paymentMethod: clearPaymentMethod
          ? null
          : paymentMethod ?? this.paymentMethod,
    );
  }
}
