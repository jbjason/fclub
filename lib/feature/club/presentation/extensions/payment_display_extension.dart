import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:flutter/material.dart';

export 'package:fclub/feature/club/data/model/club_payment.dart'
    show PaymentMethod, PaymentStatus;

extension PaymentStatusDisplay on PaymentStatus {
  String get label => switch (this) {
    PaymentStatus.pending => 'Pending',
    PaymentStatus.paid => 'Paid',
    PaymentStatus.rejected => 'Rejected',
  };

  String localizedLabel(BuildContext context) => switch (this) {
    PaymentStatus.pending => context.tr('club_status_pending'),
    PaymentStatus.paid => context.tr('club_status_paid'),
    PaymentStatus.rejected => context.tr('club_status_rejected'),
  };

  Color get color => switch (this) {
    PaymentStatus.pending => MyColor.warning,
    PaymentStatus.paid => MyColor.success,
    PaymentStatus.rejected => MyColor.error,
  };

  IconData get icon => switch (this) {
    PaymentStatus.pending => Icons.schedule_rounded,
    PaymentStatus.paid => Icons.verified_rounded,
    PaymentStatus.rejected => Icons.cancel_rounded,
  };
}

extension PaymentMethodDisplay on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.mobileWallet => 'bKash / Nagad',
    PaymentMethod.bank => 'Bank',
  };

  String localizedLabel(BuildContext context) => switch (this) {
    PaymentMethod.cash => context.tr('club_method_cash'),
    PaymentMethod.mobileWallet => context.tr('club_method_mobile_wallet'),
    PaymentMethod.bank => context.tr('club_method_bank'),
  };

  IconData get icon => switch (this) {
    PaymentMethod.cash => Icons.payments_rounded,
    PaymentMethod.mobileWallet => Icons.phone_android_rounded,
    PaymentMethod.bank => Icons.account_balance_rounded,
  };
}
