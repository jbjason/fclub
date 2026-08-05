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

  static Future<void> confirmDelete(
    BuildContext context,
    ClubPayment payment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('club_delete_confirm'.tr()),
        content: Text('club_delete_warning'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<ClubProvider>().deletePayment(payment.id);
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
