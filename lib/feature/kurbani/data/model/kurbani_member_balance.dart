class KurbaniMemberBalance {
  const KurbaniMemberBalance({
    required this.memberId,
    required this.memberName,
    required this.avatarColorIndex,
    required this.contributed,
    required this.paidExpenses,
    required this.fairShare,
  });

  final String memberId;
  final String memberName;
  final int avatarColorIndex;

  /// Amount paid into the shared pool.
  final double contributed;

  /// Amount paid directly from pocket for kurbani expenses.
  final double paidExpenses;

  /// Each member's equal share of total spending.
  final double fairShare;

  double get totalCredit => contributed + paidExpenses;

  /// Positive → group/pool owes them (refund).
  /// Negative → they still owe the group (collect).
  double get net => totalCredit - fairShare;

  bool get isOwedByGroup => net > 0.01;
  bool get owesGroup => net < -0.01;
  bool get isSettled => net.abs() <= 0.01;
}
