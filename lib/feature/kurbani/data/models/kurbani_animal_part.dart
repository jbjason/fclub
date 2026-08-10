class KurbaniAnimalPart {
  const KurbaniAnimalPart({
    required this.id,
    required this.name,
    required this.weightKg,
    required this.assignedToUid,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double weightKg;
  final String? assignedToUid;
  final String? note;
  final String createdBy;
  final DateTime createdAt;
}
