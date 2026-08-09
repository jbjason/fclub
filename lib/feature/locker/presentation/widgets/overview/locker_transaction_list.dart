import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';
import 'package:fclub/feature/locker/presentation/provider/locker_provider.dart';
import 'package:fclub/feature/locker/presentation/widgets/overview/locker_transaction_tile.dart';
import 'package:fclub/feature/locker/presentation/widgets/shared/locker_state_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LockerTransactionList extends StatelessWidget {
  const LockerTransactionList({
    super.key,
    required this.transactions,
    required this.participants,
  });

  final List<LockerTransaction> transactions;
  final List<LockerParticipant> participants;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return LockerStatePanel(
        icon: Icons.receipt_long_outlined,
        title: 'locker_no_transactions_title'.tr(),
        message: 'locker_no_transactions_message'.tr(),
      );
    }
    final provider = context.watch<LockerProvider>();
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        LockerParticipant? participant;
        for (final candidate in participants) {
          if (candidate.id == transaction.userId) {
            participant = candidate;
            break;
          }
        }
        return LockerTransactionTile(
          transaction: transaction,
          participant: participant,
          canReview: provider.isAdmin,
          isSubmitting: provider.isSubmitting,
          onApprove: () =>
              _review(context, transaction, LockerTransactionStatus.approved),
          onReject: () =>
              _review(context, transaction, LockerTransactionStatus.rejected),
        );
      },
    );
  }

  Future<void> _review(
    BuildContext context,
    LockerTransaction transaction,
    LockerTransactionStatus status,
  ) async {
    try {
      await context.read<LockerProvider>().reviewTransaction(
        transaction.id,
        status,
      );
    } catch (error) {
      if (!context.mounted) return;
      final message = context.read<LockerProvider>().actionError ?? '$error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
