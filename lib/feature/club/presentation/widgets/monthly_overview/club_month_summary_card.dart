import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/core/util/currency_formatter.dart';
import 'package:fclub/feature/club/data/model/club_constants.dart';
import 'package:fclub/feature/club/data/model/club_month_summary.dart';
import 'package:fclub/feature/club/presentation/widgets/club_card_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ClubMonthSummaryCard extends StatelessWidget {
  const ClubMonthSummaryCard({super.key, required this.summary});

  final ClubMonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClubCardShell(
      accent: MyColor.primary,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          Row(
            children: [
              ClubCardIcon(
                icon: Icons.calendar_month_rounded,
                accent: MyColor.primary,
                size: 42,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(summary.month),
                      style: TextStyle(
                        fontFamily: MyString.poppinsBold,
                        fontSize: 14.sp,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      '${summary.memberCount} members × ${CurrencyFormatter.format(ClubConstants.monthlyTargetPerMember)}',
                      style: TextStyle(
                        fontFamily: MyString.rubikRegular,
                        fontSize: 10.sp,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(summary.progress * 100).round()}%',
                style: TextStyle(
                  fontFamily: MyString.poppinsBold,
                  fontSize: 15.sp,
                  color: MyColor.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 6.h,
              backgroundColor: MyColor.primary.withValues(alpha: .1),
              valueColor: const AlwaysStoppedAnimation(MyColor.primary),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _Metric(
                label: 'Collected',
                amount: summary.collected,
                color: MyColor.success,
              ),
              _Metric(
                label: 'Pending',
                amount: summary.pending,
                color: MyColor.warning,
              ),
              _Metric(
                label: 'Outstanding',
                amount: summary.outstanding,
                color: MyColor.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CurrencyFormatter.format(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: MyString.poppinsBold,
              fontSize: 10.5.sp,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: MyString.rubikRegular,
              fontSize: 8.5.sp,
              color: color.withValues(alpha: .85),
            ),
          ),
        ],
      ),
    );
  }
}
