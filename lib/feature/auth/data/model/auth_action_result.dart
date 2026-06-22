class AuthActionResult {
  const AuthActionResult._({
    required this.isSuccess,
    required this.message,
  });

  final bool isSuccess;
  final String message;

  factory AuthActionResult.success([String message = '']) {
    return AuthActionResult._(isSuccess: true, message: message);
  }

  factory AuthActionResult.failure(String message) {
    return AuthActionResult._(isSuccess: false, message: message);
  }
}
