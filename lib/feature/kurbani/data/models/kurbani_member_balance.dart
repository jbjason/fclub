class KurbaniMemberBalance {
  const KurbaniMemberBalance({
    required this.memberId,
    required this.memberName,
    required this.contributed,
    required this.paidExpenses,
    required this.fairShare,
  });

  final String memberId;
  final String memberName;
  final double contributed;
  final double paidExpenses;
  final double fairShare;

  double get totalCredit => contributed + paidExpenses;
  double get net => totalCredit - fairShare;
  bool get isOwedByGroup => net > .01;
  bool get owesGroup => net < -.01;
  bool get isSettled => net.abs() <= .01;
}
