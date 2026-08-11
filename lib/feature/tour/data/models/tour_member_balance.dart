class TourMemberBalance {
  const TourMemberBalance({
    required this.memberId,
    required this.totalPaidToManager,
    required this.totalSpentOnOthers,
    required this.totalConsumedByThem,
  });

  final String memberId;
  final double totalPaidToManager;
  final double totalSpentOnOthers;
  final double totalConsumedByThem;

  /// Positive means the group owes the participant; negative means they owe.
  double get netBalance =>
      (totalPaidToManager + totalSpentOnOthers) - totalConsumedByThem;
}
