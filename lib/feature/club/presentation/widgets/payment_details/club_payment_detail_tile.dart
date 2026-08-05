import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_payment.dart';
import 'package:fclub/feature/club/presentation/extensions/payment_display_extension.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:fclub/feature/club/presentation/widgets/club_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClubPaymentDetailTile extends StatelessWidget {
  const ClubPaymentDetailTile({super.key, required this.payment});

  final ClubPayment payment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final submittedDate = localizations.formatShortDate(payment.submittedAt);
    final submittedTime = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(payment.submittedAt),
    );

    return ClubCardShell(
      accent: payment.status.color,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: payment.status.color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 21.r,
                  color: payment.status.color,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.formatMonthYear(payment.monthDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 13.sp,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    ClubStatusBadge(status: payment.status),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                CurrencyFormatter.format(payment.amount),
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 15.sp,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(
            height: 1,
            color: payment.status.color.withValues(alpha: .16),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: [
              _infoPill(
                context,
                icon: payment.paymentMethod.icon,
                label: payment.paymentMethod.localizedLabel(context),
              ),
              _infoPill(
                context,
                icon: Icons.schedule_rounded,
                label: '$submittedDate · $submittedTime',
              ),
            ],
          ),
          if (payment.note?.trim().isNotEmpty == true) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: .46),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 15.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      payment.note!.trim(),
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 10.sp,
                        height: 1.35,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoPill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: .52),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: colors.onSurfaceVariant),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 9.sp,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
