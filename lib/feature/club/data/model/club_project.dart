class ClubProject {
  const ClubProject({
    required this.id,
    required this.name,
    required this.adminId,
    required this.monthlyTargetPerMember,
  });

  final String id;
  final String name;
  final String adminId;
  final double monthlyTargetPerMember;
}
