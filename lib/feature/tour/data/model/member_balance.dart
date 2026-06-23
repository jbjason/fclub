class MemberBalance {
  const MemberBalance({
    required this.memberId,
    required this.totalPaidToManager,
    required this.totalSpentOnOthers,
    required this.totalConsumedByThem,
  });

  final String memberId;
  final double totalPaidToManager;
  final double totalSpentOnOthers;
  final double totalConsumedByThem;

  /// Positive = the group owes them. Negative = they owe the group.
  double get netBalance =>
      (totalPaidToManager + totalSpentOnOthers) - totalConsumedByThem;
}
