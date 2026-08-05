class ClubMember {
  const ClubMember({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String profilePic;
  final String role;

  bool get isAdmin => role == 'admin';
}

class ClubMemberCandidate {
  const ClubMemberCandidate({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePic,
  });

  final String id;
  final String name;
  final String email;
  final String profilePic;
}
