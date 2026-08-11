class TourParticipant {
  const TourParticipant({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePic,
    required this.avatarColorIndex,
    required this.paidToManager,
    required this.joinedAt,
  });

  final String id;
  final String username;
  final String email;
  final String profilePic;
  final int avatarColorIndex;
  final double paidToManager;
  final DateTime joinedAt;

  String get name => username;
}

class TourParticipantCandidate {
  const TourParticipantCandidate({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePic,
    required this.avatarColorIndex,
  });

  final String id;
  final String username;
  final String email;
  final String profilePic;
  final int avatarColorIndex;

  String get name => username;
}
