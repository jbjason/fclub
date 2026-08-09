import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:fclub/feature/club/presentation/provider/club_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract final class ClubPaymentReviewActions {
  static Future<void> updateStatus(
    BuildContext context,
    ClubPayment payment,
    PaymentStatus status,
  ) async {
    try {
      await context.read<ClubProvider>().updatePaymentStatus(
        payment.id,
        status,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'club_payment_marked'.tr(
              namedArgs: {'status': status.localizedLabel(context)},
            ),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<ClubProvider>().actionError ?? '$error'),
        ),
      );
    }
  }
}
