import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/locker/data/models/locker_participant.dart';
import 'package:fclub/feature/locker/data/models/locker_transaction.dart';
import 'package:fclub/feature/locker/presentation/widgets/locker_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LockerTransactionTile extends StatelessWidget {
  const LockerTransactionTile({
    super.key,
    required this.transaction,
    required this.participant,
    required this.canReview,
    required this.isSubmitting,
    required this.onApprove,
    required this.onReject,
  });

  final LockerTransaction transaction;
  final LockerParticipant? participant;
  final bool canReview;
  final bool isSubmitting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isContribution =
        transaction.type == LockerTransactionType.contribution;
    final accent = isContribution ? MyColor.success : MyColor.error;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: LockerCardShell(
        accent: accent,
        borderRadius: BorderRadius.circular(18.r),
        padding: EdgeInsets.all(13.w),
        child: Column(
          children: [
            Row(
              children: [
                LockerCardIcon(
                  icon: isContribution
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  accent: accent,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant?.username ?? 'locker_participant'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MyString.poppinsMedium,
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${(isContribution ? 'locker_transaction_contribution' : 'locker_transaction_expense').tr()} · ${DateFormat('d MMM yyyy', context.locale.toString()).format(transaction.submittedAt)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: MyString.rubikRegular,
                          fontSize: 9.5.sp,
                        ),
                      ),
                      if (transaction.note != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            transaction.note!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 9.5.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isContribution ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    _StatusLabel(status: transaction.status),
                  ],
                ),
              ],
            ),
            if (canReview &&
                transaction.status == LockerTransactionStatus.pending) ...[
              Divider(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting ? null : onReject,
                    child: Text('locker_reject'.tr()),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isSubmitting ? null : onApprove,
                    child: Text('locker_approve'.tr()),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});
  final LockerTransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      LockerTransactionStatus.pending => MyColor.warning,
      LockerTransactionStatus.approved => MyColor.success,
      LockerTransactionStatus.rejected => MyColor.error,
    };
    final label = switch (status) {
      LockerTransactionStatus.pending => 'locker_status_pending'.tr(),
      LockerTransactionStatus.approved => 'locker_status_approved'.tr(),
      LockerTransactionStatus.rejected => 'locker_status_rejected'.tr(),
    };
    return Container(
      margin: EdgeInsets.only(top: 3.h),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: MyString.rubikMedium,
          fontSize: 7.5.sp,
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
    );
  }
}
