import 'package:fclub/feature/club/data/model/club_payment.dart';

class ClubPaymentFilter {
  const ClubPaymentFilter({
    this.userId,
    this.month,
    this.status,
    this.paymentMethod,
  });

  final String? userId;
  final String? month;
  final PaymentStatus? status;
  final PaymentMethod? paymentMethod;

  bool get isEmpty =>
      userId == null &&
      month == null &&
      status == null &&
      paymentMethod == null;

  int get advancedFilterCount =>
      [userId, month, paymentMethod].where((value) => value != null).length;

  bool matches(ClubPayment payment) {
    return (userId == null || payment.userId == userId) &&
        (month == null || payment.month == month) &&
        (status == null || payment.status == status) &&
        (paymentMethod == null || payment.paymentMethod == paymentMethod);
  }

  ClubPaymentFilter copyWith({
    String? userId,
    String? month,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    bool clearUser = false,
    bool clearMonth = false,
    bool clearStatus = false,
    bool clearPaymentMethod = false,
  }) {
    return ClubPaymentFilter(
      userId: clearUser ? null : userId ?? this.userId,
      month: clearMonth ? null : month ?? this.month,
      status: clearStatus ? null : status ?? this.status,
      paymentMethod: clearPaymentMethod
          ? null
          : paymentMethod ?? this.paymentMethod,
    );
  }
}
