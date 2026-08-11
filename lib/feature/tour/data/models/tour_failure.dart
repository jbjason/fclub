class TourFailure implements Exception {
  const TourFailure(this.messageKey, [this.cause]);

  final String messageKey;
  final Object? cause;

  @override
  String toString() => messageKey;
}
