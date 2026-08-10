class KurbaniExpense {
  const KurbaniExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidByMemberId,
    this.paidByAllMembers = false,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final String? paidByMemberId;
  final bool paidByAllMembers;
  final String? note;
  final String createdBy;
  final DateTime createdAt;
}
