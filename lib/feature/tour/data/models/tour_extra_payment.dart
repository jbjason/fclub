class TourExtraPayment {
  const TourExtraPayment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String memberId;
  final double amount;
  final String? note;
  final String createdBy;
  final DateTime createdAt;
}
