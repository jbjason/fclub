class ClubFailure implements Exception {
  const ClubFailure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
