enum TourExpenseCategory {
  food('food'),
  transport('transport'),
  accommodation('accommodation'),
  snacks('snacks'),
  misc('misc');

  const TourExpenseCategory(this.value);

  final String value;

  static TourExpenseCategory fromValue(Object? value) => values.firstWhere(
    (category) => category.value == value,
    orElse: () => misc,
  );
}

class TourExpense {
  const TourExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidByMemberId,
    required this.paidByAllMembers,
    required this.beneficiaryMemberIds,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final double amount;
  final TourExpenseCategory category;
  final String? paidByMemberId;
  final bool paidByAllMembers;
  final List<String> beneficiaryMemberIds;
  final String? note;
  final String createdBy;
  final DateTime createdAt;
}
