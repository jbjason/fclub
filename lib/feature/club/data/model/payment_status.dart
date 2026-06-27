import 'package:fclub/core/constants/my_color.dart';
import 'package:flutter/material.dart';

/// Status of a single member's monthly contribution record.
enum PaymentStatus { paid, due, advance }

/// Display metadata for [PaymentStatus] — kept constant across light/dark
/// themes so status colors stay instantly recognizable.
extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.due:
        return 'Due';
      case PaymentStatus.advance:
        return 'Advance';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.paid:
        return MyColor.success;
      case PaymentStatus.due:
        return MyColor.error;
      case PaymentStatus.advance:
        return MyColor.warning;
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.paid:
        return Icons.check_circle_rounded;
      case PaymentStatus.due:
        return Icons.error_rounded;
      case PaymentStatus.advance:
        return Icons.upcoming_rounded;
    }
  }
}
