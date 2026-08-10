enum KurbaniPaidStatus {
  pending('pending'),
  paid('paid');

  const KurbaniPaidStatus(this.value);

  final String value;

  static KurbaniPaidStatus fromValue(Object? value) => values.firstWhere(
    (status) => status.value == value,
    orElse: () => pending,
  );
}

class KurbaniParticipant {
  const KurbaniParticipant({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePic,
    required this.contribution,
    required this.paidStatus,
    required this.joinedAt,
  });

  final String id;
  final String username;
  final String email;
  final String profilePic;
  final double contribution;
  final KurbaniPaidStatus paidStatus;
  final DateTime joinedAt;

  double get collectedContribution =>
      paidStatus == KurbaniPaidStatus.paid ? contribution : 0;
}
