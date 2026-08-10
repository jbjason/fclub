enum KurbaniProjectStatus {
  active('active'),
  completed('completed');

  const KurbaniProjectStatus(this.value);

  final String value;

  static KurbaniProjectStatus fromValue(Object? value) => values.firstWhere(
    (status) => status.value == value,
    orElse: () => active,
  );
}

class KurbaniProject {
  const KurbaniProject({
    required this.id,
    required this.name,
    required this.adminId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String adminId;
  final KurbaniProjectStatus status;
  final DateTime createdAt;
}
