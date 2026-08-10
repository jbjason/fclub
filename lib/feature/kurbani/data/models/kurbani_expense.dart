class KurbaniExpense {
  const KurbaniExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidByMemberId,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final String paidByMemberId;
  final String? note;
  final String createdBy;
  final DateTime createdAt;
}
