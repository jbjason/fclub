import 'package:fclub/feature/home/data/models/group_failure.dart';

extension GroupFailureLocalization on GroupFailure {
  String get localizationKey => switch (code) {
    GroupFailureCode.unauthenticated => 'group_error_unauthenticated',
    GroupFailureCode.emailUnavailable => 'group_error_email_unavailable',
    GroupFailureCode.invalidInput => 'group_error_invalid_input',
    GroupFailureCode.groupNotFound => 'group_error_group_not_found',
    GroupFailureCode.pinUnavailable => 'group_error_pin_unavailable',
    GroupFailureCode.permissionDenied => 'group_error_permission_denied',
    GroupFailureCode.network => 'group_error_network',
    GroupFailureCode.tooManyMembers => 'group_error_too_many_members',
    GroupFailureCode.usersLoadFailed => 'group_error_users_load',
    GroupFailureCode.unknown => 'group_error_unknown',
  };
}
