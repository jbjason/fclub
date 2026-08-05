enum GroupFailureCode {
  unauthenticated,
  emailUnavailable,
  invalidInput,
  groupNotFound,
  pinUnavailable,
  permissionDenied,
  network,
  tooManyMembers,
  usersLoadFailed,
  unknown,
}

class GroupFailure implements Exception {
  const GroupFailure(this.code, [this.cause]);

  final GroupFailureCode code;
  final Object? cause;
}
