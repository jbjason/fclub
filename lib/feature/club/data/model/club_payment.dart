enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  rejected('rejected');

  const PaymentStatus(this.value);

  final String value;

  static PaymentStatus fromValue(Object? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentMethod {
  cash('cash'),
  mobileWallet('bkash/nagad'),
  bank('bank');

  const PaymentMethod(this.value);

  final String value;

  static PaymentMethod fromValue(Object? value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

class ClubPayment {
  const ClubPayment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.month,
    required this.status,
    required this.paymentMethod,
    required this.submittedBy,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.note,
  });

  final String id;
  final String userId;
  final double amount;

  /// Canonical Firestore value in `yyyy-MM` format.
  final String month;
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final String submittedBy;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? note;

  DateTime get monthDate {
    final parts = month.split('-');
    if (parts.length != 2) return DateTime(submittedAt.year, submittedAt.month);
    return DateTime(
      int.tryParse(parts.first) ?? submittedAt.year,
      int.tryParse(parts.last) ?? submittedAt.month,
    );
  }

  ClubPayment copyWith({
    PaymentStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return ClubPayment(
      id: id,
      userId: userId,
      amount: amount,
      month: month,
      status: status ?? this.status,
      paymentMethod: paymentMethod,
      submittedBy: submittedBy,
      submittedAt: submittedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      note: note,
    );
  }
}
