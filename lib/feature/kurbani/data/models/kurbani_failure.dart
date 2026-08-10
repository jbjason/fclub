class KurbaniFailure implements Exception {
  const KurbaniFailure(this.messageKey, [this.cause]);

  final String messageKey;
  final Object? cause;

  @override
  String toString() => messageKey;
}
