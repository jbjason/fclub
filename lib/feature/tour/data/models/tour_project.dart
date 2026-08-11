class TourProject {
  const TourProject({
    required this.id,
    required this.name,
    required this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String adminId;
  final DateTime createdAt;
  final DateTime updatedAt;
}
