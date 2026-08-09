enum LockerTransactionType {
  contribution('contribution'),
  expense('expense');

  const LockerTransactionType(this.value);
  final String value;

  static LockerTransactionType fromValue(Object? value) {
    return LockerTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LockerTransactionType.expense,
    );
  }
}

enum LockerTransactionStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const LockerTransactionStatus(this.value);
  final String value;

  static LockerTransactionStatus fromValue(Object? value) {
    return LockerTransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LockerTransactionStatus.pending,
    );
  }
}

class LockerTransaction {
  const LockerTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.userId,
    required this.status,
    required this.submittedBy,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.note,
  });

  final String id;
  final LockerTransactionType type;
  final double amount;
  final String userId;
  final LockerTransactionStatus status;
  final String submittedBy;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? note;
}
