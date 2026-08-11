enum TourEventStatus {
  planning('planning'),
  active('active'),
  completed('completed'),
  cancelled('cancelled');

  const TourEventStatus(this.value);

  final String value;

  static TourEventStatus fromValue(Object? value) => values.firstWhere(
    (status) => status.value == value,
    orElse: () => planning,
  );
}

class TourEvent {
  const TourEvent({
    required this.id,
    required this.tourName,
    required this.decidedBudget,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
  });

  final String id;
  final String tourName;
  final double decidedBudget;
  final TourEventStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  bool get isOpen =>
      status == TourEventStatus.planning || status == TourEventStatus.active;

  bool get isCompleted => status == TourEventStatus.completed;
}
