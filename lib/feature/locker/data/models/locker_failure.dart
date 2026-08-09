class LockerFailure implements Exception {
  const LockerFailure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
