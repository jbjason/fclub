enum KurbaniEventStatus {
  active('active'),
  completed('completed');

  const KurbaniEventStatus(this.value);

  final String value;

  static KurbaniEventStatus fromValue(Object? value) => values.firstWhere(
    (status) => status.value == value,
    orElse: () => active,
  );
}

class KurbaniEvent {
  const KurbaniEvent({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final KurbaniEventStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => status == KurbaniEventStatus.active;
}
